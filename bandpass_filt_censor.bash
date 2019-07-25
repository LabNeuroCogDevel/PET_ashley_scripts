#!/bin/bash
#this was originally designed to bandpass filter + censor the tent resid files, but Will has a better script that does GSR + bandpassing at the same time so this one is now obsolete. 
#Title: Bandpass_filt_censor2.bash
#Author: Ashley Parr
#Purpose: Script to bandpass filter output residuals with a censored file for both gam & tent files from 3dDeconvolve for use in background connectivity analyses 
# Directory:
#/Volumes/Phillips/mMR_PETDA/subjs/*/func/nfswdktm_*_resid.nii.gz
#Updated to run on subs who weren't there before 04/25/2019
source /opt/ni_tools/lncdshell/lncd.src.sh # gives us 'waitforjobs'
HOMEDIR=/Volumes/Phillips/mMR_PETDA/subjs
cd $HOMEDIR

for subj in $HOMEDIR/1*; do
   echo $subj
   a=$subj/merged_censor_union.1D
  # [ -r $subj/background_connectivity/cbnfswdktm_tent_resid.nii.gz ] && echo "$subj cbnfswdktm_tent_resid file exists" && continue
  # a=$(du nfswdktm_gam_resid.nii.gz |cut -f 1 -d $'\t')
   [ -r $subj/func/cbnfswdktm_tent_resid.nii.gz ] && echo "$subj cbnfswdktm_tent_resid file exists" && continue
  # a=$(du nfswdktm_gam_resid.nii.gz |cut -f 1 -d $'\t')
   [ ! -r $a ] && echo "$a does not exist" && continue
echo $subj 
  # b=$(du nfswdktm_tent_resid.nii.gz |cut -f 1 -d $'\t')
#problems with size of the files for the gam files so trying to fix
#if a -gt   
#run 3dBandpass
# don't re run if final file already in there and finished
3dTproject -input $subj/func/nfswdktm_tent_resid.nii.gz -prefix $subj/func/cbnfswdktm_tent_resid.nii.gz -censor $a -cenmode NTRP -passband 0.009 0.08 &
waitforjobs
#3dTproject -input nfswdktm_gam_resid.nii.gz -prefix cbnfswdktm_gam_resid.nii.gz -censor $a -cenmode NTRP -passband 0.009 0.08
echo $subj
done 

