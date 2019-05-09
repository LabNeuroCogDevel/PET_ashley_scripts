#!/bin/bash

#Title: Extract_Timeseries.bash
#Author: Ashley Parr
#Purpose: Script to extract timeseries across all ROIs outlined in Merge_atlases.bash (VMPFC, Striatal, VTA). 
#Directory: /Volumes/Phillips/mMR_PETDA/subjs 
# 04/26/2019 updated such that it skips over files that are already created and only does those that aren't there! 

DATADIR=/Volumes/Phillips/mMR_PETDA/subjs
#ROIDIR=/Volumes/Phillips/mMR_PETDA/atlas/Ashley
#cd $ROIDIR
#pwd
atlas=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/VMPFC_STRIATAL_VTA_ROIS_rsfunctemp.nii.gz
echo ${atlas}
mask=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/Brain_Mask_GM_50thres_rsfunctemplate.nii.gz
echo ${mask}
cd $DATADIR
pwd


for subj in $DATADIR/1*; do 
   echo $subj
 sub_id=$(basename "$subj") 
echo ${sub_id}
  
#skip if we already have the ts_out_file so it doesn't redo
#[ ! -r $subj/func/${sub_id}_vmpfc_striatal_vta_ts.txt ] &&
   #Skip if we don't have censor file
  if [[ -r $subj/merged_censor_union.1D && -r $subj/background_connectivity/cbnfswdktm_tent_resid.nii.gz ]]; 
     then
        echo "both exist" 
     else
        echo "one or more relevant files missing" && continue
     fi

   [ ! -r $subj/func/${sub_id}_vmpfc_striatal_vta_ts.txt ] &&
   #Skip if we don't have censor file
     ROI_TempCorr.R \
      -njobs 20 \
      -ts $subj/background_connectivity/cbnfswdktm_tent_resid.nii.gz \
      -rois $atlas \
      -out_file $subj/func/${sub_id}_vmpfc_striatal_vta_ts_adj.txt \
      -ts_out_file $subj/func/${sub_id}_vmpfc_striatal_vta_ts.txt \
      -roi_reduce mean -corr_method pearson -fisherz \
      -brainmask $mask \
      -censor $subj/merged_censor_union.1D \
      #-roi_diagnostics $subj/func/${sub_id}_roi_diagnostics.txt \
      -write_header 1 \
     # -overwrite
 echo $subj
  done
  # cd $subj/func
  # echo $(pwd) 
  # out_file=$subj/func/${subj}_vmpfc_striatal_vta_ts_adj.txt
  # tsoutfile=$subj/func/${subj}_vmpfc_striatal_vta_ts.txt
  #func_file=$subj/func/cbnfswdktm_tent_resid.nii.gz
  
  # echo ${func_file}
   #Skip if we don't have input file 
  # [ -r $subj/func/cbnfswdktm_tent_resid.nii.gz ] && continue
  # [ ! -r $subj/func/cbnfswdktm_tent_resid.nii.gz ] && echo "$subj/func/cbnfswdktm_tent_resid.nii.gz does not exist" && continue
   #Skip if we alrady have a matrix
   #[ -r $subj/func/$outfile ] && continue


#   echo "###"
  # echo $(pwd) 
  # echo ${sub_id}
#break

  # ROI_TempCorr.R \
  #    -ts $func_file \
  #    -rois $atlas \
  #    -out_files $subj/func/${subj}_vmpfc_striatal_vta_ts_adj.txt \
  #    -ts_out_file $subj/func/${subj}_vmpfc_striatal_vta_ts.txt \
  #    -roi_reduce mean -corr_method pearson -fisherz \
  #    -brainmask $mask \
  #    -censor $censor_file \
  #    -roi_diagnostics $subj/func/${sub_id}_roi_diagnostics.txt \
  #    -write_header 1

  # echo $subj
#done



