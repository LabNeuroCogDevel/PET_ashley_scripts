#!bin/bash

#Title:  Parse_each_ROI_06.bash
# Author: Ashley Parr
# Purpose: separate out the big master text file into respective ROIs (conditions; NAcc, VTA, Caudate, Putamen) - collapsing henis
# This one goes before 3dLME
# Date: 05/03/2019

DATADIR=/Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley
conditions="NAcc Caudate Putamen"
cd $DATADIR
for condition in $conditions; do
   egrep '$condition|fdstat_funcmean' /Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley/master_conditionXcontext_hemi_R2.txt > \
      /Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley/${condition}Xcontext_RS2.txt
   egrep '$condition|fdstat_funcmean' /Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley/master_conditionXcontext_hemi_R2_goodr2p.txt > \
      /Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley/${condition}Xcontext_RS2_goodr2p.txt
   echo $condition
done

egrep 'VTA|fdstat_funcmean' /Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley/master_conditionXcontext_R2.txt > \
   /Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley/VTAXcontext_RS2.txt
egrep 'VTA|fdstat_funcmean' /Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley/master_conditionXcontext_R2_goodr2p.txt > \
   /Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley/VTAXcontext_RS2_goodr2p.txt

