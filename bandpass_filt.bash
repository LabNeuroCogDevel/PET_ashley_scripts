#!/bin/bash

#Title: Bandpass_filt.bash
#Author: Ashley Parr
#Purpose: Script to bandpass filter output residuals for both gam & tent files from 3dDeconvolve for use in background connectivity analyses 
# Directory:
#/Volumes/Phillips/mMR_PETDA/subjs/*/func/nfswdktm_*_resid.nii.gz

HOMEDIR=/Volumes/Phillips/mMR_PETDA/subjs
cd $HOMEDIR

# Second star can be 'gam' or 'tent' in Finn's directory above

#loop through subjs
#for subj in 1*; do
for subj in $HOMEDIR/1*; do
   [ -r $subj/func/cbnfswdktm_gam_resid.nii.gz ] && continue
  # a=$(du nfswdktm_gam_resid.nii.gz |cut -f 1 -d $'\t')
  # b=$(du nfswdktm_tent_resid.nii.gz |cut -f 1 -d $'\t')
   cd $subj/func
#problems with size of the files for the gam files so trying to fix
#if a -gt   
#run 3dBandpass
3dBandpass -prefix bnfswktm_tent_resid.nii.gz 0.009 0.08 nfswdktm_tent_resid.nii.gz
3dBandpass -prefix bnfswdktm_gam_resid.nii.gz 0.009 0.08 nfswdktm_gam_resid.nii.gz
echo $subj
done 

