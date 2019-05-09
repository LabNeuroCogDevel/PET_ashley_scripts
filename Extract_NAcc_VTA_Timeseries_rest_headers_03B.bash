#!/bin/bash
set -euo pipefail

#Title: Extract_NAcc_VTA_Timeseries_rest_headers.bash
#Author: Ashley Parr
#Purpose: Script to extract right & left NAcc and VTA timeseries individually from output of ROI_Tempcorr where I had previously extracted timeseries for entire striatum, vmPFC and VTA atlases/masks.Had to be redone because ROIs were not numbered properly and it was throwing them off. Had Will rerun the ROI_TempCorr script with header so their numbers could match those in the background data. 

#Date: 04/29/2019
#Dir: /Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica

DATADIR=/Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica
cd $DATADIR

#for ts4d in /Volumes/Zeus/preproc/petrest_rac*/mHRest_FM_ica/1*_2*/*_vmpfc_striatal_vta_mean_gsr_ts.txt; do
for subj in $DATADIR/1*; do
   echo $subj
   sub_id=$(basename "$subj")
#   [[ $ts4d =~ [0-9{5}_[0-9]{8} ]] || continue
#   sub_id=$BASH_REMATCH
#   subjdir=$(dirname $ts4d)

   if [ -r $subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt ];
   then
      echo "ts file exists for $sub_id"
   else
      echo "ts file is missing $sub_id" && continue
   fi

   col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi40 | awk '{print $1}')
   cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_R_NAcc.1D

   col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi34 | awk '{print $1}')
   cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_L_NAcc.1D

   col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi44 | awk '{print $1}')
   cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_VTA.1D

   col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi38 | awk '{print $1}')
   cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_R_Caudate.1D

   col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi32 | awk '{print $1}')
   cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_L_Caudate.1D

   col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi42 | awk '{print $1}')
   cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_R_Putamen.1D
   #the sed part removes the header because 3dDeconvolve doesn't like it
   col=$(head -n1 /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi36 | awk '{print $1}')
   cut -d' ' -f $col /$subj/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/${sub_id}_L_Putamen.1D
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
