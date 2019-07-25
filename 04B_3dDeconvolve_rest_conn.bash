#!/bin/bash

#Title: 3dDeconvolve_rest_conn
#Author: Ashley Parr
#Purpose: Run 3dDeconvolve on resting state connectivity with NAcc/VTA as the seed
#Date: 04/22/2019

#GM Mask
scriptdir=$(pwd)
gmthes=.5
gmmask=$scriptdir/gm_p=${gmthes}_2.3mm.nii.gz 
if [ ! -r $gmmask ]; then 
   3dcalc -a ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii  -expr "step(a-$gmthes)" -prefix gmmask${thres}_1mm.nii.gz
   exampleinput=/Volumes/Phillips/mMR_PETDA/subjs/10195_20160317/background_connectivity/cbgnfswdktm_tent_resid.nii.gz  
   3dresample -master $exampleinput -inset gmmask${thres}_1mm.nii.gz -prefix $gmmask -rmode NN
fi

censor_file=censor_custom_fd_0.3_dvars_Inf.1d

DATADIR=/Volumes/Zeus/preproc/petrest_rac2/MHRest_FM_ica
cd $DATADIR
conditions="R_NAcc L_NAcc VTA R_Caudate L_Caudate R_Putamen L_Putamen" 

for subj in $DATADIR/1*; do
   for condition in $conditions; do
      sub_id=$(basename "$subj")

      echo $subj $sub_id $condition
      if [[ -r $subj/*_${condition}.1D || -r $subj/bgrnaswudktm_func_4.nii.gz ]];
      then
         echo "all seed ROI ts & rs ts files exist"
      else
         echo "one or more seed ROI ts or rs ts file missing" 
         echo "missing $subj/*_${condition}.1D or  $subj/bgrnaswudktm_func_4.nii.gz "
         continue
      fi

      # dont rerun already finished
      finalfile=$subj/${sub_id}_${condition}_REML_r_Z+tlrc.HEAD 
      [ -r $finalfile ] && echo "have $finalfile, skipping" && continue
      echo "making $finalfile"
#      [ ! -r $subj/${sub_id}_3ddeconvolve_corr_${condition}+tlrc.HEAD ] &&

      #run 3dDeconvolve
      3dDeconvolve -input $subj/bgrnaswudktm_func_4.nii.gz -polort 3 \
         -num_stimts 1 -stim_file 1 $subj/*_${condition}.1D \
         -rout -bucket $subj/${sub_id}_3ddeconvolve_corr_${condition} \
         -errts $subj/${sub_id}_3ddeconvolve_model_resid_${condition} \
         -censor $subj/motion_info/${censor_file} \
         -jobs 20 \
         -overwrite
      [ ! -r $subj/${sub_id}_${condition}_REML+tlrc.HEAD ] &&

      3dREMLfit -matrix $subj/${sub_id}_3ddeconvolve_corr_${condition}.xmat.1D -input $subj/bgrnaswudktm_func_4.nii.gz \
         -mask $gmmask -rout -tout -Rbuck $subj/${sub_id}_${condition}_REML -Rvar $subj/${sub_id}_${condition}_REMLvar -verb \
         -overwrite

      #Get R value from R squared
      #first variable is sub-brik for R sq, second is sub-brik for beta coefficient 
       [ ! -r $subj/${sub_id}_${condition}_REML_r+tlrc.HEAD ] &&

      3dcalc -a $subj/${sub_id}_${condition}_REML+tlrc.[4] -b $subj/${sub_id}_${condition}_REML+tlrc.[2] \
         -expr 'ispositive(b)*sqrt(a)-isnegative(b)*sqrt(a)' -prefix $subj/${sub_id}_${condition}_REML_r \
         -overwrite

      #calculate fisher Z scores to run stats
          [ ! -r $subj/${sub_id}_${condition}_REML_r_Z+tlrc.HEAD ] &&
      3dcalc -a $subj/${sub_id}_${condition}_REML_r+tlrc. -expr 'log((1+a)/(1-a))/2' -prefix $subj/${sub_id}_${condition}_REML_r_Z -overwrite 

       #DO 3DCALC ON THE NON REML ONES TO SEE IF THAT CHANGES THE MAGNITUDE OF THE CORRELATIONS. 
       3dcalc -a $subj/${sub_id}_3ddeconvolve_corr_${condition}+tlrc.[3] -b $subj/${sub_id}_3ddeconvolve_corr_${condition}+tlrc.[2] \
           -expr 'ispositive(b)*sqrt(a)-isnegative(b)*sqrt(a)' -prefix $subj/${sub_id}_${condition}_r -overwrite

       3dcalc -a $subj/${sub_id}_${condition}_r+tlrc. -expr 'log((1+a)/(1-a))/2' -prefix $subj/${sub_id}_${condition}_r_Z -overwrite   

   done
done


