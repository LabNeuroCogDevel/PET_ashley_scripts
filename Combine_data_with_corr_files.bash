#!/bin/bash
#Title:Combine_data_w_corr_files.bash
#Author: Ashley Parr
#Purpose: combine file information with the participant's datatable so it can be indexed. 
#Date: 04/25/2019

datatable=/Volumes/Phillips/mMR_PETDA/analysis_ashley/mega_data.csv

Rest_dir= /Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica
BG_dir= /Volumes/Phillips/mMR_PETDA/subjs/

conditions="R_NAcc L_NAcc VTA R_Caudate L_Caudate R_Putamen L_Putamen"

#example of files I need: 
RS_file=$subj/${sub_id}_${condition}_r_Z
BG_file=$subj/background_connectivity/${sub_id}_${condition}_r_Z

#What I need is to match on sub_id (which is ses_id in the datatable) that has the subject #
# & the visit date on it. Then create a new col that specifies the context (RS v BG), and put
# the filename of the RS and BG files in another new col, respectively. 
# Then need to:
#1. Delete any sub/ses that has neither a background file or a rest file (but can have a missing
#rest of bg file, that's OK)
#2. Then have one that is complete cases (only those subs/ses who have both background and rest)
#Will do this for all conditions. 
