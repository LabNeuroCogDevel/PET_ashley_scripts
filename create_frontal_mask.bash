#!/bin/bash
#Title: create_frontal_mask.bash
#Purpose: Create frontal mask. 
#Created by: Started by BTC, modified by ACP
#Date: 05/22/2019
scriptdir=$(pwd)
NEWDIR=/Volumes/Hera/Projects/mMR_PETDA/atlases_ashley/Frontal
ATLASDIR=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/Frontal
cd $ATLASDIR

#TYPE THIS INTO COMMAND LINE TO GET COMPLETE LIST OF ROIS IN THE MASK, AS WELL AS THEIR VALUES SO YOU CAN INPUT THEM BELOW. 
#/Volumes/Phillips/mMR_PETDA/atlas/HarvardOxford_subcortical_atlas_mni_space/roi_label_xyz.tsv

#BRENDEN'S FORMULA:
#3dcalc -a /usr/share/afni/atlases//MNIa_caez_ml_18+tlrc -expr 'amongst(a,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,19,20,24,23,25,26,27,28,31,32,150,193,125,118,174,131,134,186,119,188,167,142)'\
#   -prefix $ATLASDIR/btc_front_mask.nii.gz -overwrite

#his didn't include the middle cingulate so there was a chunk out of it - here, I include it. 
#3dcalc -a /usr/share/afni/atlases//MNIa_caez_ml_18+tlrc -expr 'amongst(a,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,19,20,24,23,25,26,27,28,31,32,33,34,150,193,125,118,174,131,134,186,119,188,167,142)'\
#   -prefix $ATLASDIR/btc_front_mask_inc_midcing.nii.gz -overwrite


#BUT THE INPUT ATLAS ONLY HAS N=115 ROIS, NOT SURE WHY HIS NUMBERS GO INTO THE 140-S UNLESS HE WAS USING THE 152 ORIGINALLY. I WILL TRY USING THE MNIa_caez_ml_18 (CA_ML_18_MNIA)
y_max=36 #I've included the middle cingulate, but want to cut it off beyond the precentral sulcus. Which ends up being a cutoff of y=36 on both sides. 
#leftsidemax=36
#rightsidemax=36
#xyexpr="ispositive( ispositive($leftsidemax-y)*ispositive(x) + ispositive($rightsidemax-y)*ispositive(-x) )"


xyexpr="ispositive($y_max-y)"

#[ -r acp_front_mask_inc_midcing.nii.gz ] && echo "have acp_front_mask_inc_midcing, skipping" && continue 

#3dcalc -a /usr/share/afni/atlases//MNIa_caez_ml_18+tlrc -expr 'amongst(a,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,19,20,23,24,25,26,27,28,31,32,33,34)'\
#   -prefix $NEWDIR/acp_front_mask_inc_midcing.nii.gz -overwrite #this is the mask without the cutoff at y=36


3dcalc -a /usr/share/afni/atlases//MNIa_caez_ml_18+tlrc -expr 'amongst(a,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,19,20,23,24,25,26,27,28,29,30,31,32,33,34)'\
   -prefix $NEWDIR/acp_front_mask_inc_midcing_ins.nii.gz -overwrite #this is the mask without the cutoff at y=36


#[ -r acp_front_mask_inc_midcing_ycutoff36mm.nii.gz ] && echo "have acp_front_mask_inc_midcing_ycutoff36mm, skipping" && continue 

#3dcalc -a /usr/share/afni/atlases//MNIa_caez_ml_18+tlrc -expr "amongst(a,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,19,20,23,24,25,26,27,28,31,32,33,34)*$xyexpr"\
#   -prefix $NEWDIR/acp_front_mask_inc_midcing_ycutoff36mm.nii.gz -overwrite #This is the mask with cutoff at y=36


3dcalc -a /usr/share/afni/atlases//MNIa_caez_ml_18+tlrc -expr "amongst(a,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,19,20,23,24,25,26,27,28,29,30,31,32,33,34)*$xyexpr"\
   -prefix $NEWDIR/acp_front_mask_inc_midcing_ins_ycutoff36mm.nii.gz -overwrite #This is the mask with cutoff at y=36


#[ -r acp_front_mask_excl_midcing.nii.gz ] && echo "have acp_front_mask_excl_midcing, skipping" && continue 

#3dcalc -a /usr/share/afni/atlases//MNIa_caez_ml_18+tlrc -expr "amongst(a,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,19,20,23,24,25,26,27,28,31,32)*$xyexpr"\
#   -prefix $NEWDIR/acp_front_mask_excl_midcing.nii.gz -overwrite

#Need to warp from MNIA to MNI (all my data is in MNI)
#cd $scriptdir

#flirt -in $scriptdir/MNIa_caez_colin27_T1_18.nii.gz -ref $scriptdir/MNI_caez_N27.nii.gz -omat $scriptdir/MNIA_to_MNI.mat\
#   -out $NEWDIR/MNIA_in_MNI_caez.nii.gz

#flirt -interp nearestneighbour -in $NEWDIR/acp_front_mask_inc_midcing_ycutoff36mm.nii.gz -ref $scriptdir/MNI_caez_N27.nii.gz -applyxfm\
#   -init $scriptdir/MNIA_to_MNI.mat -out $NEWDIR/acp_front_mni.nii.gz 


flirt -interp nearestneighbour -in $NEWDIR/acp_front_mask_inc_midcing_ins_ycutoff36mm.nii.gz -ref $scriptdir/MNI_caez_N27.nii.gz -applyxfm\
   -init $scriptdir/MNIA_to_MNI.mat -out $NEWDIR/acp_front_ins_mni.nii.gz -overwrite 


#3dinfill -input $NEWDIR/acp_front_mni.nii.gz -prefix $NEWDIR/acp_front_mni_filled.nii.gz -blend SOLID
3dinfill -input $NEWDIR/acp_front_ins_mni.nii.gz -prefix $NEWDIR/acp_front_ins_mni_filled.nii.gz -overwrite

#3dresample -master /Volumes/Hera/Projects/mMR_PETDA/atlases_ashley/cbnfswdktm_tent_resid.nii.gz -prefix $NEWDIR/acp_front_mni_rs.nii.gz\
#   -inset $NEWDIR/acp_front_mni.nii.gz

3dresample -master /Volumes/Hera/Projects/mMR_PETDA/atlases_ashley/cbnfswdktm_tent_resid.nii.gz -prefix $NEWDIR/acp_front_ins_mni_rs.nii.gz\
   -inset $NEWDIR/acp_front_ins_mni.nii.gz -overwrite

#consider incluing: 29, 30 - insular cortices, only half of which fall before the precentral gyrus (1&2)
#consider excluding: 33&34 are questionable inclusions- it is the middle cingulate, only half of which fall before the precentral gyrus (1&2)

#Then transform into proper template space & resample
#is: MNI_ANAT 1mm 
#needs to be: MNI 2.3mm 
#3drefit for MNI_ANAT to MNI space? 

#3dresample -master /Volumes/Phillips/mMR_PETDA/atlas/Ashley/cbnfswdktm_tent_resid.nii.gz -prefix acp_front_mni_rs.nii.gz -inset acp_front_mni.nii.gz
#3dresample -master /Volumes/Phillips/mMR_PETDA/atlas/Ashley/cbnfswdktm_tent_resid.nii.gz -prefix acp_front_mask_inc_midcing_ycutoff36mm_rs.nii.gz -inset acp_front_mask_inc_midcing_ycutoff36mm.nii.gz
