#!/bin/bash

#Title: ROI_masks.bash
#Author: Ashley Parr
#Purpose: Script to develop ROI masks for VmPFC, Striatum, VTA for background connectivity analyses
# Data Directory: 
#/Volumes/Phillips/mMR_PETDA/subjs/*/func
# Atlas Directory: /Volumes/Phillips/mMR_PETDA/atlas
# Contains the Harvard Oxford striatal and Murty VTA atlases. 
#AFNI gui already has the VmPFC atlas
HOMEDIR=/Volumes/Phillips/mMR_PETDA/atlas/vmPFC_Ashley
cd $HOMEDIR

whereami -mask_atlas_region MNI_VmPFC:area11m_left -prefix MNI_VmPFC_Larea11m
whereami -mask_atlas_region MNI_VmPFC:area11m_right -prefix MNI_VmPFC_Rarea11m

whereami -mask_atlas_region MNI_VmPFC:area14c_left -prefix MNI_VmPFC_Larea14c
whereami -mask_atlas_region MNI_VmPFC:area14c_right -prefix MNI_VmPFC_Rarea14c

whereami -mask_atlas_region MNI_VmPFC:area14m_left -prefix MNI_VmPFC_Larea14m
whereami -mask_atlas_region MNI_VmPFC:area14m_right -prefix MNI_VmPFC_Rarea14m

whereami -mask_atlas_region MNI_VmPFC:area14r_left -prefix MNI_VmPFC_Larea14r
whereami -mask_atlas_region MNI_VmPFC:area14r_right -prefix MNI_VmPFC_Rarea14r

whereami -mask_atlas_region MNI_VmPFC:area14rr_left -prefix MNI_VmPFC_Larea14rr
whereami -mask_atlas_region MNI_VmPFC:area14rr_right -prefix MNI_VmPFC_Rarea14rr

whereami -mask_atlas_region MNI_VmPFC:area24_left -prefix MNI_VmPFC_Larea24
whereami -mask_atlas_region MNI_VmPFC:area24_right -prefix MNI_VmPFC_Rarea24

whereami -mask_atlas_region MNI_VmPFC:area25_left -prefix MNI_VmPFC_Larea25
whereami -mask_atlas_region MNI_VmPFC:area25_right -prefix MNI_VmPFC_Rarea25

whereami -mask_atlas_region MNI_VmPFC:area32_left -prefix MNI_VmPFC_Larea32
whereami -mask_atlas_region MNI_VmPFC:area32_right -prefix MNI_VmPFC_Rarea32 









