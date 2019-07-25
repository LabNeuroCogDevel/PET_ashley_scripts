#!/bin/bash

#Title: 3dDeconvolve_background_conn
#Author: Ashley Parr
#Purpose: Run 3dDeconvolve on background connectivity with NAcc/VTA as the seed
#Date created: 04/18/2019 modified 05/03/2019 to specify use of GSR files

#GM Mask
scriptdir=$(pwd)
gmthes=.5
gmmask=$scriptdir/gm_p=${gmthes}_2.3mm.nii.gz 
if [ ! -r $gmmask ]; then 
   3dcalc -a ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii  -expr "step(a-$gmthes)" -prefix gmmask${thres}_1mm.nii.gz
   exampleinput=/Volumes/Phillips/mMR_PETDA/subjs/10195_20160317/background_connectivity/cbgnfswdktm_tent_resid.nii.gz  
   3dresample -master $exampleinput -inset gmmask${thres}_1mm.nii.gz -prefix $gmmask -rmode NN
fi

censor_file=censor_merged_fd_0.3_dvars_Inf.1D
DATADIR=/Volumes/Phillips/mMR_PETDA/subjs
cd $DATADIR
conditions="R_NAcc L_NAcc VTA R_Caudate L_Caudate R_Putamen L_Putamen" 
subjs="10195_20160317"
#for subj in $DATADIR/1*; do
for subj in $subjs; do
   # 20190509 dont try if we dont have the censor file
   censor_merged=$subj/background_connectivity/$censor_file
   [ ! -r $censor_merged ] && echo "no censor merge files! ($censor_merged)" && continue
   if [ $(cat $censor_merged | wc -l) -eq 0 ]; then
      ntsc=$(cat $subj/func/[1-6]/motion_info/censor_custom_fd_0.3_dvars_Inf.1d | wc -l )
      [ $ntsc -ne 1200 ] && echo "wrong number of censored rows ($ntsc)" && continue
      cat $subj/func/[1-6]/motion_info/censor_custom_fd_0.3_dvars_Inf.1d > $subj/background_connectivity/${censor_file}
   fi
   [ ! -r $censor_merged ] && echo "failed to make $censor_merged" && continue

   for condition in $conditions; do
      sub_id=$(basename "$subj")
    
      ts_file=$subj/background_connectivity/*_${condition}_gsr.1D
          
      echo $subj $sub_id $condition
      if [[ -r $ts_file || -r $subj/background_connectivity/cbgnfswdktm_tent_resid.nii.gz ]];
      then
         echo "all seed ROI ts & resid files exist"
      else
         echo "one or more seed ROI ts or resid file missing" 
         echo "missing $subj/background_connectivity/*_${condition}_gsr.1D or  $subj/background_connectivity/cbgnfswdktm_tent_resid.nii.gz "
         continue
      fi

      # dont rerun already finished #04/22/2019 Ash removed this because need it to overwrite them anyway
 #     finalfile=$subj/background_connectivity/${sub_id}_3ddeconvolve_model_resid_${condition}+tlrc.HEAD 
 #     [ -r $finalfile ] && echo "have $finalfile, skipping" && continue
      #run 3dDeconvolve

     # [ ! -r $subj/background_connectivity/${sub_id}_3ddeconvolve_corr_${condition}+tlrc.HEAD ] && 
    
     # move outputs to hera
     outdir=$subj/background_connectivity/
     outdir=${outdir/Phillips/Hera/Projects}
     [ ! -d $outdir ] && mkdir -p $outdir

  #    finalfile=$outdir/${sub_id}_3ddeconvolve_model_resid_${condition}+tlrc.HEAD 
  #    [ -r $finalfile ] && echo "have $finalfile, skipping" && continue
  #    echo "making $finalfile"

#     3dDeconvolve -input $subj/background_connectivity/cbgnfswdktm_tent_resid.nii.gz -polort 3 \
#         -censor $censor_merged \
#         -num_stimts 1 -stim_file 1 $ts_file \
#         -rout -bucket /Volumes/Hera/Projects/mMR_PETDA/subjs/$subj/background_connectivity/${sub_id}_3ddeconvolve_corr_${condition} \
#         -errts /Volumes/Hera/Projects/mMR_PETDA/subjs/$subj/background_connectivity/${sub_id}_3ddeconvolve_model_resid_${condition} \
#         -jobs 20 \
#         -overwrite
            
     # [ ! -r $subj/background_connectivity/${sub_id}_${condition}_REML+tlrc.HEAD ] && 
      
      3dREMLfit -matrix $outdir/${sub_id}_3ddeconvolve_corr_${condition}.xmat.1D -input $subj/background_connectivity/cbgnfswdktm_tent_resid.nii.gz \
         -rout -tout -Rbuck $outdir/${sub_id}_${condition}_REML -Rvar $outdir/${sub_id}_${condition}_REMLvar -verb \
         -overwrite
      -mask $gmmask
      #Get R value from R squared
      #first variable is sub-brik for R sq, second is sub-brik for beta coefficient

     # [ ! -r $subj/background_connectivity/${sub_id}_${condition}_REML_r+tlrc.HEAD ] && 
     
    3dcalc -a $outdir/${sub_id}_${condition}_REML+tlrc.[4] -b $outdir/${sub_id}_${condition}_REML+tlrc.[2] \
         -expr 'ispositive(b)*sqrt(a)-isnegative(b)*sqrt(a)' -prefix $outdir/${sub_id}_${condition}_REML_r \
         -overwrite
     #calculate fisher Z scores to run stats
     #[ ! -r $subj/background_connectivity/${sub_id}_${condition}_REML_r_Z+tlrc.HEAD ] &&  

      3dcalc -a $outdir/${sub_id}_${condition}_REML_r+tlrc. -expr 'log((1+a)/(1-a))/2' -prefix $outdir/${sub_id}_${condition}_REML_r_Z -overwrite 
 
    #DO 3DCALC ON THE NON REML ONES TO SEE IF THAT CHANGES THE MAGNITUDE OF THE CORRELATIONS. 
#     3dcalc -a /Volumes/Hera/Projects/mMR_PETDA/subjs/$subj/background_connectivity/${sub_id}_3ddeconvolve_corr_${condition}+tlrc.[3] \
#        -b /Volumes/Hera/Projects/mMR_PETDA/subjs/$subj/background_connectivity/${sub_id}_3ddeconvolve_corr_${condition}+tlrc.[2] \
#        -expr 'ispositive(b)*sqrt(a)-isnegative(b)*sqrt(a)' -prefix /Volumes/Hera/Projects/mMR_PETDA/subjs/$subj/background_connectivity/${sub_id}_${condition}_r -overwrite

 #    3dcalc -a /Volumes/Hera/Projects/mMR_PETDA/subjs/$subj/background_connectivity/${sub_id}_${condition}_r+tlrc.\
 #       -expr 'log((1+a)/(1-a))/2' -prefix /Volumes/Hera/Projects/mMR_PETDA/subjs/$subj/background_connectivity/${sub_id}_${condition}_r_Z -overwrite 
  
  done
done

