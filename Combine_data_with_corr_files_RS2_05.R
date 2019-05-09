#!/usr/bin/env Rscript
#Title: Combine_data_with_corr_files.R
#Author: Will Foran (at the request of Ashley Parr)
#Purpose: Prepare datatable for 3dLME (incorporate demographic information with 3dDeconvolved corr files for all subs). Do separately for all files and for only subs who have both background and rest files)
#Date: 04/26/2019
library(dbplyr)
library(dplyr)
library(tidyr)
library(stringr)
# InputFile 
#
# creates master spreasheet for LME input. to specify rows use grep like
#   match any instance of the string in the row (doesn't care about columns)
#
#   egrep 'L_Putamen' master_condtionXcontext.txt  > L_put.txt 
#   egrep 'L_Putamen|R_NAcc' master_condtionXcontext.txt  > L_put+NAcc.txt 
#   egrep 'L_Putamen' master_condtionXcontext.txt | grep RS > RS_L_put.txt 

#   look for specific column (because the above command will index file names that have L_putamen in them as well as the seed ROI col)
#   awk '($3=="L_Putamen"){print}' master_condtionXcontext.txt

datatable <- "/Volumes/Phillips/mMR_PETDA/analysis_ashley/mega_data.csv"
#could potentially just do visit 1, see if you can re-capture the results from before... 
Rest_dir<- "/Volumes/Zeus/preproc/petrest_rac1/MHRest_FM_ica"
Rest_dir2 <- "/Volumes/Zeus/preproc/petrest_rac2/MHRest_FM_ica"
Rest_base<- "/Volumes/Zeus/preproc/"
BG_dir <-"/Volumes/Phillips/mMR_PETDA/subjs/"

conditions <- data.frame(condition=c("R_NAcc","L_NAcc","VTA","R_Caudate","L_Caudate","R_Putamen","L_Putamen"))

# read in
d <- read.csv(datatable)[,-1]

# 3dLME/MVM needs 'Subj' to be defined
names(d)[names(d) == "lunaid"] <- "Subj"

# give them a condtion
d_cond <- merge(d,conditions) 

## add files
# files like $subj/${sub_id}_${condition}_r_Z
rs <- d_cond %>% 
   merge(data.frame(RS=c('petrest_rac1','petrest_rac2'))) %>%
   mutate(
          InputFile=file.path(Rest_base,RS,'MHRest_FM_ica',ses_id,paste(ses_id,condition,'r_Z+tlrc.HEAD',sep="_")),
          context=paste0('RS',
                         stringr::str_extract(InputFile,'rest_rac[12]') %>% gsub('rest_rac','',.) )) %>% select(-RS)
#rs2 <- d_cond %>% mutate(context="RS", InputFile=file.path(Rest_dir2,ses_id,paste(ses_id,condition,'r_Z+tlrc.HEAD',sep="_")))

# BG files like $subj/background_connectivity/${sub_id}_${condition}_r_Z
# mising 90
bg <- d_cond %>% mutate(context="BG", InputFile=file.path(BG_dir,ses_id,'background_connectivity',paste(ses_id,condition,'r_Z+tlrc.HEAD',sep="_")))

# everything that has files
b <- rbind(bg,rs) %>% filter(file.exists(InputFile))
#b2 <- rbind(bg,rs,rs2) %>% filter(file.exists(InputFile))

# missing 92 --- 90 without BG, 2 with RS
b %>% group_by(ses_id) %>% summarise(cnt=n(), have=paste(unique(context),collapse=",")) %>% filter(cnt!=14) %>% group_by(have) %>% tally
#b2 %>% group_by(ses_id) %>% summarise(cnt=n(), have=paste(unique(context),collapse=",")) %>% filter(cnt!=14) %>% group_by(have) %>% tally

## only for subjects with both
master_table <- b %>%
   group_by(ses_id) %>%
   mutate(have_runs=paste(collapse=",", unique(context))) %>%
   filter(grepl('BG',have_runs) & grepl('RS',have_runs))
#master_table2 <- b2 %>% group_by(ses_id) %>% mutate(file_cnt=n()) %>% filter(file_cnt == n_expect )
#AP added to collapse across hemispheres (04/29/2019)
master_table_hemi <- master_table
master_table_hemi$hemi= str_detect(master_table_hemi$condition, "L_")
master_table_hemi$hemi <- ifelse(master_table_hemi$hemi, 'Left','Right')
master_table_hemi$condition <- gsub('L_|R_','',master_table_hemi$condition)
master_table_hemi <- master_table_hemi%>%select(-InputFile,InputFile)

# get visit 1 only, see if you can recapitulate previous results
#master_table_V1 <- subset(master_table, master_table$visitnum==1) 
#master_table_hemi_V1 <- subset(master_table_hemi, master_table_hemi$visitnum==1)
#master_table2_hemi_V1 <- subset(master_table2_hemi, master_table2_hemi$visitnum==1)
#master_table3_V1 <- subset(master_table3, master_table3$visitnum==1)
setwd("/Volumes/Phillips/mMR_PETDA/group_analysis_ashley")
write.table(master_table %>% select(-have_runs),
            file="master_conditionXcontext_R2.txt",sep=" ",quote=F,row.names=F)
write.table(master_table_hemi %>% select(-have_runs),
            file="master_conditionXcontext_hemi_R2.txt",sep=" ",quote=F,row.names=F)
