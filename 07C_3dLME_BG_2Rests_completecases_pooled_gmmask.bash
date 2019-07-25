#!bin/bash

#Title: 3dLME_BG_2Rests_completecases_pooled_mask_07.bash
# Author: Ashley Parr
# Purpose: Run 3dLME with age (and other vars of interest) on seeded connectivity files from NAcc, Caudate, Putamen, VTA, etc..Left and right seed ROIs collapsed and hemisphere included in LME. This table/analysis has both first and second resting state scans in it (previous analyses only had the first resting state)
#This script is for complete cases, meaning those who have both readable background and rest ts files.
# Date: created:04/26/2019 modified: 05/21/2019 to include grey matter mask

#Need to do separately for all conditions (seeds)
#So separate out the big table Will made into each ROI. 
scriptdir=$(pwd)
gmthes=.5
gmmask=$scriptdir/gm_p=${gmthes}_2.3mm.nii.gz
if [ ! -r $gmmask ]; then
   3dcalc -a ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii  -expr "step(a-$gmthes)" -prefix gmmask${thres}_1mm.nii.gz 
exampleinput=/Volumes/Phillips/mMR_PETDA/subjs/10195_20160317/background_connectivity/cbgnfswdktm_tent_resid.nii.gz
3dresample -master $exampleinput -inset gmmask${thres}_1mm.nii.gz -prefix $gmmask -rmode NN
   fi
   
   #master_table= /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/master_conditionXcontext.txt
#DATADIR=/Volumes/Phillips/mMR_PETDA/group_analysis_ashley
DATADIR=/Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley
#mask=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/VMPFC_ROIS_rsfunctemp_may.nii.gz
conditions="Caudate Putamen"
#conditions="NAcc"
cd $DATADIR
for condition in $conditions; do
#   #Go through and create text files for each ROI separately but include header. Hacked it so that fdstat_funcmean was found which is only in the header.
#   #Commented out because already done in command line (this didn't work for some reason) 
#   #egrep '$condition|fdstat_funcmean' /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/master_conditionXcontext_hemi_R2.txt >\
#      #/Volumes/Phillips/mMR_PETDA/group_analysis_ashley/${condition}Xcontext_RS2.txt
#
   echo $condition

3dLME -prefix 3dLME_invage_RS2_maineff_gmmask_$condition -jobs 20 \
   -mask $gmmask \
   -model "context*inv_age+fdstat_funcmean+hemi+visitnum" \
   -ranEff '~1' \
   -qVars "inv_age,fdstat_funcmean" \
   -SS_type 3 \
   -num_glt 7 \
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : .5*RS1 -.5*RS2' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : +1*BG -.5*RS1 -.5*RS2' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : .5*RS1 +.5*RS2 inv_age :' \
   -gltLabel 6 'RS1-RS2' -gltCode 6 'context : +1*RS1 -1*RS2 inv_age'\
   -gltLabel 7 'inv_age' -gltCode 7 'inv_age' \
   -dataTable @${condition}Xcontext_RS2.txt

3dLME -prefix 3dLME_invage_sex_RS2_maineff_gmmask_$condition -jobs 20 \
   -mask $gmmask \
   -model "context*inv_age+fdstat_funcmean+hemi+sex+visitnum" \
   -ranEff '~1' \
   -qVars "inv_age,fdstat_funcmean" \
   -SS_type 3 \
   -num_glt 10 \
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : .5*RS1 -.5*RS2' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : +1*BG -.5*RS1 -.5*RS2' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : .5*RS1 +.5*RS2 inv_age :' \
   -gltLabel 6 'RS1-RS2' -gltCode 6 'context : +1*RS1 -1*RS2 inv_age' \
   -gltLabel 7 'inv_age' -gltCode 7 'inv_age' \
   -dataTable @${condition}Xcontext_RS2.txt

done
#
# Do VTA outside the loop because the model is different and doesn't include hemi
3dLME -prefix 3dLME_invage_RS2_maineff_VTA -jobs 20 \
   -mask $gmmask \
   -model "context*inv_age+fdstat_funcmean+visitnum" \
   -ranEff '~1' \
   -qVars "inv_age,fdstat_funcmean" \
   -SS_type 3 \
   -num_glt 7 \
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : .5*RS1 -.5*RS2' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : +1*BG -.5*RS1 -.5*RS2' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : .5*RS1 +.5*RS2 inv_age :' \
   -gltLabel 6 'RS1-RS2' -gltCode 6 'context : +1*RS1 -1*RS2 inv_age' \
   -gltLabel 7 'inv_age' -gltCode 7 'inv_age'\
   -dataTable @VTAXcontext_RS2.txt
##
##
3dLME -prefix 3dLME_invage_sex_RS2_maineff_VTA -jobs 20 \
   -mask $gmmask
   -model "context*inv_age+fdstat_funcmean+sex+visitnum" \
   -ranEff '~1' \
   -qVars "inv_age,fdstat_funcmean" \
   -SS_type 3 \
   -num_glt 7 \
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : .5*RS1 -.5*RS2' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : +1*BG -.5*RS1 -.5*RS2' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \ 
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : .5*RS1 +.5*RS2 inv_age :' \
   -gltLabel 6 'RS1-RS2' -gltCode 6 'context : +1*RS1 -1*RS2 inv_age' \
   -gltLabel 7 'inv_age' -gltCode 7 'inv_age'\
   -dataTable @VTAXcontext_RS2.txt
