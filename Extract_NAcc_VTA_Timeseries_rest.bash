
#!/bin/bash

#Title: Extract_NAcc_VTA_Timeseries_rest.bash
#Author: Ashley Parr
#Purpose: Script to extract right & left NAcc and VTA timeseries individually from output of ROI_Tempcorr where I had previously extracted timeseries for entire striatum, vmPFC and VTA atlases/masks. 
#Date: 04/17/2019
#Dir: /Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica

DATADIR=/Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica
cd $DATADIR
for subj in $DATADIR/1*; do
   echo $subj
   sub_id=$(basename "$subj")
   if [ -r $subj/*_vmpfcstrvta20181221_ts_gsr.txt ];
   then
      echo "ts file exists for $sub_id"
   else
      echo "ts file is missing $sub_id" && continue
   fi

    # 3dROIstats  -mask /Volumes/Phillips/mMR_PETDA/atlas/Ashley/VMPFC_STRIATAL_VTA_ROIS_rsfunctemp.nii.gz /Volumes/Phillips/mMR_PETDA/atlas/Ashley/VMPFC_STRIATAL_VTA_ROIS_rsfunctemp.nii.gz  |sed 1q|cut -f 3-|sed 's/Mean_//g;s/\t/\n/g;'|cat -n
# roi   pos   # roi pos # roi pos       # roi40 R_NAcc.1D
# censor 1    # 14 9    # 32 18         # roi34 L_NAcc.1D
# 1      2    # 16 10   # 34 19         # roi44 VTA.1D
# 2      3    # 18 11   # 36 20         # roi38 R_Caudate.1D
# 4      4    # 20 12   # 38 21         # roi32 L_Caudate.1D
# 6      5    # 22 13   # 40 22         # roi42 R_Putamen.1D
# 8      6    # 24 14   # 42 23         # roi36 L_Putamen.1D
# 10     7    # 26 15   # 44 24
# 12     8    # 28 16   # 68 25
              # 30 17

   roi_40_col=22 
   cut -d' ' -f $roi_40_col $subj/*_vmpfcstrvta20181221_ts_gsr.txt > $subj/${sub_id}_R_NAcc.1D
   roi_34_col=19
   cut -d' ' -f $roi_34_col $subj/*_vmpfcstrvta20181221_ts_gsr.txt > $subj/${sub_id}_L_NAcc.1D
   roi_44_col=24
   cut -d' ' -f $roi_44_col $subj/*_vmpfcstrvta20181221_ts_gsr.txt > $subj/${sub_id}_VTA.1D
   roi_38_col=21
   cut -d' ' -f $roi_38_col $subj/*vmpfcstrvta20181221_ts_gsr.txt > $subj/${sub_id}_R_Caudate.1D
   roi_32_col=18
   cut -d' ' -f $roi_32_col $subj/*_vmpfcstrvta20181221_ts_gsr.txt > $subj/${sub_id}_L_Caudate.1D
   roi_42_col=23
   cut -d' ' -f $roi_42_col $subj/*_vmpfcstrvta20181221_ts_gsr.txt > $subj/${sub_id}_R_Putamen.1D
   roi_36_col=20 
   cut -d' ' -f $roi_36_col $subj/*_vmpfcstrvta20181221_ts_gsr.txt > $subj/${sub_id}_L_Putamen.1D


#   echo $subj
done
