#!/bin/bash
set -euo pipefail
#Title: Transfer_files_from_Phillips.bash
#Author: Will Foran (put into script by Ashley Parr)
#Purpose: Phillips is full, I've migrated to Hera & my data files need to follow me. 
#Directory: /Volumes/Phillips/mMR_PETDA/subjs >> /Volumes/Hera/Projects/mMR_PETDA/subjs
#Date: 07/17/2019

rsync i-size-only -vhi /Volumes/Phillips/mMR_PETDA/subjs /Volumes/Hera/Projects/mMR_PETDA/subjs/  --files-from=<(cd /Volumes/Phillips/mMR_PETDA/subjs; ls 1*_2*/func/nfswdktm_tent_resid.nii.gz)

