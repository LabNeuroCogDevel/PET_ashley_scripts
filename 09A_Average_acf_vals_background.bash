#!/bin/bash

#Title: Average_acf_vals_background_09a.bash
#Author: Ashley Parr
#Purpose: Average the acf values across subs then ROIs from 3dfWHM scripts.
#need to get a mean of the values across participants and ROIs before it goes into 3dClustsim. 
#Created: 05/21/2019

#MAXJOBS=20
#WAITTIME=60
#source /opt/ni_tools/lncdshell/utils/waitforjobs.sh
#set -euo pipefail

#GM MASK
#scriptdir=$(pwd)
#gmthes=.5
#gmmask=$scriptdir/gm_p=${gmthes}_2.3mm.nii.gz

#if [ ! -r $gmmask ]; then
#   3dcalc -a ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii  -expr "step(a-$gmthes)" -prefix gmmask${thres}_1mm.nii.gz
#   exampleinput=/Volumes/Phillips/mMR_PETDA/subjs/10195_20160317/background_connectivity/cbgnfswdktm_tent_resid.nii.gz
#   3dresample -master $exampleinput -inset gmmask${thres}_1mm.nii.gz -prefix $gmmask -rmode NN
#fi
DATADIR=/Volumes/Hera/Projects/mMR_PETDA/subjs
cd $DATADIR
SAVEDIR=/Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley

conditions="R_NAcc L_NAcc VTA R_Caudate L_Caudate R_Putamen L_Putamen" 
for condition in $conditions; do
   finalfile=$SAVEDIR/Mean_GC_acf_${condition}_background.txt
   echo $condition
   [ -r $finalfile ] &&  echo "Final file exists; skipping" && continue

   cat $DATADIR/*/background_connectivity/*_GC_acf_${condition}.txt | datamash mean 1 mean 2 mean 3 mean 4 -W \
   > $SAVEDIR/Mean_GC_acf_${condition}_background.txt

done

#Average L/R (numbers are very simiar)
mconditions="NAcc Caudate Putamen"
for condition in $mconditions; do 
   finalfile2=$SAVEDIR/Mean_GC_acf_${condition}_background.txt
   echo $condition
   [ -r $finalfile2 ] && echo "Final file exists; skipping" && continue 
   
   cat $SAVEDIR/Mean_GC_acf_*_${condition}_background.txt | datamash mean 1 mean 2 mean 3 mean 4 -W \
      > $SAVEDIR/Mean_GC_acf_${condition}_background.txt
done

#Average across ALL STRIATAL  ROIs (again, numbers are very similar) 
finalfile3=$SAVEDIR/Mean_GC_acf_allROIs_background.txt
[ -r $finalfile3 ] && echo "All ROI mean file exists: skipping"

cat $SAVEDIR/Mean_GC_acf_NAcc_background.txt $SAVEDIR/Mean_GC_acf_Putamen_background.txt $SAVEDIR/Mean_GC_acf_Caudate_background.txt \
   | datamash mean 1 mean 2 mean 3 mean 4 -W > $SAVEDIR/Mean_GC_acf_allROIs_background.txt

