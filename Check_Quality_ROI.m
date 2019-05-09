%% Code to check quality of ROIs (e.g., number of good voxels) across subs
clc
clear;
paren = @(x, varargin) x(varargin{:});
curly = @(x, varargin) x{varargin{:}};
adj = dir('/Volumes/Phillips/mMR_PETDA/subjs/*/func/*_roi_diagnostics.txt');
info=cellfun(@(x) strsplit(x,'_'), {adj.name}, 'UniformOutput',0);
 
% vectors of important info
lunaid= cellfun( @(x) x{1}, info,'UniformOutput',0)';
vdate = cellfun( @(x) datetime(x{2}, 'InputFormat','yyyyMMdd'), info)';
files = arrayfun(@(x) fullfile(x.folder,x.name), adj, 'UniformOutput',0);
T2 = table(lunaid,vdate,files);
% read in all the files

adj_ = cellfun(@(x) readtable(x,'TreatAsEmpty',{'NA'}), ...
    T2.files,'UniformOutput',0);

