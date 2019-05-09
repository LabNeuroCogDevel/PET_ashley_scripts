%% tools
% A script to look at RS connectivity and BG connectivity in relation to
% age, RT18, Intolerance scale, etc. 
clc
clear all;
addpath('/opt/ni_tools/matlab_toolboxes/') %loessline

parentfolder = 'Volumes/Phillips/mMR_PETDA/analysis_ashley/';
%cd(parentfolder)
[fn,pn]=uigetfile('*.mat','Locate the Data File!!!');
load([pn,fn]); 

%% Reshape Matrices
RS_roi_mat_size = size(RS_nbs_V1adj_{1}); %for V1 only
idx_RS = tril(ones(RS_roi_mat_size), -1)==1; % only use below lower diag
[i,j] = ind2sub(RS_roi_mat_size,find(idx_RS)); %i j value of each edge. Which two ROIs.
% extract only the unique values from each adj matrix
long1 = cell2mat(cellfun(@(x) paren(x,idx_RS)', RS_nbs_V1adj_, 'UniformOutput', 0));

BG_roi_mat_size = size(BG_nbs_V1adj_{1}); %for V1 only
idx_BG = tril(ones(BG_roi_mat_size), -1)==1; % only use below lower diag
[i,j] = ind2sub(BG_roi_mat_size,find(idx_BG)); %i j value of each edge. Which two ROIs.
% extract only the unique values from each adj matrix
long2 = cell2mat(cellfun(@(x) paren(x,idx_BG)', BG_nbs_V1adj_, 'UniformOutput', 0));

%% Set up models for age, pet, vstr
RT18_age_model = fitlme(V1_REST_nbs,'RT_18_Score ~ inv_age'); %no random effect (yet). Age as a function of correlation here.
RT18_bline_pet_model = fitlme(V1_REST_nbs,'RT_18_Score ~ srtmdyn_modelbp_cic_accumbens + inv_age + sex'); %no random effect (yet). Age as a function of correlation here.
RT18_task_pet_model = fitlme(V1_REST_nbs,'RT_18_Score ~ srtmdyn_gamma_cic_accumbens + inv_age + sex'); %no random effect (yet). Age as a function of correlation here.
RT18_rew_mr_model = fitlme(V1_REST_nbs,'RT_18_Score ~ mr_rew_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
RT18_perf_num_diff = fitlme(V1_REST_nbs,'RT_18_Score ~ perf_num_diff + inv_age + sex');
RT18_average_perf = fitlme(V1_REST_nbs,'RT_18_Score ~ average_perf + inv_age + sex');

Int_total_age_model = fitlme(V1_REST_nbs,'Intolerance_Total ~ inv_age'); %no random effect (yet). Age as a function of correlation here.
Int_total_bline_pet_model = fitlme(V1_REST_nbs,'Intolerance_Total ~ srtmdyn_modelbp_cic_accumbens + inv_age + sex'); %no random effect (yet). Age as a function of correlation here.
Int_total_task_pet_model = fitlme(V1_REST_nbs,'Intolerance_Total ~ srtmdyn_gamma_cic_accumbens + inv_age + sex'); %no random effect (yet). Age as a function of correlation here.
Int_total_rew_mr_model = fitlme(V1_REST_nbs,'Intolerance_Total ~ mr_rew_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
Int_total_perf_num_diff = fitlme(V1_REST_nbs,'Intolerance_Total ~ perf_num_diff + inv_age + sex');
Int_total_average_perf = fitlme(V1_REST_nbs,'Intolerance_Total ~ average_perf + inv_age + sex');

Int_Prosp_anx_age_model = fitlme(V1_REST_nbs,'Intolerance_Prospective_Anxiety ~ inv_age'); %no random effect (yet). Age as a function of correlation here.
Int_Prosp_anx_bline_pet_model = fitlme(V1_REST_nbs,'Intolerance_Prospective_Anxiety ~ srtmdyn_modelbp_cic_accumbens + inv_age + sex'); %no random effect (yet). Age as a function of correlation here.
Int_Prosp_anx_task_pet_model = fitlme(V1_REST_nbs,'Intolerance_Prospective_Anxiety ~ srtmdyn_gamma_cic_accumbens + inv_age + sex'); %no random effect (yet). Age as a function of correlation here.
Int_Prosp_anx_rew_mr_model = fitlme(V1_REST_nbs,'Intolerance_Prospective_Anxiety ~ mr_rew_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
Int_Prosp_anx_perf_num_diff = fitlme(V1_REST_nbs,'Intolerance_Prospective_Anxiety ~ perf_num_diff + inv_age + sex');
Int_Prosp_anx_average_perf = fitlme(V1_REST_nbs,'Intolerance_Prospective_Anxiety ~ average_perf + inv_age + sex');

Int_Inhib_anx_age_model = fitlme(V1_REST_nbs,'Intolerance_Inhibitory_Anxiety ~ inv_age'); %no random effect (yet). Age as a function of correlation here.
Int_Inhib_anx_bline_pet_model = fitlme(V1_REST_nbs,'Intolerance_Inhibitory_Anxiety ~ srtmdyn_modelbp_cic_accumbens + inv_age + sex'); %no random effect (yet). Age as a function of correlation here.
Int_Inhib_anx_task_pet_model = fitlme(V1_REST_nbs,'Intolerance_Inhibitory_Anxiety ~ srtmdyn_gamma_cic_accumbens + inv_age + sex'); %no random effect (yet). Age as a function of correlation here.
Int_Inhib_anx_rew_mr_model = fitlme(V1_REST_nbs,'Intolerance_Inhibitory_Anxiety ~ mr_rew_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
Int_Inhib_anx_perf_num_diff = fitlme(V1_REST_nbs,'Intolerance_Inhibitory_Anxiety ~ perf_num_diff + inv_age + sex');
Int_Inhib_anx_average_perf = fitlme(V1_REST_nbs,'Intolerance_Inhibitory_Anxiety ~ average_perf + inv_age + sex');

RS_age_model=cell(1,size(long1,2)); % model connectivity pairs as a function of age
RS_inv_age_model=cell(1,size(long1,2)); % model connectivity pairs as a function of age

RS_bline_pet_model=cell(1,size(long1,2)); % model connectivity pairs as a function of baseline NAC PET including age, sex, motion as fixed factor
RS_task_pet_model=cell(1,size(long1,2)); % model connectivity pairs as a function of task NAC PET including age, sex, motion as fixed factor
RS_rew_mr_model=cell(1,size(long1,2)); % model connectivity pairs as a function of vSTR MR reward including age, sex, motion as fixed factor
RS_RT18_model=cell(1,size(long1,2));
RS_Int_Prosp_anx_model=cell(1,size(long1,2));
RS_Int_Inhib_anx_model=cell(1,size(long1,2));
RS_Int_Total_model=cell(1,size(long1,2));
RS_perf_num_diff_model=cell(1,size(long1,2));
RS_average_perf_model=cell(1,size(long1,2));

BG_age_model=cell(1,size(long2,2)); % model connectivity pairs as a function of age
BG_inv_age_model=cell(1,size(long2,2)); % model connectivity pairs as a function of age
BG_bline_pet_model=cell(1,size(long2,2)); % model connectivity pairs as a function of baseline NAC PET including age, sex, motion as fixed factor
BG_task_pet_model=cell(1,size(long2,2)); % model connectivity pairs as a function of task NAC PET including age, sex, motion as fixed factor
BG_rew_mr_model=cell(1,size(long2,2)); % model connectivity pairs as a function of vSTR MR reward including age, sex, motion as fixed factor
BG_RT18_model=cell(1,size(long2,2));
BG_Int_Prosp_anx_model=cell(1,size(long2,2));
BG_Int_Inhib_anx_model=cell(1,size(long2,2));
BG_Int_Total_model=cell(1,size(long2,2));
BG_perf_num_diff_model=cell(1,size(long2,2));
BG_average_perf_model=cell(1,size(long2,2));

for edgei = 1:size(long1,2)
    V1_REST_nbs.cor = long1(:,edgei); % update the roi we are using each iteration
    V1_BG_nbs.cor = long2(:,edgei); % update the roi we are using each iteration
%  often have too many NaN so model will fail -- hence the try/catch
    try
        % INVERSE AGE can change to age proper:
        RS_inv_age_model{edgei} = fitlme(V1_REST_nbs,'cor ~ inv_age'); %no random effect (yet). Age as a function of correlation here.
        RS_age_model{edgei} = fitlme(V1_REST_nbs,'cor ~ age'); %no random effect (yet). Age as a function of correlation here.
        RS_bline_pet_model{edgei} = fitlme(V1_REST_nbs,'cor ~ srtmdyn_modelbp_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        RS_task_pet_model{edgei} = fitlme(V1_REST_nbs,'cor ~ srtmdyn_gamma_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        RS_rew_mr_model{edgei} = fitlme(V1_REST_nbs,'cor ~ mr_rew_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        RS_RT18_model{edgei} = fitlme(V1_REST_nbs,'cor ~ RT_18_Score + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        RS_Int_Prosp_anx_model{edgei} = fitlme(V1_REST_nbs,'cor ~ Intolerance_Prospective_Anxiety + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        RS_Int_Inhib_anx_model{edgei} = fitlme(V1_REST_nbs,'cor ~ Intolerance_Inhibitory_Anxiety + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        RS_Int_Total_anx_model{edgei} = fitlme(V1_REST_nbs,'cor ~ Intolerance_Total + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        RS_perf_num_diff_model{edgei} = fitlme(V1_REST_nbs,'cor ~ perf_num_diff + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        RS_average_perf_model{edgei} = fitlme(V1_REST_nbs,'cor ~ average_perf + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.   

        BG_inv_age_model{edgei} = fitlme(V1_BG_nbs,'cor ~ inv_age'); %no random effect (yet). Age as a function of correlation here.
        BG_age_model{edgei} = fitlme(V1_BG_nbs,'cor ~ age'); %no random effect (yet). Age as a function of correlation here.
        BG_bline_pet_model{edgei} = fitlme(V1_BG_nbs,'cor ~ srtmdyn_modelbp_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        BG_task_pet_model{edgei} = fitlme(V1_BG_nbs,'cor ~ srtmdyn_gamma_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        BG_rew_mr_model{edgei} = fitlme(V1_BG_nbs,'cor ~ mr_rew_cic_accumbens + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        BG_RT18_model{edgei} = fitlme(V1_BG_nbs,'cor ~ RT_18_Score + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        BG_Int_Prosp_anx_model{edgei} = fitlme(V1_BG_nbs,'cor ~ Intolerance_Prospective_Anxiety + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        BG_Int_Inhib_anx_model{edgei} = fitlme(V1_BG_nbs,'cor ~ Intolerance_Inhibitory_Anxiety + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        BG_Int_Total_anx_model{edgei} = fitlme(V1_BG_nbs,'cor ~ Intolerance_Total + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        BG_perf_num_diff_model{edgei} = fitlme(V1_BG_nbs,'cor ~ perf_num_diff + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.
        BG_average_perf_model{edgei} = fitlme(V1_BG_nbs,'cor ~ average_perf + inv_age + sex + fdstat_funcmean'); %no random effect (yet). Age as a function of correlation here.   

    catch e
        fprintf('failed to model cor: %d (%d<->%d): %s\n', ...
            edgei, i(edgei), j(edgei), e.message);
    end
end

%% set up a plotting function so that I don't have plot everything separately

%What do you want to look at? (age, task pet, baseline pet, mr reward)
RS_model=RS_inv_age_model; %RS_bline_pet_model  RS_task_pet_model RS_rew_mr_model RS_RT18_model RS_Int_Prosp_anx_model RS_Int_Inhibit_anx_model RS_Int_Total_anx_model Which model?
BG_model=BG_inv_age_model; %BG_bline_pet_model BG_task_pet_model BG_rew_mr_model BG_RT18_model BG_Int_Prosp_anx_model BG_Int_Inhibit_anx_model BG_Int_Total_anx_model Which model?
Var1= 'mRS.Variables.age'; % age srtmdyn_modelbp_cic_accumbens srtmdyn_gamma_cic_accumbens mr_rew_cic_accumbens RT_18_Score Intolerance_Prospective_Anxiety Intolerance_Inhibitory_Anxiety Intolerance_Total What do you want to plot
Var2= 'mBG.Variables.age'; % agesrtmdyn_modelbp_cic_accumbens srtmdyn_gamma_cic_accumbens mr_rew_cic_accumbens RT_18_Score Intolerance_Prospective_Anxiety Intolerance_Inhibitory_Anxiety Intolerance_Total What do you want to plot
xl='Age';
xl1='Age RS';
xl2='Age BG';
%RS_Matrix= RS_age_mat; %RS_bline_pet_mat RS_task_pet_mat RS_rew_mr_mat
%BG_Matrix= BG_age_mat; %BG_bline_pet_mat BG_task_pet_mat BG_rew_mr_mat
pval = 2; %which pvalue, if its age, 2, if anything else, 3 for the straight model. RT-18 is 5
%adjust = .2; %what number to adjust for text on figure, 6 for age, .2 for everything else
RS_Matrix = zeros(RS_roi_mat_size);
BG_Matrix = zeros(BG_roi_mat_size);
col=V1_REST_nbs.age;
col2=V1_BG_nbs.age;

for edgei = 1:size(long1,2)
    mRS = RS_model{edgei};
    mBG = BG_model{edgei};
    
    if isempty(mRS)||isempty(mBG), continue, end
    pRS = mRS.Coefficients.pValue(pval);
    pBG = mBG.Coefficients.pValue(pval);
    tRS = mRS.Coefficients.tStat(pval);
    tBG = mBG.Coefficients.tStat(pval);
    
    RS_Matrix(i(edgei), j(edgei)) = log10(pRS);
    BG_Matrix(i(edgei), j(edgei)) = log10(pBG);
    if pRS < .05 || pBG <.05
        figure(edgei)
        hold on;
        subplot(1,2,1)

        title(sprintf('t= %.3f, p= %.4f',tRS,pRS))
        ylabel(sprintf('%s by %s FC',ROI_NAMES{i(edgei)},ROI_NAMES{j(edgei)}))
        xlabel(xl)
        hold on;
        scatter(eval(Var1),mRS.Variables.cor,[],col,'filled','^')
        yline(0,':k');
        t = colorbar;
        set(get(t,'title'),'string','Age');
        axis square
        loessline;
        lsline;

        subplot(1,2,2)
        title(sprintf('t= %.3f, p= %.4f',tBG,pBG))
        ylabel(sprintf('%s by %s FC',ROI_NAMES{i(edgei)},ROI_NAMES{j(edgei)}))
        xlabel(xl)
        hold on;
        scatter(eval(Var2),mBG.Variables.cor,[],col2,'filled','o')
        yline(0,':k');
        t = colorbar;
        set(get(t,'title'),'string','Age');
        loessline;
        lsline;
        axis square;
    end
end

%Matrices
figure;
subplot(1,2,1)
im = imagesc(RS_Matrix);
xticks([1:23]);
xticklabels(ROI_NAMES);
xtickangle(45)
yticks([1:23]);
yticklabels(ROI_NAMES);
set(gca,'TickDir','out');
title(xl1)
axis square
hold on;

subplot(1,2,2)
im = imagesc(BG_Matrix);
xticks([1:23]);
xticklabels(ROI_NAMES);
xtickangle(45)
yticks([1:23]);
yticklabels(ROI_NAMES);
set(gca,'TickDir','out');
title(xl2)
axis square

m3=BG_age_model{i==23 & j ==21};

%23 & 21 VTA R NAC
%23 & 18 VTA L NAC

%% FOR FINN (originally) TO PLOT INTERESTING ROI PAIRS AND THEIR CORRELATIONS
%figure(68768);
i_val = 23; % VTA
j_val=1:22; %ALL ROIS
Var1= 'm.Variables.age'; % age srtmdyn_modelbp_cic_accumbens srtmdyn_gamma_cic_accumbens mr_rew_cic_accumbens RT_18_Score Intolerance_Prospective_Anxiety Intolerance_Inhibitory_Anxiety Intolerance_Total What do you want to plot
Var2= 'm2.Variables.age'; % agesrtmdyn_modelbp_cic_accumbens srtmdyn_gamma_cic_accumbens mr_rew_cic_accumbens RT_18_Score Intolerance_Prospective_Anxiety Intolerance_Inhibitory_Anxiety Intolerance_Total What do you want to plot
xl='Age';
pval=2;

for ii = 1:length(j_val)
    m=RS_inv_age_model{i==i_val & j==ii};
    m2=BG_inv_age_model{i==i_val & j==ii};
    if m.Coefficients.pValue(pval) < .05 || m2.Coefficients.pValue(pval) <.05
        figure(ii)
        subplot(1,2,1)
        title(sprintf('t=%.3f, p= %.5f',m.Coefficients.tStat(pval),m.Coefficients.pValue(pval)))
        ylabel(sprintf('%s by %s RS',ROI_NAMES{i_val},ROI_NAMES{ii}))
        xlabel(xl)
        hold on;
        scatter(eval(Var1),m.Variables.cor,[],col,'filled','^')
        yline(0,':k');
        t = colorbar;
        set(get(t,'title'),'string','Age');
        %colorbar
        axis square
        loessline;
        lsline;
        %set(gca,'TickDir','out','fontsize',15);
        %axis square
        hold on;
        
        subplot(1,2,2)
        title(sprintf('t=%.3f, p= %.5f',m2.Coefficients.tStat(pval),m2.Coefficients.pValue(pval)))
        ylabel(sprintf('%s by %s FC',ROI_NAMES{i_val},ROI_NAMES{ii}))
        xlabel(xl)
        hold on;
        scatter(eval(Var2),m2.Variables.cor,[],col2,'filled','o')
        yline(0,':k');
        t = colorbar;
        set(get(t,'title'),'string','Age');
        %colorbar
        axis square
        loessline;
        lsline;
        %set(gca,'TickDir','out','fontsize',15);
        %axis square
        hold on;
    end
end

%%  Plot stuff independently of its relationship with FC
plot_y={'RT_18_Score','Intolerance_Total','age','srtmdyn_modelbp_cic_accumbens', 'srtmdyn_gamma_cic_accumbens', 'mr_rew_cic_accumbens', 'perf_num_diff', 'average_perf'}; % V1_REST_nbs.RT_18_Score V1_REST_nbs.Intolerance_Prospective_Anxiety V1_REST_nbs.Intolerance_Inhibitory_Anxiety V1_REST_nbs.Intolerance_Total 
label_y={'RT 18','Uncertainty Scale','Age','Baseline BP','Task BP','MR Reward','Probe Performance','Average Performance'};
%plot_y={'average_perf'}; % V1_REST_nbs.RT_18_Score V1_REST_nbs.Intolerance_Prospective_Anxiety V1_REST_nbs.Intolerance_Inhibitory_Anxiety V1_REST_nbs.Intolerance_Total 
%label_y={'Average Performance'};
plot_x={'mr_rew_cic_accumbens'};%,V1_REST_nbs.srtmdyn_modelbp_cic_accumbens, V1_REST_nbs.srtmdyn_gamma_cic_accumbens,V1_REST_nbs.mr_rew_cic_accumbens, V1_REST_nbs.perf_num_diff, V1_REST_nbs.average_perf);%, V1_REST_nbs.Intolerance_Total; % age srtmdyn_modelbp_cic_accumbens srtmdyn_gamma_cic_accumbens mr_rew_cic_accumbens RT_18_Score Intolerance_Prospective_Anxiety Intolerance_Inhibitory_Anxiety Intolerance_Total 
label_x='MR Reward';
col=V1_REST_nbs.age;

for i=1:length(plot_y)
subplot(2,4,i)
model= fitlme(V1_REST_nbs,sprintf('%s ~ %s',plot_x{1},plot_y{i}));
title(sprintf('t= %.2f, p= %.2f', model.Coefficients.tStat(2),model.Coefficients.pValue(2)));
xlabel(label_x)
ylabel(label_y{i})
hold on;
scatter(V1_REST_nbs.(plot_x{1}),V1_REST_nbs.(plot_y{i}),[],col,'filled','o')
t = colorbar;
set(get(t,'title'),'string','Age');
loessline;
h=lsline;
h.LineStyle = '-';
%xlim([4 16])
set(gca,'TickDir','out')%,'fontsize',15);
axis square
hold on;
end
        
%scatter3(V1_REST_nbs.srtmdyn_modelbp_cic_accumbens,V1_REST_nbs.average_perf,V1_REST_nbs.age,'filled')
%xlabel('Baseline BP')
%ylabel('Performance')
%zlabel('age')
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


%% find indices in V1 for individuals who have completed V2
[id,loc]=intersect(V1_REST_nbs.lunaid, V2_nobadsub.lunaid); %indices in ***V1*** for IDs in V2******
bad_sub=find(V2_REST.mr_rew_cic_accumbens<=-100 |V2_REST.mr_rew_cic_accumbens>=20);
V2_nobadsub=V2_REST;
V2_nobadsub(bad_sub,:)=[]
%Look at diff between V1 & V2
%model= fitlme(V1,'inv_age ~ mr_rew_cic_accumbens'); %no random effect (yet). Age as a function of correlation here.
figure;
for ii = 1:length(loc)
    idx(ii) = strcmp(V1_REST_nbs.sex(loc(ii)),'F');
    if idx(ii)==1
        plot([V1_REST_nbs.RT_18_Score(loc(ii)) V2_nobadsub.RT_18_Score(ii)], ([V1_REST_nbs.mr_rew_cic_accumbens(loc(ii)) V2_nobadsub.mr_rew_cic_accumbens(ii)]),'.r-')
        hold on;
    elseif idx(ii)==0
        plot([V1_REST_nbs.RT_18_Score(loc(ii)) V2_nobadsub.RT_18_Score(ii)], ([V1_REST_nbs.mr_rew_cic_accumbens(loc(ii)) V2_nobadsub.mr_rew_cic_accumbens(ii)]),'.b-')
        hold on;
    end
end

%% To check out behavioral performance as a f'n of striatal bold signal - under construction.
%% See if baseline BP & task BP correlates with age
%bad_sub = find(V1.srtmdyn_gamma_cic_accumbens<=-.5);
%V1_nobadsub=V1;
%V1_nobadsub(bad_sub,:)=[];
%find(V1_nobadsub.srtmdyn_gamma_cic_accumbens<=-.5);
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
