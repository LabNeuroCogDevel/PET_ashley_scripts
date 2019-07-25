#!/bin/bash

#Title: Merge_atlases.bash
#Author: Ashley Parr
#Purpose: Script to merge all relevant ROI atlases into one
#Directory:
#/Volumes/Phillips/mMR_PETDA/atlas/vmPFC_Ashley

HOMEDIR=/Volumes/Phillips/mMR_PETDA/atlas/Ashley
cd $HOMEDIR


#Resample to master functional timecourse
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Larea11m_rsfunctemplate.nii.gz -inset MNI_VmPFC_Larea11m.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Larea14c_rsfunctemplate.nii.gz -inset MNI_VmPFC_Larea14c.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Larea14m_rsfunctemplate.nii.gz -inset MNI_VmPFC_Larea14m.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Larea14r_rsfunctemplate.nii.gz -inset MNI_VmPFC_Larea14r.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Larea14rr_rsfunctemplate.nii.gz -inset MNI_VmPFC_Larea14rr.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Larea24_rsfunctemplate.nii.gz -inset MNI_VmPFC_Larea24.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Larea25_rsfunctemplate.nii.gz -inset MNI_VmPFC_Larea25.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Larea32_rsfunctemplate.nii.gz -inset MNI_VmPFC_Larea32.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Rarea11m_rsfunctemplate.nii.gz -inset MNI_VmPFC_Rarea11m.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Rarea14c_rsfunctemplate.nii.gz -inset MNI_VmPFC_Rarea14c.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Rarea14m_rsfunctemplate.nii.gz -inset MNI_VmPFC_Rarea14m.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Rarea14r_rsfunctemplate.nii.gz -inset MNI_VmPFC_Rarea14r.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Rarea14rr_rsfunctemplate.nii.gz -inset MNI_VmPFC_Rarea14rr.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Rarea24_rsfunctemplate.nii.gz -inset MNI_VmPFC_Rarea24.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Rarea25_rsfunctemplate.nii.gz -inset MNI_VmPFC_Rarea25.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix MNI_VmPFC_Rarea32_rsfunctemplate.nii.gz -inset MNI_VmPFC_Rarea32.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix mean_VTA_rsfunctemplate.nii.gz -inset mean_VTA.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix L_caudate_harOx_rsfunctemplate.nii.gz -inset L_caudate_harOx.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix R_caudate_harOx_rsfunctemplate.nii.gz -inset R_caudate_harOx.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix L_putamen_harOx_rsfunctemplate.nii.gz -inset L_putamen_harOx.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix R_putamen_harOx_rsfunctemplate.nii.gz -inset R_putamen_harOx.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix L_Nacc_harOx_rsfunctemplate.nii.gz -inset L_Nacc_harOx.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix R_Nacc_harOx_rsfunctemplate.nii.gz -inset R_Nacc_harOx.nii.gz
3dresample -master cbnfswdktm_tent_resid.nii.gz -prefix mean_VTA_bin_rsfunctemplate.nii.gz -inset mean_VTA_bin.nii.gz


3dcalc -a MNI_VmPFC_Larea11m_rsfunctemplate.nii.gz -b MNI_VmPFC_Larea14c_rsfunctemplate.nii.gz \
   -c MNI_VmPFC_Larea14m_rsfunctemplate.nii.gz -d MNI_VmPFC_Larea14r_rsfunctemplate.nii.gz \
   -e MNI_VmPFC_Larea14rr_rsfunctemplate.nii.gz -f MNI_VmPFC_Larea24_rsfunctemplate.nii.gz \
   -g MNI_VmPFC_Larea25_rsfunctemplate.nii.gz -h MNI_VmPFC_Larea32_rsfunctemplate.nii.gz \
   -i MNI_VmPFC_Rarea11m_rsfunctemplate.nii.gz -j MNI_VmPFC_Rarea14c_rsfunctemplate.nii.gz \
   -k MNI_VmPFC_Rarea14m_rsfunctemplate.nii.gz -l MNI_VmPFC_Rarea14r_rsfunctemplate.nii.gz \
   -m MNI_VmPFC_Rarea14rr_rsfunctemplate.nii.gz -n MNI_VmPFC_Rarea24_rsfunctemplate.nii.gz \
   -o MNI_VmPFC_Rarea25_rsfunctemplate.nii.gz -p MNI_VmPFC_Rarea32_rsfunctemplate.nii.gz \
   -q L_caudate_harOx_rsfunctemplate.nii.gz -r L_Nacc_harOx_rsfunctemplate.nii.gz \
   -s L_putamen_harOx_rsfunctemplate.nii.gz -t R_caudate_harOx_rsfunctemplate.nii.gz \
   -u R_Nacc_harOx_rsfunctemplate.nii.gz -v R_putamen_harOx_rsfunctemplate.nii.gz -w mean_VTA_bin_rsfunctemplate.nii.gz \
   -expr 'step(a)+2*step(b)+4*step(c)+6*step(d)+8*step(e)+10*step(f)+12*step(g)+14*step(h)+16*step(i)+18*step(j)+20*step(k)+22*step(l)+24*step(m)+26*step(n)+28*step(o)+30*step(p)+32*step(q)+34*step(r)+36*step(s)+38*step(t)+40*step(u)+42*step(v)+44*step(w)' \
   -prefix VMPFC_STRIATAL_VTA_ROIS_rsfunctemp.nii.gz 


#3dcalc -a MNI_VmPFC_Larea11m_rsfunctemplate.nii.gz -b MNI_VmPFC_Larea14c_rsfunctemplate.nii.gz \
#   -c MNI_VmPFC_Larea14m_rsfunctemplate.nii.gz -d MNI_VmPFC_Larea14r_rsfunctemplate.nii.gz \
#   -e MNI_VmPFC_Larea14rr_rsfunctemplate.nii.gz -f MNI_VmPFC_Larea24_rsfunctemplate.nii.gz \
#   -g MNI_VmPFC_Larea25_rsfunctemplate.nii.gz -h MNI_VmPFC_Larea32_rsfunctemplate.nii.gz \
#   -i MNI_VmPFC_Rarea11m_rsfunctemplate.nii.gz -j MNI_VmPFC_Rarea14c_rsfunctemplate.nii.gz \
#   -k MNI_VmPFC_Rarea14m_rsfunctemplate.nii.gz -l MNI_VmPFC_Rarea14r_rsfunctemplate.nii.gz \
#   -m MNI_VmPFC_Rarea14rr_rsfunctemplate.nii.gz -n MNI_VmPFC_Rarea24_rsfunctemplate.nii.gz \
#   -o MNI_VmPFC_Rarea25_rsfunctemplate.nii.gz -p MNI_VmPFC_Rarea32_rsfunctemplate.nii.gz \
#   -expr 'step(a)+2*step(b)+4*step(c)+6*step(d)+8*step(e)+10*step(f)+12*step(g)+14*step(h)+16*step(i)+18*step(j)+20*step(k)+22*step(l)+24*step(m)+26*step(n)+28*step(o)+30*step(p)'\
#   -prefix VMPFC_ROIS_rsfunctemp_may.nii.gz 
#
