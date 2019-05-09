# !/bin/bash

#Title: Striatal_ROI_masks.bash
#Author: Ashley Parr
#Purpose: script to develop separate ROI masks for striatal regions (right now there are L/R in same)

#Data Directory: /Volumes/Phillips/mMR_PETDA/atlas/Ashley/striatum_Ashley

HOMEDIR=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/striatum_Ashley

#for reg in $HOMEDIR/harOx*; do
3dClusterize -inset harOx_caudate.nii.gz -pref_map caudate_ROI.nii.gz  
