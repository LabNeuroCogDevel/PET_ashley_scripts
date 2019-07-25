
#!/bin/bash

#Title: Extract_NAcc_VTA_Timeseries_background.bash
#Author: Ashley Parr
#Purpose: Script to extract right & left NAcc and VTA timeseries individually from output of ROI_Tempcorr where I had previously extracted timeseries for entire striatum, vmPFC and VTA atlases/masks. 
#these files WITH GSR (previous ones hadn't been)
#Date: 04/17/2019
#Dir: /Volumes/Phillips/mMR_PETDA/subjs

#DATADIR=/Volumes/Phillips/mMR_PETDA/subjs
DATADIR=/Volumes/Hera/Projects/mMR_PETDA/subjs
cd $DATADIR

for subj in $DATADIR/1*; do
   echo $subj
   sub_id=$(basename "$subj")
   if [ -r $subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt ];
   then
      echo "ts file exists"
   else
      echo "ts file is missing" && continue
   fi
   finalfile=$subj/background_connectivity/${sub_id}_L_Putamen_gsr.1D
   [ -r $finalfile ] && echo "have $finalfile, skipping" && continue
      echo "making $finalfile"

   col=$(head -n1 /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi40 | awk '{print $1}')
   cut -d' ' -f $col /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/background_connectivity/${sub_id}_R_NAcc_gsr.1D
  # sed -i '1d' ${sub_id}_R_NAcc_gsr.1D
   col=$(head -n1 /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi34 | awk '{print $1}')
   cut -d' ' -f $col /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/background_connectivity/${sub_id}_L_NAcc_gsr.1D
  # sed -i '1d' ${sub_id}_L_NAcc_gsr.1D
   col=$(head -n1 /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi44 | awk '{print $1}')
   cut -d' ' -f $col /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/background_connectivity/${sub_id}_VTA_gsr.1D
  # sed -i '1d' ${sub_id}_VTA_gsr.1D
   col=$(head -n1 /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi38 | awk '{print $1}')
   cut -d' ' -f $col /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/background_connectivity/${sub_id}_R_Caudate_gsr.1D
  # sed -i '1d' ${sub_id}_R_Caudate_gsr.1D
   col=$(head -n1 /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi32 | awk '{print $1}')
   cut -d' ' -f $col /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/background_connectivity/${sub_id}_L_Caudate_gsr.1D
  # sed -i '1d' ${sub_id}_L_Caudate_gsr.1D
   col=$(head -n1 /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi42 | awk '{print $1}')
   cut -d' ' -f $col /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/background_connectivity/${sub_id}_R_Putamen_gsr.1D
  # sed -i '1d' ${sub_id}_R_Putamen_gsr.1D
   col=$(head -n1 /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |tr ' ' '\n' | cat -n|grep roi36 | awk '{print $1}')
   cut -d' ' -f $col /$subj/func/*_vmpfc_striatal_vta_mean_gsr_ts.txt |sed '/roi/d' > /$subj/background_connectivity/${sub_id}_L_Putamen_gsr.1D
  # sed -i '1d' ${sub_id}_L_Putamen_gsr.1D
#Will's example that isn't working so I've cut out the piece that isn't working because I don't think we need it
  # col=$(head -n1 /$subj/func/*_vmpfc_striatal_vta_ts.txt |tr ' ' '\n' | cat -n|grep roi40 | awk '{print $1}')
  # cut -d' ' -f $col /$subj/func/*_vmpfc_striatal_vta_ts.txt |sed s/roi/d > /$subj/background_connectivity/${sub_id}_R_NAcc.1D
echo $subj
done 

#DATADIR2=/Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica

#col=$(head -n1 ../*/*_vmpfcstrvta20181221_ts.txt |tr ' ' '\n' | cat -n|grep roi40 | awk '{print $1}')
#cut -d' ' -f $col ../*/*_vmpfcstrvta20181221_ts.txt > ../*/*_R_NAcc.1D

#col=$(head -n1 ../*/*_vmpfcstrvta20181221_ts.txt |tr ' ' '\n' | cat -n|grep roi34 | awk '{print $1}')
#cut -d' ' -f $col ../*/*vmpfcstrvta20181221_ts.txt > ../*/*_L_NAcc.1D

#col=$(head -n1 ../*/*_vmpfcstrvta20181221_ts.txt |tr ' ' '\n' | cat -n|grep roi44 | awk '{print $1}')
#cut -d' ' -f $col ../*/*vmpfcstrvta20181221_ts.txt > ../*/*_VTA.1D
