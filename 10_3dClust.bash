#!/bin/bash

#Title: 3dClust_10.bash
#Author: Ashley Parr
#Purpose: run 3dCluster simulation on the acf  values from 3dfWHM scripts.
#Date Created: 05/21/2019

DATADIR=/Volumes/Hera/Projects/mMR_PETDA/group_analysis_ashley
cd $DATADIR

scriptdir=$(pwd)
gmthes=.5
gmmask=$scriptdir/gm_p=${gmthes}_2.3mm.nii.gz
if [ ! -r $gmmask ]; then 
   3dcalc -a ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c.nii -expr "step(a-$gmthes)" -prefix gmmask${thres}_1mm.nii.gz
   exampleinput=/Volumes/Phillips/mMR_PETDA/subjs/10195_20160317/background_connectivity/cbgnfswdktm_tent_resid.nii.gz
   3dresample -master $exampleinput -inset gmmask${thres}_1mm.nii.gz -prefix $gmmask -rmode NN
fi

conditions="NAcc Caudate Putamen"
for condition in $conditions; do

   acf1=$(awk {'print $1'} $DATADIR/acf_vals/Mean_GC_acf_allROIs_bothrests.txt) #Both rests combined, averaged across 3 striatal ROIS 
   acf2=$(awk {'print $2'} $DATADIR/acf_vals/Mean_GC_acf_allROIs_bothrests.txt)
   acf3=$(awk {'print $3'} $DATADIR/acf_vals/Mean_GC_acf_allROIs_bothrests.txt)

   acf4=$(awk {'print $1'} $DATADIR/acf_vals/Mean_GC_acf_allROIs_background.txt) #background, averaged across 3 striatal ROIs
   acf5=$(awk {'print $2'} $DATADIR/acf_vals/Mean_GC_acf_allROIs_background.txt)
   acf6=$(awk {'print $3'} $DATADIR/acf_vals/Mean_GC_acf_allROIs_background.txt)
 
   acf7=$(awk {'print $1'} $DATADIR/acf_vals/Mean_GC_acf_allROIs_restbg.txt) #mean of background and rest across 3 striatal ROIs. 
   acf8=$(awk {'print $2'} $DATADIR/acf_vals/Mean_GC_acf_allROIs_restbg.txt)
   acf9=$(awk {'print $3'} $DATADIR/acf_vals/Mean_GC_acf_allROIs_restbg.txt)

#Run 3 separate simulations - one for rest acf values, one for background acf values, and one for the mean of those. Pick the most conservative one. 

3dClustSim \
   -acf $acf1 $acf2 $acf3 \
   -mask $gmmask > ${condition}_clustSim_rs.txt 
   #-jobs 20

3dClustSim \
   -acf $acf4 $acf5 $acf6 \
   -mask $gmmask > ${condition}_clustSim_bg.txt 
   #-jobs 20

3dClustSim \
   -acf $acf7 $acf8 $acf9 \
   -mask $gmmask > ${condition}_clustSim_bgrs.txt 
   #-jobs 20

#3dClustSim \
#      -acf 0.5582919 2.9735825 9.5799342 -jobs 20 \
#         -mask $map > 3dLME_invage_sex_RS2_maineff_gmmask_${condition}_clustSim.txt
done

