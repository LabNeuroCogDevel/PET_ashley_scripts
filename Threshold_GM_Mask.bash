#!/bin/bash

#Title: Threshold_GM_Mask.bash
#Author: Ashley Parr
#Purpose: none other then to treshold a grey matter brain mask 
#Directory of grey matter mask: /opt/ni_tools/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c_2.3mm.nii

MASK_DIR=/Volumes/Phillips/mMR_PETDA/atlas/Ashley
cd $MASK_DIR
#prob_mask=mni_icbm152_gm_tal_nlin_asym_09c_2_3mm.nii
#thres=0.5 

3dcalc -a mni_icbm152_gm_tal_nlin_asym_09c_2_3mm.nii \
  -expr 'step(a-0.5)' \
  -prefix Brain_Mask_GM_50thres.nii

#Have to resample to be in same dims as my functional data and brain atlas 
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix Brain_Mask_GM_50thres_rsfunctemplate.nii.gz -inset Brain_Mask_GM_50thres.nii.gz 
