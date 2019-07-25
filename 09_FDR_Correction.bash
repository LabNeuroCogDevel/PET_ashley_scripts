#!/bin/bash

#Title: FDR_Correction
#Author: Ashley Parr
#Purpose: Do FDR correction on group LME maps
#Date created: 05/14/2019

# Get GM mask

scriptdir=$(pwd)
gmthes=.5
gmmask=$scriptdir/gm_p=${gmthes}_2.3mm.nii.gz
if [ ! -r $gmmask ]; then
3dcalc -a ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii  -expr "step(a-$gmthes)" -prefix gmmask${thres}_1mm.nii.gz
exampleinput=/Volumes/Phillips/mMR_PETDA/subjs/10195_20160317/background_connectivity/cbgnfswdktm_tent_resid.nii.gz
3dresample -master $exampleinput -inset gmmask${thres}_1mm.nii.gz -prefix $gmmask -rmode NN
fi

DATADIR=/Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley
cd $DATADIR

conditions="NAcc Caudate Putamen"
for condition in $conditions; do
echo $condition

   3dFDR -input 3dLME_invage_RS2_maineff_${condition}+tlrc.HEAD \
   -mask $gmmask -list -prefix FDR_Corr_3dLME_invage_RS2_maineff_${condition} 
done
