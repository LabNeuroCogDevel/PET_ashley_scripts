#!/bin/bash
set -euo pipefail

#Title: Extract_NAcc_VTA_Timeseries_rest_headers.bash
#Author: Ashley Parr
#Purpose: Script to extract right & left NAcc and VTA timeseries individually from output of ROI_Tempcorr where I had previously extracted timeseries for entire striatum, vmPFC and VTA atlases/masks.Had to be redone because ROIs were not numbered properly and it was throwing them off. Had Will rerun the ROI_TempCorr script with header so their numbers could match those in the background data. 

#Date: 04/29/2019
#Dir: /Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica

DATADIR=/Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica
cd $DATADIR

roicol() {
   # get params from function call
   subj="$1"
   roi="$2"
   roiname="$3"

   sub_id=$(basename "$subj")
   out="/$subj/${sub_id}_${roiname}.1D"

   # skip if already done
   [ -r $out ] && return 0

   # find again
   tsout=$(find $subj/ -maxdepth 1 -iname '*_vmpfc_striatal_vta_mean_gsr_ts.txt')
   [ -z "$tsout" -o ! -r "$tsout" ] && echo "cannot find (or found too many) $subj tsout: '$tsout')" >&2

   # find what column the roi is in output
   col=$(head -n1 $tsout |tr ' ' '\n' | cat -n|grep $roi\" | awk '{print $1}')
   # make sure we have a column
   ! [[ "$col" =~ ^[0-9]+$ ]] && echo "# bad col ($col) for $roi in $tsout" >&2 && return 1
   # extract it
   cut -d' ' -f $col $tsout |sed '/roi/d' > $out 
}

#for ts4d in /Volumes/Zeus/preproc/petrest_rac*/mHRest_FM_ica/1*_2*/*_vmpfc_striatal_vta_mean_gsr_ts.txt; do
for subj in $DATADIR/1*; do
   echo $subj
   sub_id=$(basename "$subj")
#   [[ $ts4d =~ [0-9{5}_[0-9]{8} ]] || continue
#   sub_id=$BASH_REMATCH
#   subjdir=$(dirname $ts4d)

   if [ ! -r $subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt ]; then
      echo "ts file is missing $sub_id ($subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt)" && continue
   #else
   #   echo "ts file exists for $sub_id ($subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt)"
   fi
   finalfile=$subj/${sub_id}_L_subg_cingulate_gsr.1D
   [ -r $finalfile ] && echo "have $finalfile, skipping" && continue
   echo "making $finalfile"

   roicol $subj roi40 R_NAcc
   #col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi40 | awk '{print $1}')
   #cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_R_NAcc.1D

   roicol $subj roi34 L_NAcc
   #col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi34 | awk '{print $1}')
   #cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_L_NAcc.1D

   roicol $subj roi44 VTA
   #col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi44 | awk '{print $1}')
   #cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_VTA.1D

   roicol $subj roi38 R_Caudate
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi38 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_R_Caudate.1D

   roicol $subj roi32 L_Caudate
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi32 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_L_Caudate.1D

   roicol $subj roi42 R_Putamen
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi42 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_R_Putamen.1D
   # #the sed part removes the header because 3dDeconvolve doesn't like it
   roicol $subj roi36 L_Putamen
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi36 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_L_Putamen.1D
  
   roicol $subj roi26 R_vACC
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi26 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_R_vACC.1D
   # 
   roicol $subj roi10 L_vACC
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi10 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_L_vACC.1D
   # 
   roicol $subj roi18 R_post_med_OFC_1
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi18 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_R_post_med_OFC_1.1D
   # 
   roicol $subj roi2 L_post_med_OFC_1
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi2 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_L_post_med_OFC_1.1D
   # 
   roicol $subj roi28 R_subg_cingulate
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi28 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_R_subg_cingulate.1D
   # 
   roicol $subj roi12 L_subg_cingulate
   # col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi12 | awk '{print $1}')
   # cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_L_subg_cingulate.1D
   echo $subj
#   echo "$subj_id $(date) $subjdir"
done

    # 3dROIstats  -mask /Volumes/Phillips/mMR_PETDA/atlas/Ashley/VMPFC_STRIATAL_VTA_ROIS_rsfunctemp.nii.gz /Volumes/Phillips/mMR_PETDA/atlas/Ashley/VMPFC_STRIATAL_VTA_ROIS_rsfunctemp.nii.gz  |sed 1q|cut -f 3-|sed 's/Mean_//g;s/\t/\n/g;'|cat -n
# roi   pos   # roi pos # roi pos       # roi40 R_NAcc.1D
# censor 1    # 14 9    # 32 18         # roi34 L_NAcc.1D
# 1      2    # 16 10   # 34 19         # roi44 VTA.1D
# 2      3    # 18 11   # 36 20         # roi38 R_Caudate.1D
# 4      4    # 20 12   # 38 21         # roi32 L_Caudate.1D
# 6      5    # 22 13   # 40 22         # roi42 R_Putamen.1D
# 8      6    # 24 14   # 42 23         # roi36 L_Putamen.1D
# 10     7    # 26 15   # 44 24
# 12     8    # 28 16   # 68 25
              # 30 17
