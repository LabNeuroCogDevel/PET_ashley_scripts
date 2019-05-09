#!bin/bash

#Title: 3dLME_BG_Rest_completecases_pooled.bash
# Author: Ashley Parr
# Purpose: Run 3dLME with age (and other vars of interest) on seeded connectivity files from NAcc, Caudate, Putamen, VTA, etc..Left and right seed ROIs collapsed and hemisphere included in LME.
#This script is for complete cases, meaning those who have both readable background and rest ts files.
# Date: created:04/26/2019 modified: 04/29/2019

#Need to do separately for all conditions (seeds)
#So separate out the big table Will made into each ROI. 

#master_table= /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/master_conditionXcontext.txt
DATADIR=/Volumes/Phillips/mMR_PETDA/group_analysis_ashley
#conditions="NAcc Caudate Putamen"
conditions="VTA"
cd $DATADIR
for condition in $conditions; do
   #Go through and create text files for each ROI separately but include header. Hacked it so that fdstat_funcmean was found which is only in the header.
   #Commented out because already done in command line (this didn't work for some reason) 
   #egrep '$condition|fdstat_funcmean' /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/master_conditionXcontext_hemi.txt >\
      #/Volumes/Phillips/mMR_PETDA/group_analysis_ashley/${condition}Xcontext.txt
   #e.g., 
   #egrep 'VTA|fdstat_funcmean' /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/master_conditionXcontext_hemi.txt >\
      #/Volumes/Phillips/mMR_PETDA/group_analysis_ashley/VTAXcontext.txt

echo $condition

#3dLME -prefix 3dLME_invage_sex_no_vnum$condition -jobs 20 \
#   -model "context*inv_age+fdstat_funcmean+hemi+sex" \
#   -ranEff '~1' \
#   -qVars "inv_age,fdstat_funcmean" \
#   -SS_type 3 \
#   -num_glt 5 \
#   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
#   -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
#   -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS' \
#   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
#   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
#   -dataTable @${condition}Xcontext.txt  
#

3dLME -prefix 3dLME_invage_sex_V1_$condition -jobs 20 \
   -model "context*inv_age+fdstat_funcmean+sex" \
   -ranEff '~1' \
   -qVars "inv_age,fdstat_funcmean" \
   -SS_type 3 \
   -num_glt 5 \
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
   -dataTable @V1_${condition}Xcontext.txt

3dLME -prefix 3dLME_invage_V1_$condition -jobs 20 \
   -model "context*inv_age+fdstat_funcmean" \
   -ranEff '~1' \
   -qVars "inv_age,fdstat_funcmean" \
   -SS_type 3 \
   -num_glt 5 \
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
   -dataTable @V1_${condition}Xcontext.txt

 #  3dLME -prefix 3dLME_invage_sex_$condition -jobs 20 \
 #  -model "context*inv_age+fdstat_funcmean+hemi+sex+visitnum" \
 #  -ranEff '~1' \
 #  -qVars "inv_age,fdstat_funcmean" \
 #  -SS_type 3 \
 #  -num_glt 5 \
 #  -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
 #  -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
 #  -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS' \
 #  -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
 #  -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
 #  -dataTable @${condition}Xcontext.txt
 #  
#3dLME -prefix 3dLME_invage_$condition -jobs 20 \
#   -model "context*inv_age+fdstat_funcmean+hemi+visitnum" \
#   -ranEff '~1' \
#   -qVars "inv_age,fdstat_funcmean" \
#   -SS_type 3 \
#   -num_glt 5 \
#   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
#   -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
#   -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS' \
#   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
#   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
#   -dataTable @${condition}Xcontext.txt
#
   #if doing for VTA so exclude hemi
#3dLME -prefix 3dLME_invage_sex_$condition -jobs 20 \
#   -model "context*inv_age+fdstat_funcmean+sex+visitnum" \
#   -ranEff '~1' \
#   -qVars "inv_age,fdstat_funcmean" \
#   -SS_type 3 \
#   -num_glt 5 \
#   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
#   -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
#   -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS'\
#   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
#   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
#   -dataTable @${condition}Xcontext.txt
#
#3dLME -prefix 3dLME_invage_sex_no_vnum$condition -jobs 20 \
#   -model "context*inv_age+fdstat_funcmean+sex" \
#   -ranEff '~1' \
#   -qVars "inv_age,fdstat_funcmean" \
#   -SS_type 3 \
#   -num_glt 5 \
#   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
#   -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
#   -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS'\
#   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
#   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
#   -dataTable @${condition}Xcontext.txt
#
#3dLME -prefix 3dLME_invage_$condition -jobs 20 \
#   -model "context*inv_age+fdstat_funcmean+visitnum" \
#   -ranEff '~1' \
#   -qVars "inv_age,fdstat_funcmean" \
#   -SS_type 3 \
#   -num_glt 5 \
#   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
#   -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
#   -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS'\
#   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
#   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
#   -dataTable @${condition}Xcontext.txt
#
#If wanting to add RS2 and test difference between RS scans, include in model 

#3dLME -prefix 3dLME_invage_$condition -jobs 20 \
#-model "context*inv_age+fdstat_funcmean+hemi+visitnum" \
#-ranEff '~1' \
#-qVars "inv_age,fdstat_funcmean" \
#-SS_type 3 \
#-num_glt 5 \
#-qVars "inv_age,fdstat_funcmean" \
#-SS_type 3 \
#-num_glt 5 \
#-gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
#-gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
#-gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS' \
#-gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
#-gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
#-gltLabel 6 'RS1-RS2' -gltCode 6 'rest : .5*RS1 -.5*RS2' \
#-gltLabel 7 'BG-RS12' -gltCode 7 'context: .5*RS1 -.5*RS2 -1*BG' \
#-dataTable @${condition}Xcontext.txt  
#
done
