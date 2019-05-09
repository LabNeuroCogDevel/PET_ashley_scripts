#!bin/bash

#Title: 3dLME_BG_Rest_completecases_pooled_R2p.bash
# Author: Ashley Parr
# Purpose: Run 3dLME with R2p (and other vars of interest) on seeded connectivity files from NAcc, Caudate, Putamen, VTA, etc..Left and right seed ROIs collapsed and hemisphere included in LME.
#This script is for complete cases, meaning those who have both readable background and rest ts files.
# Date: created:05/02/2019

#Need to do separately for all conditions (seeds)
#So separate out the big table Will made into each ROI. 

#master_table= /Volumes/Phillips/mMR_PETDA/group_analysis_ashley/master_conditionXcontext.txt
DATADIR=/Volumes/Phillips/mMR_PETDA/group_analysis_ashley
conditions="NAcc Caudate Putamen"

# need to subset the table such that good_r2p==TRUE
cd $DATADIR
for condition in $conditions; do
echo $condition
# do your thing here to grep the rows in the table where good_r2p==TRUE
awk '(NR==1||$30=="TRUE"){print}' ${condition}Xcontext.txt > ${condition}Xcontext_r2p.txt
#awk -F, 'NR> 1 ($30=="TRUE"){print} || NR==1' ${condition}Xcontext.txt > ${condition}Xcontext_r2p.txt
#awk ' NR==1; NR>1 ($30=="TRUE"){print}' ${condition}Xcontext.txt > ${condition}Xcontext_r2p.txt
#break 

# save for each condition then do an if !r & continue thing so it doesn't recreate them every time I run it.
#get R2' for each ROI respectively
if [ $condition == 'NAcc' ]; then
   new_condition='accumbens'
elif [ $condition == 'Caudate' ]; then
   new_condition='caudate'
elif [ $condition == 'Putamen' ]; then
   new_condition='putamen'
fi

r2p=r2p_cic_${new_condition}
echo $r2p

3dLME -prefix 3dLME_R2p_invage_sex_$condition -jobs 20 \
   -model "context*inv_age*${r2p}+fdstat_funcmean+sex+hemi+visitnum" \
   -ranEff '~1' \
   -qVars "inv_age,fdstat_funcmean,${r2p}" \
   -SS_type 3 \
   -num_glt 7 \
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
   -gltLabel 6 'R2p_BG' -gltCode 6 'context : 1*BG r2p :' \
   -gltLabel 7 'R2p_RS' -gltCode 7 'context : 1*RS r2p :' \
   -dataTable ${condition}Xcontext_r2p.txt

3dLME -prefix 3dLME_R2p_invage_$condition -jobs 20 \
   -model "context*inv_age*${r2p}+fdstat_funcmean+hemi+visitnum" \
   -ranEff '~1' \
   -qVars "inv_age,fdstat_funcmean,${r2p}" \
   -SS_type 3 \
   -num_glt 7 \
   -gltLabel 1 'BG' -gltCode 1 'context : 1*BG' \
   -gltLabel 2 'RS' -gltCode 2 'context : 1*RS' \
   -gltLabel 3 'BG-RS' -gltCode 3 'context : 1*BG -1*RS' \
   -gltLabel 4 'Inv_Age_BG' -gltCode 4 'context : 1*BG inv_age :' \
   -gltLabel 5 'Inv_Age_RS' -gltCode 5 'context : 1*RS inv_age :' \
   -gltLabel 6 'R2p_BG' -gltCode 6 'context : 1*BG r2p :' \
   -gltLabel 7 'R2p_RS' -gltCode 7 'context : 1*RS r2p :' \
   -dataTable ${condition}Xcontext_r2p.txt

done
