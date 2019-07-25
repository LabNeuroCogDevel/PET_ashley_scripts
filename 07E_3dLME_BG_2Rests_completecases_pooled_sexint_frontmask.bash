#!bin/bash

#Title: 3dLME_BG_2Rests_completecases_pooled_sexint_mask_07.bash
# Author: Ashley Parr
# Purpose: Run 3dLME with age (and other vars of interest) on seeded connectivity files from NAcc, Caudate, Putamen, VTA, etc..Left and right seed ROIs collapsed and hemisphere included in LME. This table/analysis has both first and second resting state scans in it (previous analyses only had the first resting state)
#This script is for complete cases, meaning those who have both readable background and rest ts files.
# Date: created:04/26/2019 modified: 05/23/2019 to include frontal mask and sex as an interaction.

#Need to do separately for all conditions (seeds)
#So separate out the big table Will made into each ROI. 
scriptdir=$(pwd)
#gmthes=.5
#gmmask=$scriptdir/gm_p=${gmthes}_2.3mm.nii.gz
#if [ ! -r $gmmask ]; then
#   3dcalc -a ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii  -expr "step(a-$gmthes)" -prefix gmmask${thres}_1mm.nii.gz 
#exampleinput=/Volumes/Phillips/mMR_PETDA/subjs/10195_20160317/background_connectivity/cbgnfswdktm_tent_resid.nii.gz
#3dresample -master $exampleinput -inset gmmask${thres}_1mm.nii.gz -prefix $gmmask -rmode NN
#   fi
fmask=/Volumes/Hera/Projects/mMR_PETDA/atlases_ashley/Frontal/acp_front_ins_mni_rs.nii.gz
DATADIR=/Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley
conditions="NAcc Caudate Putamen"
cd $DATADIR
for condition in $conditions; do
   echo $condition

3dLME -prefix 3dLME_invage_sex_RS2_maineff_frontmask_$condition -jobs 20 \
   -mask $fmask \
   -model "context*inv_age*sex+fdstat_funcmean+hemi+visitnum" \
   -ranEff '~1+inv_age' \
   -qVars "inv_age,fdstat_funcmean" \
   -SS_type 3 \
   -num_glt 7 \
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : .5*RS1 -.5*RS2' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : +1*BG -.5*RS1 -.5*RS2' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : .5*RS1 +.5*RS2 inv_age :' \
   -gltLabel 6 'RS1-RS2' -gltCode 6 'context : +1*RS1 -1*RS2 inv_age' \
   -gltLabel 7 'inv_age' -gltCode 7 'inv_age' \
   -dataTable @${condition}Xcontext_RS2.txt

done
##
3dLME -prefix 3dLME_invage_sex_RS2_maineff_frontmask_VTA -jobs 20 \
   -mask $fmask
   -model "context*inv_age*sex+fdstat_funcmean+visitnum" \
   -ranEff '~1+inv_age' \
   -qVars "inv_age,fdstat_funcmean" \
   -SS_type 3 \
   -num_glt  8\
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : .5*RS1 -.5*RS2' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : +1*BG -.5*RS1 -.5*RS2' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \ 
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : .5*RS1 +.5*RS2 inv_age :' \
   -gltLabel 6 'RS1-RS2' -gltCode 6 'context : +1*RS1 -1*RS2 inv_age' \
   -gltLabel 7 'inv_age' -gltCode 7 'inv_age'\
   -dataTable @VTAXcontext_RS2.txt


   #-gltLabel 8 'sex' -gltCode 8 'sex' \
   #-gltLabel 9 'sex_BG' -gltCode 9 'context : 1*BG sex :' \
   #-gltLabel 10 'sex_RS' -gltCode 10 'context : .5*RS1 +.5*RS2 sex' \
