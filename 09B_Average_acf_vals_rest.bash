#!/bin/bash

#Title: Average_acf_vals_rest_09b.bash
#Author: Ashley Parr
#Purpose: Average the acf values across subs then ROIs from 3dfWHM scripts.
#need to get a mean of the values across participants and ROIs before it goes into 3dClustsim. 
#Created: 05/21/2019
DATADIR1=/Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica
DATADIR2=/Volumes/Zeus/preproc/petrest_rac2/MHRest_FM_ica

SAVEDIR=/Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley

conditions="R_NAcc L_NAcc VTA R_Caudate L_Caudate R_Putamen L_Putamen" 
for condition in $conditions; do
   finalfile_rs1=$SAVEDIR/Mean_GC_acf_${condition}_rest1.txt

   echo $condition
   [ -r $finalfile_rs1 ] &&  echo "Final file rest 1 exists; skipping" && continue

   cat $DATADIR1/*/*_GC_acf_${condition}.txt | datamash mean 1 mean 2 mean 3 mean 4 -W \
   > $SAVEDIR/Mean_GC_acf_${condition}_rest1.txt

   finalfile_rs2=$SAVEDIR/Mean_GC_acf_${condition}_rest2.txt

   echo $condition
   [ -r $finalfile_rs2 ] &&  echo "Final file rest 2 exists; skipping" && continue

   cat $DATADIR2/*/*_GC_acf_${condition}.txt | datamash mean 1 mean 2 mean 3 mean 4 -W \
      > $SAVEDIR/Mean_GC_acf_${condition}_rest2.txt
done

#Average L/R (numbers are very simiar)
mconditions="NAcc Caudate Putamen"
for condition in $mconditions; do 
   finalfile2=$SAVEDIR/Mean_GC_acf_${condition}_rest1.txt
   echo $condition
   [ -r $finalfile2 ] && echo "Final file rest 1 exists; skipping" && continue 
    
   cat $SAVEDIR/Mean_GC_acf_*_${condition}_rest1.txt | datamash mean 1 mean 2 mean 3 mean 4 -W \
      > $SAVEDIR/Mean_GC_acf_${condition}_rest1.txt

   finalfile2_rs2=$SAVEDIR/Mean_GC_acf_${condition}_rest2.txt
   echo $condition
   [ -r $finalfile2_rs2 ] && echo "Final file rest 2 exists; skipping" && continue 
   
   cat $SAVEDIR/Mean_GC_acf_*_${condition}_rest2.txt | datamash mean 1 mean 2 mean 3 mean 4 -W \
      > $SAVEDIR/Mean_GC_acf_${condition}_rest2.txt
done

#Average across ALL STRIATAL  ROIs (again, numbers are very similar) 
finalfile3=$SAVEDIR/Mean_GC_acf_allROIs_rest1.txt
[ -r $finalfile3 ] && echo "All ROI mean rs1 file exists: skipping"

cat $SAVEDIR/Mean_GC_acf_NAcc_rest1.txt $SAVEDIR/Mean_GC_acf_Putamen_rest1.txt $SAVEDIR/Mean_GC_acf_Caudate_rest1.txt \
   | datamash mean 1 mean 2 mean 3 mean 4 -W > $SAVEDIR/Mean_GC_acf_allROIs_rest1.txt

finalfile3_rs2=$SAVEDIR/Mean_GC_acf_allROIs_rest2.txt
[ -r $finalfile3_rs2 ] && echo "All ROI mean rs2 file exists: skipping"

cat $SAVEDIR/Mean_GC_acf_NAcc_rest2.txt $SAVEDIR/Mean_GC_acf_Putamen_rest2.txt $SAVEDIR/Mean_GC_acf_Caudate_rest2.txt \
   | datamash mean 1 mean 2 mean 3 mean 4 -W > $SAVEDIR/Mean_GC_acf_allROIs_rest2.txt

#Last thing, average across both resting state scans. 

finalfile4=$SAVEDIR/Mean_GC_acf_allROIs_bothrests.txt
[ -r $finalfile4 ] && echo "combined ROI mean rest file exists: skipping"

cat $SAVEDIR/Mean_GC_acf_allROIs_rest1.txt $SAVEDIR/Mean_GC_acf_allROIs_rest2.txt | datamash mean 1 mean 2 mean 3 \
   mean 4 -W > $SAVEDIR/Mean_GC_acf_allROIs_bothrests.txt

#average rests and backgrounds

finalfile5=$SAVEDIR/Mean_GC_acf_allROIs_restbg.txt
[ -r $finalfile4 ] && echo "combined ROI mean rest bg file exists: skipping"

cat $SAVEDIR/Mean_GC_acf_allROIs_bothrests.txt $SAVEDIR/Mean_GC_acf_allROIs_background.txt | datamash mean 1 mean 2 mean 3 \
   mean 4 -W > $SAVEDIR/Mean_GC_acf_allROIs_restbg.txt

