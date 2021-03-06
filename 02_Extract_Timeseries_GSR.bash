#!/bin/bash
set -euo pipefail
#Title: Extract_Timeseries.bash
#Author: Ashley Parr
#Purpose: Script to extract timeseries across all ROIs outlined in Merge_atlases.bash (VMPFC, Striatal, VTA). 
#Directory: /Volumes/Phillips/mMR_PETDA/subjs 
# 04/26/2019 updated such that it skips over files that are already created and only does those that aren't there! 

DATADIR=/Volumes/Hera/Projects/mMR_PETDA/subjs
#ROIDIR=/Volumes/Phillips/mMR_PETDA/atlas/Ashley
#cd $ROIDIR
#pwd
atlas=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/VMPFC_STRIATAL_VTA_ROIS_rsfunctemp.nii.gz
echo ${atlas}
mask=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/Brain_Mask_GM_50thres_rsfunctemplate.nii.gz
echo ${mask}
cd $DATADIR
pwd
#subjs="10195_20160317"
#for subj in $subjs; do
for subj in $DATADIR/1*; do

   echo $subj
   sub_id=$(basename "$subj") 
   echo ${sub_id}

   censor=$subj/merged_censor_union.1D
   [ ! -r $censor ] && echo "cannot find $censor; skipping" && continue

   ts_file=$subj/background_connectivity/cbgnfswdktm_tent_resid.nii.gz
   [ ! -r $ts_file ] && echo "cannot find $ts_file; skipping" && continue

   #[[ ! -r $censor && ! -r $ts_file ]] && echo "cannot find $censor and/or $ts_file; skipping" && continue
   #These tsoutfiles are all on PHILLIPS right now in the func folder 
   subj_phil=${subj/Hera\/Projects/Phillips}
   tsoutfile_p=$subj_phil/func/${sub_id}_vmpfc_striatal_vta_mean_gsr_ts.txt
   adjoutfile_p=$subj_phil/func/${sub_id}_vmpfc_striatal_vta_mean_gsr_pearson_adj.txt
   
   tsoutfile=$subj/func/${sub_id}_vmpfc_striatal_vta_mean_gsr_ts.txt
   adjoutfile=$subj/func/${sub_id}_vmpfc_striatal_vta_mean_gsr_pearson_adj_pearson.txt

   echo $sub_id
   [ -r $tsoutfile_p -a ! -r $tsoutfile ] && cp $tsoutfile_p $tsoutfile
   [ -r $adjoutfile_p -a ! -r $adjoutfile ] && cp $adjoutfile_p $adjoutfile
   [ -r $adjoutfile ] && echo "final file ($adjoutfile) already done; skipping" && continue
   #[ -r $tsoutfile ] && echo "have ts but not final $tsoutfile" && continue
   echo "missing $adjoutfile, running"
   set -x
   
   #these files are stupidly being saved as "${sub_id}_vmpfc_striatal_vta_mean_gsr_pearson_adj_pearson.txt??? 
   # 10195_20160317_vmpfc_striatal_vta_mean_gsr_pearson_adj_pearson.txt 
   # 10195_20160317_vmpfc_striatal_vta_mean_gsr_ts.txt
   #want something that says if found on Phillips, skip BUT send files over to HERA. And if not found on Phillips, just create files on HERA. 
   
   ROI_TempCorr.R \
      -ts $ts_file \
      -rois $atlas \
      -out_file ${adjoutfile/_pearson.txt}.txt \
      -ts_out_file $tsoutfile \
      -roi_reduce mean -corr_method pearson -fisherz \
      -brainmask $mask \
      -censor $censor \
      -write_header 1
   set +x
done 


##skip if we dont' have the censor file or the tent resid file. 
#if [[ -r $subj/merged_censor_union.1D && -r $subj/background_connectivity/cbgnfswdktm_tent_resid.nii.gz ]]; 
#     then
#        echo "both exist" 
#     else
#        echo "one or more relevant files missing" && continue
#     fi

##   [  -r $subj/func/${sub_id}_vmpfc_striatal_vta_mean_gsr_ts.txt ] &&

#     ROI_TempCorr.R \
#      -njobs 20 \
#      -ts $subj/background_connectivity/cbgnfswdktm_tent_resid.nii.gz \
#      -rois $atlas \
#      -out_file $subj/func/${sub_id}_vmpfc_striatal_vta_mean_gsr_ts_adj.txt \
#      -ts_out_file $subj/func/${sub_id}_vmpfc_striatal_vta_mean_gsr_ts.txt \
#      -roi_reduce mean -corr_method pearson -fisherz \
#      -brainmask $mask \
#      -censor $subj/merged_censor_union.1D \
#      -write_header 1
# echo $subj
#  done
#  # cd $subj/func
#  # echo $(pwd) 
#  # out_file=$subj/func/${subj}_vmpfc_striatal_vta_ts_adj.txt
#  # tsoutfile=$subj/func/${subj}_vmpfc_striatal_vta_ts.txt
#  #func_file=$subj/func/cbnfswdktm_tent_resid.nii.gz

#  # echo ${func_file}
#   #Skip if we don't have input file 
#  # [ -r $subj/func/cbnfswdktm_tent_resid.nii.gz ] && continue
#  # [ ! -r $subj/func/cbnfswdktm_tent_resid.nii.gz ] && echo "$subj/func/cbnfswdktm_tent_resid.nii.gz does not exist" && continue
#   #Skip if we alrady have a matrix
#   #[ -r $subj/func/$outfile ] && continue


##   echo "###"
#  # echo $(pwd) 
#  # echo ${sub_id}
##break

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



