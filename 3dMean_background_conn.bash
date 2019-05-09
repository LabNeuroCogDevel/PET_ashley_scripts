#!/bin/bash

#Title: 3dMean_background_conn
#Author: Ashley Parr
#Purpose: Get a mean group map of connectivity in the background condition. 
#Date: 04/23/2019

#Need to grab files from only those subs who have both RS and background ts files. 
#Also need to only pull out visit 1 data.  

BG_DATADIR=/Volumes/Phillips/mMR_PETDA/subjs
RS_DATADIR=/Volumes/Zeus/preproc/petrest_rac*/MHRest_FM_ica
SAVEDIR=/Volumes/Phillips/mMR_PETDA/group_analysis_ashley
conditions="R_NAcc L_NAcc VTA R_Caudate L_Caudate R_Putamen L_Putamen"
#context="Background Rest"
# under construction, just did a quick mean for now. In the future, I believe I should be grabbing only those people who have both background and rest files, but for now this is OK. 
#for subj in $BG_DIR/1*; do
   for condition in $conditions; do
#   sub_id=$(basename "$subj")
#   bg_file=$subj/background_connectivity/${sub_id}_${condition}_REML_r_Z+tlrc.BRIK.gz
#   rs_file=$RS_DATADIR/$subj/${sub_id}_${condition}_REML_r_Z+tlrc.BRIK.gz
   
#   echo $subj $sub_id $condition
#   if [[ -r $bg_file || -r $rs_file]]
#   then
#      echo "both background and rest REML files exist"
#   else
#      echo "either background or rest REML file is missing"
#      echo "missing $subj/background_connectivity/*_${condition}_REML_r_Z+tlrc.BRIK.gz or $RS_DATADIR/$subj/*_${condition}_REML_r_Z+tlrc.BRIK.gz "
#      continue
#   fi

   
   #3dMean -prefix $SAVEDIR/group_${condition}_background_conn_REML_r_Z \
   #$BG_DATADIR/*/background_connectivity/*_${condition}_REML_r_Z+tlrc.BRIK.gz -overwrite 
   
   #3dMean -prefix $SAVEDIR/group_${condition}_rest_conn_REML_r_Z \
   #$RS_DATADIR/*/*_${condition}_REML_r_Z+tlrc.BRIK.gz -overwrite

   3dMean -prefix $SAVEDIR/group_${condition}_background_conn_r_Z \
   $BG_DATADIR/*/background_connectivity/*_${condition}_r_Z+tlrc.BRIK.gz -overwrite

   3dMean -prefix $SAVEDIR/group_${condition}_rest_conn_r_Z $RS_DATADIR/*/*_${condition}_r_Z+tlrc.BRIK.gz -overwrite 
done
# in the end, I want it to take the sub_id for those subs who have both files and put it into a text file as first column so I can use it as an index to get the rest of what I need from the database (e.g., Age, gender, R2', pet indices). 


