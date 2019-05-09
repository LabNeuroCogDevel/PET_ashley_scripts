#!/bin/bash

#Title: Convert_Nii.bash
#Author: Ashley Parr
#Purpose: convert afni mni_vmPFC atlas from brik/head to nii files. 
#Directory: /Volumes/Phillips/mMR_PETDA/atlas/vmPFC_Ashley

HOMEDIR=/Volumes/Phillips/mMR_PETDA/atlas/Ashley/striatum_Ashley
cd $HOMEDIR
for roi in $HOMEDIR/*BRIK.gz; do
3dAFNItoNIFTI "$roi"
done

