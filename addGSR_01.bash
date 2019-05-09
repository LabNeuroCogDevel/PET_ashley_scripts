#!/usr/bin/env bash

MAXJOBS=5
WAITTIME=60
JOBCFGDIR=/Volumes/Phillips/mMR_PETDA/scripts_ashley
source /opt/ni_tools/lncdshell/utils/waitforjobs.sh
set -euo pipefail

# where to get mni csf and wm tissue probabilities, and what value to use in thresholding
CSF_PROB="/opt/ni_tools/standard_old/mni_icbm152_nlin_asym_09c/mni_icbm152_csf_tal_nlin_asym_09c_2.3mm.nii"
CSF_THRES=.98
WM_PROB="/opt/ni_tools/standard_old/mni_icbm152_nlin_asym_09c/mni_icbm152_wm_tal_nlin_asym_09c_2.3mm.nii"
WM_THRES=.95
MAXCENSOR=$(((1200 - 959))) # total timepoints - number of regressors

# use the folders given or run on all
[ $# -eq 0 ] && echo "USAGE: $0 all; $0 /Volumes/Phillips/mMR_PETDA/subjs/11434_20160601/" && exit 1
if [ $1 == "all" ]; then
  echo "# finding all subjects"
  files=( /Volumes/Phillips/mMR_PETDA/subjs/1*_2*/func);
else 
  files=($@) 
fi

# get subject directory from an input file
subj_root_dir(){ perl -lne 'print $& while m:/Volumes/.*?/\d{5}_\d{8}/:g' | sort | uniq; }

# given a file, get the preprocessFunctional "funcFile" no prefix name
get_suffix(){
   local f="$1"                  # path/to/blah/nfswdktm_thingwecareabout_5.nii.gz
   fname=$(basename $f .nii.gz); # nfswdktm_thingwecareabout_5
   noprefix=${fname#*_};         # thingwecareabout_5
   # remove smoothing kernel (probably 5, but could be 4)
   noprefix=${noprefix/_[45]/}   # thingwecareabout
   echo $noprefix 
}

get_ts() {
 local mask=$1; shift
 local input=$1; shift
 local out=$1; shift
 [ ! -r $mask ] && echo "$FUNCNAME: missing mask $mask" && return 1
 [ ! -r $input ] && echo "$FUNCNAME: missing ts input $input" && return 1
 3dmaskave -q -mask $mask $input > $out
 1d_tool.py -overwrite -infile $out -demean -write $out
 1d_tool.py -overwrite -infile $out -derivative -demean -write ${out}_deriv
}

project() {
   local subj_root="$1"; shift
   local func_dir=$subj_root/func/
   local input=$func_dir/nfswdktm_tent_resid.nii.gz 
   [ ! -r $input ] && echo "$input DNE!" && return 1
   # check mni space
   local E_in="$(3dinfo -ad3 -extent $input)"
   local E_WM="$(3dinfo -ad3 -extent $WM_PROB)"
   if [  "$E_in" != "$E_WM" ]; then
      echo "prob mask ($E_WM) and input ($E_in) have different dim or extents, different MNI? ($input vs $WM_PROB)"
      return 1
   fi
   local TR=$(3dinfo -tr $input)

   # file name parsing
   noprefix=$(get_suffix $input)       # tent_resid | gam_resid
   fname=$(basename $input .nii.gz)    # nfswdktm_tent_resid
   final_prefix=${fname%%_*};          # nfswdktm

   this_dir=$subj_root/background_connectivity
   [ ! -d $this_dir ] && mkdir $this_dir
   cd $this_dir

   bandpass_gsr_file=cbg${final_prefix}_$noprefix.nii.gz
   # cbgnfswdktm_tent_resid.nii.gz
   [ -r $bandpass_gsr_file ] && echo "$(pwd)/$bandpass_gsr_file exists; skipping" && return 1

   local censor=$subj_root/merged_censor_union.1D
   [ ! -r $censor ] && echo "$func_dir/merged_censor_union.1D DNE" && return 1
   local ncensor=$(grep -c '^0$' $censor)
   [  $ncensor -gt $MAXCENSOR ] && echo "$censor: Too many censored timepoints ($ncensor > $MAXCENSOR)!" && return 1

   nuisance=nuisance_$noprefix
   if [ ! -r $nuisance ]; then
      echo "# making $nuisance $(pwd)"
      # check we match input/gsr counts
      n_input=$(3dNotes $input |perl -lne 'print $& while m:/Volume\S*/func/[0-6]\S*?.nii.gz:g'|wc -l)
      n_mot=$(ls $func_dir/[1-6]/motion.par|wc -l)
      [ $n_input -ne $n_mot ] && echo "$func_dir: number motion.par ($n_mot) != number input func ($n_input)" && return 1

      # motion
      cat  $func_dir/[1-6]/motion.par  |
        1d_tool.py -overwrite -set_nruns $n_mot -demean -write motion_demean -infile -

      # gsr
      [ ! -s brainmask.nii.gz ] && 
        3dTstat -prefix brainmask.nii.gz -nzcount $input && 
        3dcalc -a brainmask.nii.gz -expr 'step(a)' -overwrite -prefix brainmask.nii.gz
      get_ts brainmask.nii.gz $input gs_ts_$noprefix

      ## csf
      [ ! -s csf_mask.nii.gz ] && 
         fslmaths "$CSF_PROB" -thr $CSF_THRES -bin csf_mask_all.nii.gz && 
         3dcalc -a csf_mask_all.nii.gz -m brainmask.nii.gz -expr "a*m" -prefix csf_mask.nii.gz
      # make csf_ts_tent_resid and csf_ts_tent_resid_deriv
      get_ts csf_mask.nii.gz $input csf_ts_$noprefix  

      ## wm
      [ ! -s wm_mask.nii.gz ] && 
         fslmaths "$WM_PROB" -thr $WM_THRES -bin -eroF wm_mask_all.nii.gz &&
         3dcalc -a wm_mask_all.nii.gz -m brainmask.nii.gz -expr "a*m" -prefix wm_mask.nii.gz
      # make wm_ts_tent_resid and wm_ts_tent_resid_deriv
      get_ts wm_mask.nii.gz $input wm_ts_$noprefix

      # combine all regressors
      1dcat motion_demean  gs_ts_$noprefix csf_ts_$noprefix csf_ts_${noprefix}_deriv wm_ts_$noprefix wm_ts_${noprefix}_deriv > ${nuisance}_unfiltered
		1dBandpass -dt $TR 0.009 .08 ${nuisance}_unfiltered > $nuisance
   fi

   3dTproject -input $input -prefix $bandpass_gsr_file -censor $censor -cenmode NTRP -passband 0.009 0.08 -polort 2 -ort $nuisance -mask brainmask.nii.gz
   echo "# made  $(pwd)/$bandpass_gsr_file"

}

## 3dTproject each resid
for subj_root in $(echo ${files[@]} | subj_root_dir ); do
   project $subj_root &
   sleep .25 # time for job to return if next
   waitforjobs
done
wait
