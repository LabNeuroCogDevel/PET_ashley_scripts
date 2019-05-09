#!/bin/bash
set -euo pipefail

#Title: Extract_Timeseries.bash
#Author: Ashley Parr
#Purpose: Script to extract timeseries across all ROIs outlined in Merge_atlases.bash (VMPFC, Striatal, VTA). 
#Directory: /Volumes/Phillips/mMR_PETDA/subjs 
# 04/26/2019 updated such that it skips over files that are already created and only does those that aren't there! 

#ROIDIR=/Volumes/Phillips/mMR_PETDA/atlas/Ashley
#cd $ROIDIR
#pwd
atlas=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/VMPFC_STRIATAL_VTA_ROIS_rsfunctemp.nii.gz
mask=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/Brain_Mask_GM_50thres_rsfunctemplate.nii.gz

echo ${atlas}
echo ${mask}

for ts4d in /Volumes/Zeus/preproc/petrest_rac*/MHRest_FM_ica/1*_2*/bgrnaswudktm_func_4.nii.gz; do 
   [[ $ts4d =~ [0-9]{5}_[0-9]{8} ]] || continue
   subj_id=$BASH_REMATCH

   subjdir=$(dirname $ts4d)
   censor=$subjdir/motion_info/censor_custom_fd_0.3_dvars_Inf.1d
   [ ! -r $censor ] && echo "cannot find $censor; skipping" && continue

   tsoutfile=$subjdir/${subj_id}_vmpfc_striatal_vta_mean_gsr_ts.txt 
   adjoutfile=$subjdir/${subj_id}_vmpfc_striatal_vta_mean_gsr_pearson_adj.txt 
   # only run if we haven't
   [ -r $tsoutfile ] && continue

   echo "$subj_id $(date) $subjdir"
   ROI_TempCorr.R \
        -ts $ts4d \
        -rois $atlas \
        -out_file $adjoutfile \
        -ts_out_file $tsoutfile \
        -roi_reduce mean -corr_method pearson -fisherz \
        -brainmask $mask \
        -censor $censor \
        -write_header 1
done



