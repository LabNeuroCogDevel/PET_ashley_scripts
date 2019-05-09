%% tools
% An ugly script to pull in all the data, merge all questionnaires, PET,
% fMRI (BG & REST) and separate out into their respective visit dates.

clc
clear all; %#ok<CLALL>

% functional matlab
paren = @(x, varargin) x(varargin{:}); %#ok<NASGU>
curly = @(x, varargin) x{varargin{:}}; %#ok<NASGU>
addpath('/Volumes/Hera-3/Projects/RestDB/')

%Pull in tables for the questionnaire data. 
RT_18_Data = readtable('/Users/lncd/Documents/Projects/VTA-VMPFC/RT_18.xlsx','ReadRowNames',true);
Intolerance_Data = readtable('/Users/lncd/Documents/Projects/VTA-VMPFC/intolerance.xlsx','ReadRowNames',true);
RT_18_Data.date=yyyymmdd(RT_18_Data.date);
Intolerance_Data.date=yyyymmdd(Intolerance_Data.Date);
RT_18_Data = RT_18_Data(:, ismember(RT_18_Data.Properties.VariableNames, ...
    {'ID','date','visit_no','Score'}));
Intolerance_Data=Intolerance_Data(:, ismember(Intolerance_Data.Properties.VariableNames, ...
    {'ID','date','Prospective_Anxiety_Subscale','Inhibitory_Anxiety_Subscale','Total_Score'}));
RT_18_Data.Properties.VariableNames{'ID'}='lunaid'; %rename subj to lunaid
Intolerance_Data.Properties.VariableNames{'ID'}='lunaid'; %rename subj to lunaid
RT_18_Data.Properties.VariableNames{'date'}='vdate'; %rename subj to lunaid
Intolerance_Data.Properties.VariableNames{'date'}='vdate'; %rename subj to lunaid
RT_18_Data.Properties.VariableNames{'visit_no'}='visitnum'; %rename subj to lunaid

%pull in rest data
study = 'pet'; %#ok<NASGU>
atlas = 'vmpfcstrvta20181221';  %#ok<NASGU>
dbcn = sqlite('/Volumes/Hera-3/Projects/RestDB/rest.db');
tbl = get_rest(dbcn,'ses.study like "PET" and atlas like "vmpfcstrvta20181221"');

%% read in adjacency matrix data
% find file, get info from name (id and date)
%adj = dir('/Volumes/Phillips/mMR_PETDA/subjs/*/func/*_vmpfc_striatal_vta_ts_adj_pearson.txt');
adj = dir('/Volumes/Phillips/mMR_PETDA/subjs/*/background_connectivity/*_gs-wm-csf-6mot_vmpfc-striatal-vta_ts_adj*.txt'); 
info=cellfun(@(x) strsplit(x,'_'), {adj.name}, 'UniformOutput',0);

% vectors of important info
lunaid= cellfun( @(x) x{1}, info,'UniformOutput',0)';
vdate = cellfun( @(x) x{2}, info,'UniformOutput',0)';
%vdate = cellfun( @(x) datetime(x{2}, 'InputFormat','yyyyMMdd'), info)';
files = arrayfun(@(x) fullfile(x.folder,x.name), adj, 'UniformOutput',0);

% get a big table from merge pet
alldata = readtable('/Volumes/Phillips/mMR_PETDA/scripts/merged_data.csv',...
    'TreatAsEmpty',{'NA'});
mergepet = alldata(:, ismember(alldata.Properties.VariableNames, ...
    {'lunaid','vdate','visitnum','age','sex','srtmdyn_gamma_cic_accumbens','srtmdyn_modelbp_cic_accumbens',...
    'mr_rew_cic_accumbens','fdstat_funcmean','perf_num_diff','perf_pctoptblock1','perf_pctoptblock2','perf_pctoptblock3',...
    'perf_pctoptblock4','perf_pctoptblock5','perf_pctoptblock6','perf_rtmean1','perf_rtmean2','perf_rtmean3','perf_rtmean4',...
    'perf_rtmean5','perf_rtmean6','perf_rtsd1','perf_rtsd2','perf_rtsd3','perf_rtsd4',...
    'perf_rtsd5','perf_rtsd6','r2p_cic_accumbens','r2p_cic_caudate', 'r2p_cic_putamen','r2p_cic_striatum',...
    'r2p_harox_amyg','r2p_harox_caudate','r2p_harox_hpc','r2p_harox_nacc','r2p_harox_putamen','r2p_vta','mr_rew_vta',...
    'mr_rew_harox_nacc','mr_rew_harox_hpc','mr_rew_harox_putamen','mr_rew_mpfc_clust','mr_rew_harox_caudate',...
    'mr_rew_harox_amyg','mr_rew_harox_ahpc','srtmdyn_modelbp_harox_caudate','srtmdyn_modelbp_harox_hpc',...
    'srtmdyn_modelbp_harox_nacc','srtmdyn_modelbp_harox_putamen','srtmdyn_modelbp_harox_thalamus','srtmdyn_modelbp_vta',...
    'srtmdyn_gamma_harox_caudate','srtmdyn_gamma_harox_hpc','srtmdyn_gamma_harox_nacc','srtmdyn_gamma_harox_putamen',...
    'srtmdyn_gamma_harox_thalamus','srtmdyn_gamma_vta','dtbz_bp_cic_accumbens','dtbz_bp_harox_caudate','dtbz_bp_harox_nacc',...
    'dtbz_bp_harox_putamen','dtbz_bp_harox_thalamus','dtbz_bp_vta','dtbz_bp_sn'}));

% fix date for bad subject
mergepet.vdate{cellfun(@(x) strncmp('20172018',x,8), mergepet.vdate)} = '20170218';
mergepet.lunaid = arrayfun(@num2str, mergepet.lunaid, 'UniformOutput',0);

% convert strings to dates (Will had this in there but I took it out bc
% unnecessary
%mergepet.vdate = cellfun(@(x) datetime(x,'InputFormat','yyyyMMdd'), mergepet.vdate);
% and ids to strings
mm = fitlme(mergepet, 'r2p_cic_accumbens~age');
mm1 = fitlme(mergepet, 'r2p_cic_caudate~age');
mm2 = fitlme(mergepet, 'r2p_cic_putamen~age');
mm3 = fitlme(mergepet,'r2p_cic_striatum~age');
mm4 = fitlme(mergepet,'r2p_harox_amyg~age');
mm5 = fitlme(mergepet,'r2p_harox_caudate~age');
mm6 = fitlme(mergepet,'r2p_harox_hpc~age');
mm7 = fitlme(mergepet,'r2p_harox_nacc~age');
mm8 = fitlme(mergepet,'r2p_harox_putamen~age');
mm9 = fitlme(mergepet,'r2p_vta~age');
mergepet.res_r2p_cic_accumbens(:)=residuals(mm);
mergepet.res_r2p_cic_caudate(:)=residuals(mm1);
mergepet.res_r2p_cic_putamen(:)=residuals(mm2);
mergepet.res_r2p_cic_striatum(:)=residuals(mm3);
mergepet.res_r2p_harox_amyg(:)=residuals(mm4);
mergepet.res_r2p_harox_caudate(:)=residuals(mm5);
mergepet.res_r2p_harox_hpc(:)=residuals(mm6);
mergepet.res_r2p_harox_nacc(:)=residuals(mm7);
mergepet.res_r2p_harox_putamen(:)=residuals(mm8);
mergepet.res_r2p_vta(:)=residuals(mm9);

%Compute a few things.... 
for ii= 1:length(mergepet.age) %compute inverse age here so you don't have to do it separately for each table later
    mergepet.inv_age(ii)=1/mergepet.age(ii);
    perf_mat = [mergepet.perf_pctoptblock1(ii),mergepet.perf_pctoptblock2(ii),...
        mergepet.perf_pctoptblock3(ii),mergepet.perf_pctoptblock4(ii),...
        mergepet.perf_pctoptblock5(ii),mergepet.perf_pctoptblock6(ii)];
    rt_mat = [mergepet.perf_rtmean1(ii),mergepet.perf_rtmean2(ii),mergepet.perf_rtmean3(ii),...
        mergepet.perf_rtmean4(ii),mergepet.perf_rtmean5(ii),mergepet.perf_rtmean6(ii)];
    sdrt_mat = [mergepet.perf_rtsd1(ii),mergepet.perf_rtsd2(ii),mergepet.perf_rtsd3(ii),...
        mergepet.perf_rtsd4(ii),mergepet.perf_rtsd5(ii),mergepet.perf_rtsd6(ii)];
    mergepet.average_perf(ii)=nanmean(perf_mat);
    mergepet.average_rt(ii)=nanmean(rt_mat);
    mergepet.average_rtsd(ii)=nanmean(sdrt_mat); 
end

% Input data from RT-18 Questionnaire
new_RT_18 = unique(RT_18_Data);% remove duplicates
lunaids=str2num(cell2mat(mergepet.lunaid)); %#ok<ST2NM>

%Delete subs in the RT18 table that aren't in the mergepet database
idx=find(~ismember(new_RT_18.lunaid,lunaids));
new_RT_18(idx,:)=[]; %#ok<FNDSB>
idx=find(~ismember(Intolerance_Data.lunaid,lunaids));
Intolerance_Data(idx,:)=[]; %#ok<FNDSB>

for i=1:length(new_RT_18.lunaid)
    inds= find(lunaids==new_RT_18.lunaid(i) & mergepet.visitnum==new_RT_18.visitnum(i));% & mergepet.visitnum==new_RT_18.visitnum(i))
    mergepet.RT_18_Score(inds)=new_RT_18.Score(i); %#ok<FNDSB>
end

%Input data from Intolerance Questionnaire 
for i=1:length(Intolerance_Data.lunaid)
    inds=find(lunaids==Intolerance_Data.lunaid(i));
    for j=1:length(inds)
    mergepet.Intolerance_Prospective_Anxiety(inds(j))=Intolerance_Data.Prospective_Anxiety_Subscale(i);
    mergepet.Intolerance_Inhibitory_Anxiety(inds(j))=Intolerance_Data.Inhibitory_Anxiety_Subscale(i);
    mergepet.Intolerance_Total(inds(j))=Intolerance_Data.Total_Score(i);
    end
end
for ii=1:length(mergepet.Intolerance_Prospective_Anxiety)
    if mergepet.Intolerance_Prospective_Anxiety(ii)==0
    mergepet.Intolerance_Prospective_Anxiety(ii)=NaN;
    mergepet.Intolerance_Inhibitory_Anxiety(ii)=NaN;
    mergepet.Intolerance_Total(ii)=NaN;
    end    
end
%Read in important info from rest database
rest = tbl(:, ismember(tbl.Properties.VariableNames, ...
    {'subj','age','sex','ses_id','preproc','adj_file'}));

% change ses_id to lunaid
rest.ses_id= erase(rest.ses_id, "_");
for k = 1:length(rest.ses_id)
    mm = rest.ses_id{k};
    rest.vdate{k}=mm(6:end);
end

rest = removevars(rest,{'ses_id'});
rest.Properties.VariableNames{'subj'}='lunaid'; %rename subj to lunaid

% find the rs files we want and remove the other ones FOR NOW (may want to
% look at rac2 later on
rac1_gsr_inds=find(strcmp(rest.preproc,'aroma_gsr') & contains(rest.adj_file, "rac1"));
%rac1_gsr_inds=find(strcmp(rest.preproc,'aroma') & contains(rest.adj_file, "rac1") & ~contains(rest.preproc,"gsr"));

rest=rest(rac1_gsr_inds,:); %#ok<FNDSB>
%Find subs with bad MR Reward signal
inx=find(mergepet.mr_rew_cic_accumbens >0.3 | mergepet.mr_rew_cic_accumbens <-0.1);
nobadsubs=mergepet;
nobadsubs(inx,:)=[];

% merge info into a few tables
T = table(lunaid,vdate,files);
BG_nbs= innerjoin(T,nobadsubs);
BG = innerjoin(T,mergepet);
RS_nbs = innerjoin(rest,nobadsubs);
REST=innerjoin(rest,mergepet);
BG_RS= outerjoin(T,rest,'Type','left','MergeKeys',1); %prioritize background files
BG_RS.visitnum=BG.visitnum;
BG_RS.inv_age=BG.inv_age;
BG_RS.average_perf=BG.average_perf;
BG_RS.average_rt=BG.average_rt;
BG_RS.average_rtsd= BG.average_rtsd;
BG_RS.res_r2p_cic_accumbens=BG.res_r2p_cic_accumbens;
BG_RS.res_r2p_cic_accumbens=BG.res_r2p_cic_accumbens;
BG_RS.res_r2p_cic_caudate=BG.res_r2p_cic_caudate;
BG_RS.res_r2p_cic_putamen=BG.res_r2p_cic_putamen;
BG_RS.res_r2p_cic_striatum=BG.res_r2p_cic_striatum;
BG_RS.res_r2p_harox_amyg=BG.res_r2p_harox_amyg;
BG_RS.res_r2p_harox_caudate=BG.res_r2p_harox_caudate;
BG_RS.res_r2p_harox_hpc=BG.res_r2p_harox_hpc;
BG_RS.res_r2p_harox_nacc=BG.res_r2p_harox_nacc;
BG_RS.res_r2p_harox_putamen=BG.res_r2p_harox_putamen;
BG_RS.res_r2p_vta=BG.res_r2p_vta;
RS_BG = outerjoin(T,rest,'Type','right','MergeKeys',1); %prioritize rest files 
RS_BG.visitnum=REST.visitnum;
RS_BG.inv_age=REST.inv_age;
RS_BG.average_perf=REST.average_perf;
RS_BG.average_rt=REST.average_rt;
RS_BG.average_rtsd=REST.average_rtsd;
RS_BG.res_r2p_cic_accumbens=REST.res_r2p_cic_accumbens;
RS_BG.res_r2p_cic_accumbens=REST.res_r2p_cic_accumbens;
RS_BG.res_r2p_cic_caudate=REST.res_r2p_cic_caudate;
RS_BG.res_r2p_cic_putamen=REST.res_r2p_cic_putamen;
RS_BG.res_r2p_cic_striatum=REST.res_r2p_cic_striatum;
RS_BG.res_r2p_harox_amyg=REST.res_r2p_harox_amyg;
RS_BG.res_r2p_harox_caudate=REST.res_r2p_harox_caudate;
RS_BG.res_r2p_harox_hpc=REST.res_r2p_harox_hpc;
RS_BG.res_r2p_harox_nacc=REST.res_r2p_harox_nacc;
RS_BG.res_r2p_harox_putamen=REST.res_r2p_harox_putamen;
RS_BG.res_r2p_vta=REST.res_r2p_vta;
%% Separate the data into visit 1-3
V1_BG=BG((find(BG.visitnum==1)),:);
V1_BG_nbs= BG_nbs((find(BG_nbs.visitnum==1)),:);
V2_BG=BG((find(BG.visitnum==2)),:);
V2_BG_nbs= BG_nbs((find(BG_nbs.visitnum==2)),:);
V3_BG=BG((find(BG.visitnum==3)),:);
V3_BG_nbs= BG_nbs((find(BG_nbs.visitnum==3)),:);
V1_REST=REST((find(REST.visitnum==1)),:);
V1_REST_nbs=RS_nbs((find(RS_nbs.visitnum==1)),:);
V2_REST=REST((find(REST.visitnum==2)),:);
V2_REST_nbs=RS_nbs((find(RS_nbs.visitnum==2)),:);
V3_REST=REST((find(REST.visitnum==3)),:); %no visit 3 yet
V3_REST_nbs=RS_nbs((find(RS_nbs.visitnum==3)),:);

V1_BG_RS=BG_RS((find(BG_RS.visitnum==1)),:);
V2_BG_RS=BG_RS((find(BG_RS.visitnum==2)),:);
V3_BG_RS=BG_RS((find(BG_RS.visitnum==3)),:);
V1_RS_BG=RS_BG((find(RS_BG.visitnum==1)),:);
V2_RS_BG=RS_BG((find(RS_BG.visitnum==2)),:);
%V3_RS_BG=RS_BG((find(RS_BG.visitnum==3)),:); %no visit 3 yet

% read in all the adjacency files for BG connectivity
BG_V1adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V1_BG.files,'UniformOutput',0);

for ii = 1:length(V1_BG.lunaid)
    ff{ii}=['ID',V1_BG.lunaid{ii}];
end
BG_V1adj_struct=cell2struct(BG_V1adj_,ff,1);
clear ff

BG_nbs_V1adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V1_BG_nbs.files,'UniformOutput',0);
for ii = 1:length(V1_BG_nbs.lunaid)
    ff{ii}=['ID',V1_BG_nbs.lunaid{ii}];
end
BG_nbs_V1adj_struct=cell2struct(BG_nbs_V1adj_,ff,1);
clear ff

BG_V2adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V2_BG.files,'UniformOutput',0);
for ii = 1:length(V2_BG.lunaid)
    ff{ii}=['ID',V2_BG.lunaid{ii}];
end
BG_V2adj_struct=cell2struct(BG_V2adj_,ff,1);
clear ff

BG_nbs_V2adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V2_BG_nbs.files,'UniformOutput',0);
for ii = 1:length(V2_BG_nbs.lunaid)
    ff{ii}=['ID',V2_BG_nbs.lunaid{ii}];
end
BG_nbs_V2adj_struct=cell2struct(BG_nbs_V2adj_,ff,1);
clear ff

%BG_V3adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
%    V3_BG.files,'UniformOutput',0);

% read in all the adjacency files for RS connectivity
RS_V1adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V1_REST.adj_file,'UniformOutput',0);
for ii = 1:length(V1_REST.lunaid)
    ff{ii}=['ID',V1_REST.lunaid{ii}];
end
RS_V1adj_struct=cell2struct(RS_V1adj_,ff,1);
clear ff

RS_nbs_V1adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V1_REST_nbs.adj_file,'UniformOutput',0);
for ii = 1:length(V1_REST_nbs.lunaid)
    ff{ii}=['ID',V1_REST_nbs.lunaid{ii}];
end
RS_nbs_V1adj_struct=cell2struct(RS_nbs_V1adj_,ff,1);
clear ff

RS_V2adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V2_REST.adj_file,'UniformOutput',0);
for ii = 1:length(V2_REST.lunaid)
    ff{ii}=['ID',V2_REST.lunaid{ii}];
end
RS_V2adj_struct=cell2struct(RS_V2adj_,ff,1);
clear ff

RS_nbs_V2adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V2_REST_nbs.adj_file,'UniformOutput',0);
for ii = 1:length(V2_REST_nbs.lunaid)
    ff{ii}=['ID',V2_REST_nbs.lunaid{ii}];
end
RS_nbs_V2adj_struct=cell2struct(RS_nbs_V2adj_,ff,1);
clear ff

%RS_V3adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
%    V3_REST.adj_file,'UniformOutput',0);

%create labels for ROIs (in order) AP
ROI_NAMES= {'L Ant. med. OFC 1','L Post. med. OFC 1','L Ant. VMPFC','L Post. med. OFC 2','L Ant. med. OFC 2',...
    'L Vent. ACC','L Subg. cingulate','L Rostr. ACC','R Ant. med. OFC 1','R Post. med. OFC 1','R Ant. VMPFC',...
    'R Post. med. OFC 2','R Ant. med. OFC 2','R Vent. ACC','R Subg. cingulate','R Rostr. ACC', 'L Caudate',...
    'L NAC','L Putamen','R Caudate','R NAC','R Putamen','VTA'};

%clear shit you don't need
clear alldata atlas files info Intolerance_Data lunaid lunaids mergepet new_RT_18 perf_mat rac1_gsr_inds rest RT_18_Data study T tbl vdate i idx ii inds mm dcbn
%dtstr=date;
%filename = ['/Volumes/Phillips/mMR_PETDA/analysis_ashley/All_Data_' dtstr];
%save (filename)
cd('/Volumes/Phillips/mMR_PETDA/analysis_ashley/');
writetable(V1_BG,'V1_BG.csv');
writetable(V1_REST,'V1_REST.csv');
writetable(V1_BG_nbs,'V1_BG_nbs.csv');
writetable(V1_REST_nbs,'V1_REST_nbs.csv');
writetable(V2_BG,'V2_BG.csv');
writetable(V2_REST,'V2_REST.csv');
writetable(V2_BG_nbs,'V2_BG_nbs.csv');
writetable(V2_REST_nbs,'V2_REST_nbs.csv');
writetable(V3_BG,'V3_BG.csv');
writetable(V3_REST,'V3_REST.csv');
writetable(V3_BG_nbs,'V3_BG_nbs.csv');
writetable(V3_REST_nbs,'V3_REST_nbs.csv');
writetable(BG,'BG.csv');
writetable(REST,'REST.csv');
writetable(BG_RS,'BG_RS.csv');
writetable(RS_BG,'RS_BG.csv');
save('V1_BG_adj.mat', '-struct','BG_V1adj_struct');
save('V1_RS_adj.mat', '-struct','RS_V1adj_struct');
save('V1_nbs_BG_adj.mat', '-struct','BG_nbs_V1adj_struct');
save('V1_nbs_RS_adj.mat', '-struct','RS_nbs_V1adj_struct');
save('V2_BG_adj.mat', '-struct','BG_V2adj_struct');
save('V2_RS_adj.mat', '-struct','RS_V2adj_struct');
save('V2_nbs_BG_adj.mat', '-struct','BG_nbs_V2adj_struct');
save('V2_nbs_RS_adj.mat', '-struct','RS_nbs_V2adj_struct');
