#!/bin/bas

#Title: 3dfWHMx_rest_08.bash
#Author: Ashley Parr
#Purpose: Compute per subject (and condition) smoothness using fWHM/acf procedure so it can be used by 3d Clust Sim
#Date: 05/07/2019
MAXJOBS=20
WAITTIME=60
source /opt/ni_tools/lncdshell/utils/waitforjobs.sh
set -euo pipefail

#GM MASK
scriptdir=$(pwd)
gmthes=.5
gmmask=$scriptdir/gm_p=${gmthes}_2.3mm.nii.gz
if [ ! -r $gmmask ]; then
   3dcalc -a ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii  -expr "step(a-$gmthes)" -prefix gmmask${thres}_1mm.nii.gz
   exampleinput=/Volumes/Phillips/mMR_PETDA/subjs/10195_20160317/background_connectivity/cbgnfswdktm_tent_resid.nii.gz
    3dresample -master $exampleinput -inset gmmask${thres}_1mm.nii.gz -prefix $gmmask -rmode NN
fi
DATADIR=/Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica
cd $DATADIR
conditions="R_NAcc L_NAcc VTA R_Caudate L_Caudate R_Putamen L_Putamen" 

for subj in $DATADIR/1*; do
   for condition in $conditions; do
      sub_id=$(basename "$subj")
      echo $sub_id $condition

      errtsFname=$subj/${sub_id}_3ddeconvolve_model_resid_${condition}+tlrc.HEAD
      if [ -r $errtsFname ]; then echo "Errts file exists for $sub_id"
      else echo "Errts file missing for $sub_id"
         continue
      fi

      3dFWHMx -acf -overwrite \
         -mask $gmmask \
         -input ${errtsFname} | sed 's/ \+/ /' | sed 1d > $subj/${sub_id}_GC_acf_${condition}.txt &
      sleep .25
      waitforjobs
   done
done
      
