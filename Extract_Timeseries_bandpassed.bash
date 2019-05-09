#!/bin/bash

#Title: Extract_Timeseries_bandpassed.bash
#Author: Ashley Parr
#Purpose: Script to extract timeseries across all ROIs outlined in Merge_atlases.bash (VMPFC, Striatal, VTA). 
#Directory: /Volumes/Phillips/mMR_PETDA/subjs 
# Log:
#   20190123WF - copy from Extract_Timeseries.bash, update to use bandpass regressed background


DATADIR=/Volumes/Phillips/mMR_PETDA/subjs
atlas=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/VMPFC_STRIATAL_VTA_ROIS_rsfunctemp.nii.gz
mask=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/Brain_Mask_GM_50thres_rsfunctemplate.nii.gz
outinfo=gs-wm-csf-6mot_vmpfc-striatal-vta
cd $DATADIR

echo "atlas: ${atlas}"
echo "mask: ${mask}"
echo "outinfo: ${outinfo}"
echo "pwd: $(pwd)"

# # setup running many jobs
# MAXJOBS=5
# WAITTIME=60
# source /opt/ni_tools/lncdshell/utils/waitforjobs.sh


for subj in $DATADIR/1*; do 
   # subject info
   sub_id=$(basename "$subj") 
   # skip if we already made
   outfile=$subj/background_connectivity/${sub_id}_${outinfo}_ts_adj.txt 
   outfilep=$subj/background_connectivity/${sub_id}_${outinfo}_ts_adj_pearson.txt 
   # [ -r "$outfile" ] && rm $outfile" # remove old (if we did something stupid, and need to redo)
   [ -r "$outfilep" ] && echo "# have $outfilep" && continue


   # check for files
   censor=$subj/merged_censor_union.1D
   input=$subj/background_connectivity/cbgnfswdktm_tent_resid.nii.gz 
   if [ ! -r "$censor" -o ! -r $input ]; then
      echo "# $subj_id: missing censor or input ($censor $input)" 
      continue
   fi

   # create adj matrix file
   echo "# ${sub_id}: $(date): generating $outfile"
   ROI_TempCorr.R \
      -ts $input \
      -rois $atlas \
      -out_file $outfile \
      -ts_out_file $censor \
      -roi_reduce mean -corr_method pearson -fisherz \
      -brainmask $mask \
      -censor $censor \
      -roi_diagnostics $subj/background_connectivity/${sub_id}_${outinfo}_roi_diagnostics.txt \
      -write_header 1 \
      -njobs 10
   echo "# ${sub_id}: $(date): made $outfile"
   #waitforjobs
done
wait
