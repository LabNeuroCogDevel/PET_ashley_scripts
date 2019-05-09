#!bin/bash

#Title: 3dLME_BG_Rest_completecases.bash
# Author: Ashley Parr
# Purpose: Run 3dLME with age (and other vars of interest) on seeded connectivity files from NAcc, Caudate, Putamen, VTA, etc.. This script is for complete
# cases, meaning those who have both readable background and rest ts files.
# Date: 04/26/2019

#Need to do separately for all conditions (seeds)
#So separate out the big table Will made into each ROI. 

#master_table= /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/master_conditionXcontext.txt
DATADIR=/Volumes/Phillips/mMR_PETDA/group_analysis_ashley
#conditions="R_NAcc L_NAcc VTA R_Caudate L_Caudate R_Putamen L_Putamen"
conditions="R_NAcc VTA"
cd $DATADIR

for condition in $conditions; do
   #Go through and create text files for each ROI separately. Commented out because already done in command line (this didn't work for some reason) 
   #  egrep '$condition|fdstat_funcmean' /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/master_conditionXcontext.txt > /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/$conditionXcontext.txt
   #e.g., 
   # egrep 'L_Putamen|fdstat_funcmean' /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/master_conditionXcontext.txt > /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/L_PutamenXcontext.txt

echo $condition
3dLME -prefix 3dLME_invage_$condition -jobs 20 \
-model "context*inv_age+fdstat_funcmean+visitnum" \
-ranEff '~1' \
-qVars "inv_age,fdstat_funcmean" \
-SS_type 3 \
-num_glt 5 \
-gltLabel 1 'BG' -gltCode 1 'context: 1*BG' \
-gltLabel 2 'RS' -gltCode 2 'context: 1*RS' \
-gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS' \
-gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
-gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
-dataTable @${condition}Xcontext.txt  

done
