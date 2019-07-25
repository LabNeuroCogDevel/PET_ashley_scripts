#!/bin/bash

#set -uo pipefail

#Title: extractROIs_Finn.bash
#Author: Ashley Parr (adapted from Finn's /Volumes/Zeus/preproc/scripts_finn/pet/08_ExtractROIs_R.sh 
#Purpose: Script to extract timeseries across all harvard oxford + gordon parcellation atlas.  
#Directory: /Volumes/Hera/Projects/mMR_PETDA

#scriptdir=$(pwd)
gmthes=.5
gmmask=/Volumes/Hera/Projects/mMR_PETDA/scripts_ashley//gm_p=${gmthes}_2.3mm.nii.gz

    if [ ! -r $gmmask ]; then
        3dcalc -a ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii  -expr "step(a-$gmthes)" -prefix gmmask${thres}_1mm.nii.gz
        exampleinput=/Volumes/Phillips/mMR_PETDA/subjs/10195_20160317/background_connectivity/cbgnfswdktm_tent_resid.nii.gz
        3dresample -master $exampleinput -inset gmmask${thres}_1mm.nii.gz -prefix $gmmask -rmode NN
    fi


#DATADIR=/Volumes/Phillips/mMR_PETDA/subjs
SAVEDIR=/Volumes/Hera/Projects/mMR_PETDA/subjs
#DATADIR=/Volumes/Phillips/mMR_PETDA/subjs
atlas=/Volumes/Phillips/CogRest/atlas/Gordon_HarOX_2.3mm.nii.gz
#outinfo=gsdd-wm-csf-6mot_vmpfc-striatal-vta
outinfo=GordonHarOx
censor_file=censor_merged_fd_0.3_dvars_Inf.1D
#cd $DATADIR

#echo "atlas: ${atlas}"
#echo "mask: ${mask}"
#echo "outinfo: ${outinfo}"
#echo "pwd: $(pwd)"

# # setup running many jobs
# MAXJOBS=5
# WAITTIME=60
# source /opt/ni_tools/lncdshell/utils/waitforjobs.sh

#cd $SAVEDIR
for subj_path in $SAVEDIR/1*_2*; do 
   sub_id=$(basename "$subj_path") 
   echo $sub_id
#outdir=$subj/
#outdir=${outdir/Phillips/Hera/Projects}

   censor_merged=$SAVEDIR/$sub_id/background_connectivity/$censor_file
   [ ! -r $censor_merged ] && echo "no censor merge files! ($censor_merged)" && continue
   if [ $(cat $censor_merged | wc -l) -eq 0 ]; then
      ntsc=$(cat $sub_id/func/[1-6]/motion_info/censor_custom_fd_0.3_dvars_Inf.1d | wc -l )
      [ $ntsc -ne 1200 ] && echo "wrong number of censored rows ($ntsc)" && continue
      cat $subj_path/func/[1-6]/motion_info/censor_custom_fd_0.3_dvars_Inf.1d > $SAVEDIR/$sub_id/background_connectivity/${censor_file}
   fi 
   [ ! -r $censor_merged ]  && echo "failed to make $censor_merged" && continue

   # subject info
   # skip if we already made
   outfile=${sub_id}_${outinfo}_adj_gsr_pearson.txt
   outfilep=${sub_id}_${outinfo}_ts_gsr.txt
   [ -r "$SAVEDIR/$sub_id/background_connectivity/$outfilep" ] && echo "# have $outfilep" && continue


   # check for files
#  censor=$subj/merged_censor_union.1D
 # censor=$subj/background_connectivity/censor_merged_fd_0.3_dvars_Inf.1D
  input=/Volumes/Phillips/mMR_PETDA/subjs/$sub_id/background_connectivity/cbgnfswdktm_tent_resid.nii.gz
   if [ ! -r "$censor_merged" -o ! -r $input ]; then
      echo "# $sub_id: missing censor or input ('$censor' and '$input')" 
      continue
   fi

   # create adj matrix file
   echo "# ${sub_id}: $(date): generating $outfile"
   #set -x # turn tracing on
   ROI_TempCorr.R \
      -ts $input \
      -rois $atlas \
      -out_file $SAVEDIR/$sub_id/background_connectivity/$outfile \
      -ts_out_file $SAVEDIR/$sub_id/background_connectivity/$outfilep \
      -roi_reduce pca -corr_method pearson -fisherz \
      -brainmask $gmmask \
      -censor $censor_merged \
      -njobs 32
   # set +x # turn tracing back off
   echo "# ${sub_id}: $(date): made $outfile"
   #waitforjobs
done
wait
