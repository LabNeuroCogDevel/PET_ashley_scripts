%% tools
clc
clear all;

% functional matlab
paren = @(x, varargin) x(varargin{:});
curly = @(x, varargin) x{varargin{:}};
addpath('/opt/ni_tools/matlab_toolboxes/') %loessline
addpath('/Volumes/Hera-3/Projects/RestDB/')

%pull in rest data
study = 'pet';
atlas = 'vmpfcstrvta20181221'; 
dbcn = sqlite('/Volumes/Hera-3/Projects/RestDB/rest.db');
tbl = get_rest(dbcn,'ses.study like "PET" and atlas like "vmpfcstrvta20181221"');

% Understanding what var names mean in the massive data table: 
%the naming convention for most imaging measure... 
%measure type_atlas_region e.g., there's also mr_rew_cic_accumbens... mr=type, rew=specific variable (reward response), cic=atlas, accumbens=region
%e.g., srtmdyn_modelbp_cic_accumbens
%srtmdyn is the name we use for the model (SRTM=simplified reference tissue model, dyn=dynamic, i.e., task-effect)
%modelbp = BP as estimated by that model
%cic = atlas
%accumbens = obv
%% read in data
% find file, get info from name (id and date)
adj = dir('/Volumes/Phillips/mMR_PETDA/subjs/*/func/*_vmpfc_striatal_vta_ts_adj_pearson.txt');
info=cellfun(@(x) strsplit(x,'_'), {adj.name}, 'UniformOutput',0);

% vectors of important info
lunaid= cellfun( @(x) x{1}, info,'UniformOutput',0)';
vdate = cellfun( @(x) datetime(x{2}, 'InputFormat','yyyyMMdd'), info)';
files = arrayfun(@(x) fullfile(x.folder,x.name), adj, 'UniformOutput',0);

% get a big table from merge pet
alldata = readtable('/Volumes/Phillips/mMR_PETDA/scripts/merged_data.csv',...
    'TreatAsEmpty',{'NA'});
mergepet = alldata(:, ismember(alldata.Properties.VariableNames, ...
    {'lunaid','vdate','visitnum','age','sex','srtmdyn_gamma_cic_accumbens','srtmdyn_modelbp_cic_accumbens','mr_rew_cic_accumbens',...
    'fdstat_funcmean','perf_num_diff','perf_pctoptblock1','perf_pctoptblock2','perf_pctoptblock3',...
    'perf_pctoptblock4','perf_pctoptblock5','perf_pctoptblock6'}));
% fix date for bad subject
mergepet.vdate{cellfun(@(x) strncmp('20172018',x,8), mergepet.vdate)} = '20170218';
% convert strings to dates
mergepet.vdate = cellfun(@(x) datetime(x,'InputFormat','yyyyMMdd'), mergepet.vdate);
% and ids to strings
mergepet.lunaid = arrayfun(@num2str, mergepet.lunaid, 'UniformOutput',0);

%AP2019 - add inverse age
for ii= 1:length(mergepet.age)
    mergepet.inv_age(ii)=1/mergepet.age(ii);
end

% merge info into 1 table
T = table(lunaid,vdate,files);
T = innerjoin(T,mergepet);

%% Separate the data into visit 1-3
V1 = T; %visit1
V2 = T; %visit2
V3 = T; %visit3
% get inds for subs in visit 1-3
V1_inds=find(V1.visitnum==1); 
V1=V1(V1_inds,:);
V2_inds=find(V2.visitnum==2);
V2=V2(V2_inds,:);
V3_inds=find(V3.visitnum==3);
V3=V3(V3_inds,:);
%writetable(V1,'/Users/lncd/Documents/Projects/VTA-VMPFC/V1_datatable.xlsx') %write as excel table to input into R
%writetable(V2,'/Users/lncd/Documents/Projects/VTA-VMPFC/V2_datatable.xlsx') %write as excel table to input into R

% read in all the adjacency files for BG connectivity
V1adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V1.files,'UniformOutput',0);
V2adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V2.files,'UniformOutput',0);
V3adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    V3.files,'UniformOutput',0);

%Reorganize/reorder session 1 & session 2 for the rest data
%for each subject, go in and get their session dates first. Then index
%session 1 and session 2, then pull in both of their adjacency matrices (gsr/non-gsr).
info1 = tbl(:, ismember(tbl.Properties.VariableNames, ...
    {'subj','age','sex','ses_id','preproc','adj_file'}));

info1.new_ses= erase(info1.ses_id, "_");

info1.new_ses=str2num(cell2mat(info1.new_ses)); %convert dates to numeric values because a. i hate strings and b. i hate cell arrays
sub_inds=unique(info1.subj);

for i = 1:length(sub_inds)
    inds=find(strcmp(info1.subj,sub_inds(i))); %4 wonky
    sub_table=info1(inds,:); %pulls out/cats all rows with this sub ID
    ses_dates=unique(sub_table.new_ses); %pulls out unique ses_dates
    [~,p]=sort(ses_dates,'ascend'); %p=1 is visit 1, p=2 is visit 2
    V1_date=ses_dates(p(1));
    %pull out all rows in table where V1_date matches
    V1_inds=find(sub_table.new_ses==V1_date);
    
    % Decide what you want to look at - Rac1 OR mean of Rac1&Rac2, but not
    % Rac2 alone also, use GSR.
    
    rac1_gsr_inds=find(strcmp(sub_table.preproc,'aroma_gsr') & contains(sub_table.adj_file, "rac1"));
    V1_rac1gsr_adj_file{i,1}=cell2mat(sub_table.adj_file(intersect(V1_inds,rac1_gsr_inds)));
    V1_rac1gsr_adj_file2{1}=cell2mat(sub_table.adj_file(intersect(V1_inds,rac1_gsr_inds)));
    rest_V1(i,:)=table(sub_table.subj(V1_inds(1)), sub_table.age(V1_inds(1)), sub_table.sex(V1_inds(1)), V1_date, V1_rac1gsr_adj_file2)
    %might be something up with this... not sure why V2 stuff is almost as
    %long as V1 stuff...
    if length(p)>1
        V2_date=ses_dates(p(2));
        V2_inds=find(sub_table.new_ses==V2_date);
        V2_rac1gsr_adj_file{i,1}=cell2mat(sub_table.adj_file(intersect(V2_inds,rac1_gsr_inds)));
        V2_rac1gsr_adj_file2{1}=cell2mat(sub_table.adj_file(intersect(V2_inds,rac1_gsr_inds)));
    rest_V2(i,:)=table(sub_table.subj(V2_inds(1)), sub_table.age(V2_inds(1)), sub_table.sex(V2_inds(1)), V2_date, V2_rac1gsr_adj_file2)
    end
end
rest_V1.Properties.VariableNames= {'lunaid','age','sex','vdate','files'};
rest_V2.Properties.VariableNames= {'lunaid','age','sex','vdate','files'};
%way to remove empty things 
empty_inds=cellfun('isempty',rest_V1.files)
rest_V1(empty_inds,:)=[];
empty_inds2=cellfun('isempty',rest_V2.files)
rest_V2(empty_inds2,:)=[];
%V2_rac1gsr_adj_file=V2_rac1gsr_adj_file(~cellfun('isempty',V2_rac1gsr_adj_file));

% read in all the adjacency files for rest connectivity
%restV1adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
%    adj_,'UniformOutput',0);
restV1adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    rest_V1.files,'UniformOutput',0);
restV2adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
    rest_V2.files,'UniformOutput',0);
%restV3adj_ = cellfun(@(x) table2array(readtable(x,'TreatAsEmpty',{'NA'})), ...
%    RV3adj_,'UniformOutput',0);

%find indices in V1 for individuals who have completed V2
keep_ind=find(ismember(V2.lunaid, V1.lunaid));
V2 = V2(keep_ind,:);
[id,loc]=intersect(V1.lunaid, V2.lunaid); %indices in ***V1*** for IDs in V2******

%create labels for ROIs (in order) AP
ROI_NAMES= {'L Ant. med. OFC 1','L Post. med. OFC 1','L Ant. VMPFC','L Post. med. OFC 2','L Ant. med. OFC 2',...
    'L Vent. ACC','L Subg. cingulate','L Rostr. ACC','R Ant. med. OFC 1','R Post. med. OFC 1','R Ant. VMPFC',...
    'R Post. med. OFC 2','R Ant. med. OFC 2','R Vent. ACC','R Subg. cingulate','R Rostr. ACC', 'L Caudate',...
    'L NAC','L Putamen','R Caudate','R NAC','R Putamen','VTA'};

%% reshape
% dimensions
roi_mat_size = size(V1adj_{1}); %for V1 only
idx = tril(ones(roi_mat_size), -1)==1; % only use below lower diag
[i,j] = ind2sub(roi_mat_size,find(idx)); %i j value of each edge. Which two ROIs.
% extract only the unique values from each adj matrix
long = cell2mat(cellfun(@(x) paren(x,idx)', V1adj_, 'UniformOutput', 0));

%% Set up models for age, pet, vstr

% Need to include sex, motion in here as fixed effects too eventually

age_model=cell(1,size(long,2)); % model connectivity pairs as a function of age
bline_pet_model=cell(1,size(long,2)); % model connectivity pairs as a function of baseline NAC PET including age, sex, motion as fixed factor
task_pet_model=cell(1,size(long,2)); % model connectivity pairs as a function of task NAC PET including age, sex, motion as fixed factor
rew_mr_model=cell(1,size(long,2)); % model connectivity pairs as a function of vSTR MR reward including age, sex, motion as fixed factor

for edgei = 1:size(long,2)
    V1.cor = long(:,edgei); % update the roi we are using each iteration
    %  often have too many NaN so model will fail -- hence the try/catch
    try
        % INVERSE AGE can change to age proper:
        age_model{edgei} = fitlme(V1,'cor ~ inv_age'); %no random effect (yet). Age as a function of correlation here.
        bline_pet_model{edgei} = fitlme(V1,'cor ~ srtmdyn_modelbp_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        task_pet_model{edgei} = fitlme(V1,'cor ~ srtmdyn_gamma_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        rew_mr_model{edgei} = fitlme(V1,'cor ~ mr_rew_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.

        %bline_pet_model{edgei} = fitlme(V1,'cor ~ inv_age*srtmdyn_modelbp_cic_accumbens + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        %model3{edgei} = fitlme(V1,'cor ~ inv_age*mr_rew_cic_accumbens + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        %model3{edgei} = fitlme(V1,'cor ~ mr_rew_cic_accumbens'); %no random effect (yet). Age as a function of correlation here.
    catch e
        fprintf('failed to model cor: %d (%d<->%d): %s\n', ...
            edgei, i(edgei), j(edgei), e.message);
    end
end


%% plot individual pair correlations that are significant for AGE
age_mat = zeros(roi_mat_size);

for edgei = 1:size(long,2)
    m1 = age_model{edgei};
    if isempty(m1), continue, end
    p1 = m1.Coefficients.pValue(2);
    age_mat(i(edgei), j(edgei)) = log10(p1);
    %title('Significant age correlations')
    if p1 < .001
        figure(edgei)
        % INVERSE AGE can change to age proper:
        title(sprintf('%d by %d: p = %.7f',i(edgei), j(edgei),p1))
        %title(ROI_NAMES{i(edgei)}, ROI_NAMES{j(edgei)},sprintf(':p = %.7f',i(edgei), j(edgei),p1))
        hold on;
        plot(m1.Variables.age,m1.Variables.cor,'.'); %Plot age by correlation
        loessline;
        h=lsline;
        h.LineStyle = '--';
    end
end

%for xx = 1:23
%    disp(model1{i==23 & j ==xx}.Rsquared)% Which edges for the model look significant - display info.
%end
%% plot individual pair correlations that are significant for baseline PET
bline_pet_mat = zeros(roi_mat_size);

for edgei = 1:size(long,2)
    m2 = bline_pet_model{edgei};
    if isempty(m2), continue, end
    p2 = m2.Coefficients.pValue(3);
    bline_pet_mat(i(edgei), j(edgei)) = log10(p2);
    %title('Significant age correlations')
    if p2 < .05
        figure(edgei)
        % INVERSE AGE can change to age proper:
        title(sprintf('%d by %d: p = %.7f',i(edgei), j(edgei),p2))
        %title(ROI_NAMES{i(edgei)}, ROI_NAMES{j(edgei)},sprintf(':p = %.7f',i(edgei), j(edgei),p1))
        hold on;
        plot(m2.Variables.srtmdyn_modelbp_cic_accumbens,m2.Variables.cor,'.'); %Plot age by correlation
        loessline;
        h=lsline;
        h.LineStyle = '--';
    end
end

%% plot individual pair correlations that are significant for task PET
task_pet_mat = zeros(roi_mat_size);

for edgei = 1:size(long,2)
    m3 = task_pet_model{edgei};
    if isempty(m3), continue, end
    p3 = m3.Coefficients.pValue(3);
    task_pet_mat(i(edgei), j(edgei)) = log10(p3);
    %title('Significant age correlations')
    if p3 < .05
        figure(edgei)
        % INVERSE AGE can change to age proper:
        title(sprintf('%d by %d: p = %.7f',i(edgei), j(edgei),p3))
        %title(ROI_NAMES{i(edgei)}, ROI_NAMES{j(edgei)},sprintf(':p = %.7f',i(edgei), j(edgei),p1))
        hold on;
        plot(m3.Variables.srtmdyn_gamma_cic_accumbens,m3.Variables.cor,'.'); %Plot age by correlation
        loessline;
        h=lsline;
        h.LineStyle = '--';
    end
end

%% plot individual pair correlations that are significant for rew Bold signal

rew_mr_mat = zeros(roi_mat_size);

for edgei = 1:size(long,2)
    m4 = rew_mr_model{edgei};
    if isempty(m4), continue, end
    p4 = m4.Coefficients.pValue(3);
    rew_mr_mat(i(edgei), j(edgei)) = log10(p4);
    %title('Significant age correlations')
    if p4 < .05
        figure(edgei)
        % INVERSE AGE can change to age proper:
        title(sprintf('%d by %d: p = %.7f',i(edgei), j(edgei),p4))
        %title(ROI_NAMES{i(edgei)}, ROI_NAMES{j(edgei)},sprintf(':p = %.7f',i(edgei), j(edgei),p1))
        hold on;
        plot(m4.Variables.mr_rew_cic_accumbens,m4.Variables.cor,'.'); %Plot age by correlation
        loessline;
        h=lsline;
        h.LineStyle = '--';
    end
end

%% PLOT ALL CORRELATION MATRICES IN ONE FIGURE

figure;
subplot(2,2,1)
im = imagesc(age_mat);
xticks([1:23]);
xticklabels(ROI_NAMES);
xtickangle(45)
yticks([1:23]);
yticklabels(ROI_NAMES);
set(gca,'TickDir','out');
title('Correlations with AGE')
axis square
hold on;

subplot(2,2,2)
im = imagesc(bline_pet_mat);
xticks([1:23]);
xticklabels(ROI_NAMES);
xtickangle(45)
yticks([1:23]);
yticklabels(ROI_NAMES);
set(gca,'TickDir','out');
title('Correlations with baseline NAC BP')
axis square

subplot(2,2,3)
im = imagesc(task_pet_mat);
xticks([1:23]);
xticklabels(ROI_NAMES);
xtickangle(45)
yticks([1:23]);
yticklabels(ROI_NAMES);
set(gca,'TickDir','out');
title('Correlations with task NAC BP')
axis square

subplot(2,2,4)
im = imagesc(rew_mr_mat);
xticks([1:23]);
xticklabels(ROI_NAMES);
xtickangle(45)
yticks([1:23]);
yticklabels(ROI_NAMES);
set(gca,'TickDir','out');
title('Correlations with BOLD rew signal')
axis square

%% FOR FINN (originally) TO PLOT INTERESTING ROI PAIRS AND THEIR CORRELATIONS
figure(68768);

subplot(1,2,1)
m=age_model{i==23 & j ==2};
title(sprintf('VTA-Posterior Medial OFC pair (N subs=144), p= %.5f',m.Coefficients.pValue(2)),'fontsize',22)
hold on;
plot(m.Variables.age,m.Variables.cor,'o','MarkerSize',3,'MarkerFaceColor','b','MarkerEdgeColor','none');
%loessline;
lsline;
xlabel('Age','fontsize',18);
ylabel('Correlation','fontsize',18);
set(gca,'TickDir','out','fontsize',15);
axis square
hold on;

subplot(1,2,2)
m3=task_pet_model{i==23 & j ==2};
title(sprintf('VTA-Posterior Medial OFC pair (N subs=82), p= %.5f',m3.Coefficients.pValue(3)),'fontsize',22)
hold on;
plot(m3.Variables.srtmdyn_gamma_cic_accumbens,m3.Variables.cor,'o','MarkerSize',3,'MarkerFaceColor','b','MarkerEdgeColor','none');
%loessline;
lsline;
xlabel('Accumbens PET','fontsize',18);
ylabel('Correlation','fontsize',18);
set(gca,'TickDir','out','fontsize',15);
xlim([-0.4,0.2])
axis square
hold on;

%% To recreate Finn's VS fig

model= fitlme(V1,'inv_age ~ mr_rew_cic_accumbens');
figure;
title(sprintf('AGE BY MR Accumbens Rew Signal, p= %.5f', model.Coefficients.pValue(2)), 'fontsize',22)
hold on;
plot(V1.age,V1.mr_rew_cic_accumbens,'o','MarkerFaceColor','k','MarkerEdgeColor','none')
loessline;
h=lsline;
h.LineStyle = '--';
xlabel('Age','fontsize',18);
ylabel('MR Accumbens Rew Signal','fontsize',18);
set(gca,'TickDir','out','fontsize',15);
axis square
hold on;

%% create difference scores for visit 1 & visit 2 for various variables.
diff_table = V2(:, ismember(V2.Properties.VariableNames, ...
    {'lunaid','sex'}));

for ii = 1:length(loc)
    diff_table.diff_age(ii) = V2.age(ii) - V1.age(loc(ii));
    diff_table.diff_mr_rew_cic_accumbens(ii) = V2.mr_rew_cic_accumbens(ii) - V1.mr_rew_cic_accumbens(loc(ii));
    diff_table.diff_perf_num_diff(ii) = V2.perf_num_diff(ii) - V1.perf_num_diff(loc(ii));
    diff_table.diff_perf_pctoptblock1(ii) = V2.perf_pctoptblock1(ii) - V1.perf_pctoptblock1(loc(ii));
    diff_table.diff_perf_pctoptblock2(ii) = V2.perf_pctoptblock2(ii) - V1.perf_pctoptblock2(loc(ii));
    diff_table.diff_perf_pctoptblock3(ii) = V2.perf_pctoptblock3(ii) - V1.perf_pctoptblock3(loc(ii));
    diff_table.diff_perf_pctoptblock4(ii) = V2.perf_pctoptblock4(ii) - V1.perf_pctoptblock4(loc(ii));
    diff_table.diff_perf_pctoptblock5(ii) = V2.perf_pctoptblock5(ii) - V1.perf_pctoptblock5(loc(ii));
    diff_table.diff_perf_pctoptblock6(ii) = V2.perf_pctoptblock6(ii) - V1.perf_pctoptblock6(loc(ii));
    diff_table.diff_srtmdyn_gamma_cic_accumbens(ii) = V2.srtmdyn_gamma_cic_accumbens(ii) - V1.srtmdyn_gamma_cic_accumbens(loc(ii));
    diff_table.diff_srtmdyn_modelbp_cic_accumbens(ii) = V2.srtmdyn_modelbp_cic_accumbens(ii) - V1.srtmdyn_modelbp_cic_accumbens(loc(ii));
    
end
%Plot some things
%plot(diff_table.diff_srtmdyn_gamma_cic_accumbens, diff_table.diff_mr_rew_cic_accumbens,'ok')
%idx = strcmp(V1.sex(loc(ii)),'F')

%% See if baseline BP & task BP correlates with age
bad_sub = find(V1.srtmdyn_gamma_cic_accumbens<=-.5);
V1_nobadsub=V1;
V1_nobadsub(bad_sub,:)=[];
find(V1_nobadsub.srtmdyn_gamma_cic_accumbens<=-.5);

model= fitlme(V1_nobadsub,'inv_age ~ srtmdyn_gamma_cic_accumbens'); %no random effect (yet). Age as a function of correlation here.
model2= fitlme(V1_nobadsub,'age ~ srtmdyn_gamma_cic_accumbens'); %no random effect (yet). Age as a function of correlation here.
model3= fitlme(V1,'inv_age ~ srtmdyn_modelbp_cic_accumbens'); %no random effect (yet). Age as a function of correlation here.
model4= fitlme(V1,'age ~ srtmdyn_modelbp_cic_accumbens'); %no random effect (yet). Age as a function of correlation here.

figure;
subplot(2,2,1)
title(sprintf('INVERSE AGE BY task BP Accumbens, p= %.5f', model.Coefficients.pValue(2)), 'fontsize',22)
hold on;
plot(V1_nobadsub.inv_age,V1_nobadsub.srtmdyn_gamma_cic_accumbens,'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%loessline;
h=lsline;
h.LineStyle = '--';
xlabel('Inv Age','fontsize',18);
ylabel('Task BP Accumbens','fontsize',18);
set(gca,'TickDir','out','fontsize',15);
axis square
hold on;

subplot(2,2,2)
title(sprintf('AGE BY task BP Accumbens, p= %.5f', model2.Coefficients.pValue(2)), 'fontsize',22)
hold on;
plot(V1_nobadsub.age,V1_nobadsub.srtmdyn_gamma_cic_accumbens,'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%loessline;
h=lsline;
h.LineStyle = '--';
xlabel('Age','fontsize',18);
ylabel('Task BP Accumbens','fontsize',18);
set(gca,'TickDir','out','fontsize',15);
axis square
hold on;

subplot(2,2,3)
title(sprintf('INVERSE AGE BY baseline BP Accumbens, p= %.5f', model3.Coefficients.pValue(2)), 'fontsize',22)
hold on;
plot(V1.inv_age,V1.srtmdyn_modelbp_cic_accumbens,'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%loessline;
h=lsline;
h.LineStyle = '--';
xlabel('Inv Age','fontsize',18);
ylabel('Baseline BP Accumbens','fontsize',18);
set(gca,'TickDir','out','fontsize',15);
axis square
hold on;

subplot(2,2,4)
title(sprintf('AGE BY baseline BP Accumbens, p= %.5f', model4.Coefficients.pValue(2)), 'fontsize',22)
hold on;
plot(V1.age,V1.srtmdyn_modelbp_cic_accumbens,'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%loessline;
h=lsline;
h.LineStyle = '--';
xlabel('Age','fontsize',18);
ylabel('Baseline BP Accumbens','fontsize',18);
set(gca,'TickDir','out','fontsize',15);
axis square
hold on;
 

% Look at diff between V1 & V2 
model= fitlme(V1,'inv_age ~ mr_rew_cic_accumbens'); %no random effect (yet). Age as a function of correlation here.

figure;
for ii = 1:length(loc)
    idx(ii) = strcmp(V1.sex(loc(ii)),'F');
    if idx(ii)==1
        plot([V1.age(loc(ii)) V2.age(ii)], ([V1.mr_rew_cic_accumbens(loc(ii)) V2.mr_rew_cic_accumbens(ii)]),'.r-')
        hold on;
    elseif idx(ii)==0
        plot([V1.age(loc(ii)) V2.age(ii)], ([V1.mr_rew_cic_accumbens(loc(ii)) V2.mr_rew_cic_accumbens(ii)]),'.b-')
        hold on;
    end
end

%% To check out behavioral performance as a f'n of striatal bold signal - under construction.
model= fitlme(V1_nobadsub,'mr_rew_cic_accumbens ~ srtmdyn_gamma_cic_accumbens'); %no random effect (yet). Age as a function of correlation here.
model2= fitlme(V1_nobadsub,'mr_rew_cic_accumbens ~ srtmdyn_modelbp_cic_accumbens'); %no random effect (yet). Age as a function of correlation here.

figure;
subplot(1,2,1)
title(sprintf('mr rew signal by task BP Accumbens, p= %.5f', model.Coefficients.pValue(2)), 'fontsize',22)
hold on;
plot(V1_nobadsub.mr_rew_cic_accumbens,V1_nobadsub.srtmdyn_gamma_cic_accumbens,'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%loessline;
h=lsline;
h.LineStyle = '--';
xlabel('MR rew signal','fontsize',18);
ylabel('Task BP Accumbens','fontsize',18);
set(gca,'TickDir','out','fontsize',15);
axis square
hold on;

subplot(1,2,2)
title(sprintf('mr rew signal by baseline BP Accumbens, p= %.5f', model2.Coefficients.pValue(2)), 'fontsize',22)
hold on;
plot(V1.mr_rew_cic_accumbens,V1.srtmdyn_modelbp_cic_accumbens,'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%loessline;
h=lsline;
h.LineStyle = '--';
xlabel('MR rew signal','fontsize',18);
ylabel('baseline BP Accumbens','fontsize',18);
set(gca,'TickDir','out','fontsize',15);
axis square
hold on;

%diff_taskbp=V1_nobadsub.srtmdyn_modelbp_cic_accumbens-V1_nobadsub.srtmdyn_gamma_cic_accumbens
%plot(V1_nobadsub.mr_rew_cic_accumbens,diff_taskbp,'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%model= fitlme(V1_nobadsub,'mr_rew_cic_accumbens ~ diff_taskbp'); %no random effect (yet). Age as a function of correlation here.
%V1_nobadsub.diff_taskbp=diff_taskbp;

figure;
subplot(2,3,1)
plot(T.perf_pctoptblock1, T.mr_rew_cic_accumbens, 'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%model= fitlme(T,'perf_pctoptblock1 ~ mr_rew_cic_accumbens')
subplot(2,3,2)
plot(T.perf_pctoptblock2, T.mr_rew_cic_accumbens, 'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%model= fitlme(T,'perf_pctoptblock2 ~ mr_rew_cic_accumbens')
subplot(2,3,3)
plot(T.perf_pctoptblock3, T.mr_rew_cic_accumbens, 'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%model= fitlme(T,'perf_pctoptblock3 ~ mr_rew_cic_accumbens')
subplot(2,3,4)
plot(T.perf_pctoptblock4, T.mr_rew_cic_accumbens, 'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%model= fitlme(T,'perf_pctoptblock4 ~ mr_rew_cic_accumbens')
subplot(2,3,5)
plot(T.perf_pctoptblock5, T.mr_rew_cic_accumbens, 'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%model= fitlme(T,'perf_pctoptblock5 ~ mr_rew_cic_accumbens')
subplot(2,3,6)
plot(T.perf_pctoptblock6, T.mr_rew_cic_accumbens, 'o','MarkerFaceColor','k','MarkerEdgeColor','none')
%model= fitlme(T,'perf_pctoptblock6 ~ mr_rew_cic_accumbens')
