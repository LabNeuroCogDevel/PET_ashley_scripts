#!/bin/bash

#Title: 3dClustSim_background_09.bash
#Author: Ashley Parr
#Purpose: perform cluster simulation on group connectivity maps (first average the output from 3dFWHMx across participants for each seed ROI). 
#Date: 05/08/2019


conditions="R_NAcc L_NAcc VTA R_Caudate L_Caudate R_Putamen L_Putamen"
BG_DATADIR=/Volumes/Phillips/mMR_PETDA/subjs/*/background_connectivity/
RS1_DATADIR=/Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica/*/
RS2_DATADIR=/Volumes/Zeus/preproc/petrest_rac2/MHRest_FM_ica/*/


for condition in conditions; do

   ls -ltr $BG_DATADIR/*_GC_acf_${condition}.txt |awk '{sum+=$1} END {print ${condition} "BG_Average_FWHM_x = ",sum/NR}' 
   ls -ltr $BG_DATADIR/*_GC_acf_${condition}.txt |awk '{sum+=$2} END {print ${condition} "BG_Average_FWHM_y = ",sum/NR}' 
   ls -ltr $BG_DATADIR/*_GC_acf_${condition}.txt |awk '{sum+=$3} END {print ${condition} "BG_Average_FWHM_z = ",sum/NR}' 

   ls -ltr $RS1_DATADIR/*_GC_acf_${condition}.txt |awk '{sum+=$1} END {print ${condition} "RS1_Average_FWHM_x = ",sum/NR}' 
   ls -ltr $RS1_DATADIR/*_GC_acf_${condition}.txt |awk '{sum+=$2} END {print ${condition} "RS1_Average_FWHM_y = ",sum/NR}' 
   ls -ltr $RS1_DATADIR/*_GC_acf_${condition}.txt |awk '{sum+=$3} END {print ${condition} "RS1_Average_FWHM_z = ",sum/NR}' 

   ls -ltr $RS2_DATADIR/*_GC_acf_${condition}.txt |awk '{sum+=$1} END {print ${condition} "RS2_Average_FWHM_x = ",sum/NR}' 
   ls -ltr $RS2_DATADIR/*_GC_acf_${condition}.txt |awk '{sum+=$2} END {print ${condition} "RS2_Average_FWHM_y = ",sum/NR}' 
   ls -ltr $RS2_DATADIR/*_GC_acf_${condition}.txt |awk '{sum+=$3} END {print ${condition} "RS2_Average_FWHM_z = ",sum/NR}' 
done

#OR 
#filename=*_GC_acf_${condition}.txt 
#(cd awkdir ; ls | while read filename ; do awk '{sum+=$1} END { print "Average for " $filename " = ", sum/NR}' $filename ; done)
