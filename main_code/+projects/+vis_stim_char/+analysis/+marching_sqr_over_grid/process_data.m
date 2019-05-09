function process_data
%% Initial run

% load data directories
dirNames = projects.vis_stim_char.analysis.load_dir_names;

for iDir = 1:length(dirNames.dataDirLong) % loop through directories
    close all
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    %     clearvars -except dirNames iDir param_BiasIndex % clear vars
    script_load_data; load idxNeur ; load idxToMerge.mat; load idxFinalSel% load data
    %     load(fullfile(dirNames.marching_sqr_over_grid,'dataOut'))
    dataOut = projects.vis_stim_char.analysis.marching_sqr_over_grid.process_spiketrains(...
        idxFinalSel.keep,'no_plot');
    dataOut = projects.vis_stim_char.analysis.marching_sqr_over_grid.get_rf_size(dataOut);
    
    mkdir(dirNames.marching_sqr_over_grid);
    save(fullfile(dirNames.marching_sqr_over_grid,'dataOut'),'dataOut')
    progress_info(iDir,length(dirNames.dataDirLong),'batch mode: ')
end
%% plot rasters of data 
fileNameFig = 'rasters_squares_at_center';
titleNameFig = 'Rasters - Marching Sqr Over Grid';

dirNames = projects.vis_stim_char.analysis.load_dir_names;
h= figure;
figs.scale(h,75,75)

idxFinalSelAll = {};

for iDir =1:length(dirNames.dataDirLong) % loop through directories
    clf
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load idxFinalSel
    load(fullfile(dirNames.marching_sqr_over_grid,'dataOut'))
    % plot data for specified indices.
    dataOut = projects.vis_stim_char.analysis.marching_sqr_over_grid.plot_rasters(...
        dataOut,'fig',h);
     
shg
end
%% compute parameters
idxKeep = find(dataOut.keep==1);

% spike count
for i=1:length(idxKeep)
    spikesON(i) = sum(cellfun(@length,dataOut.spikecount_at_ctr_ON{idxKeep(i)}))
end
for i=1:length(idxKeep)
    spikesOFF(i) = sum(cellfun(@length,dataOut.spikecount_at_ctr_OFF{idxKeep(i)}))
end

paramBiasCnt = (spikesON-spikesOFF)./(spikesON+spikesOFF);

% spike rate
spikesON = cellfun(@max,dataOut.firing_rate_ON(idxKeep));
spikesOFF = cellfun(@max,dataOut.firing_rate_OFF(idxKeep));

paramBiasFR = (spikesON-spikesOFF)./(spikesON+spikesOFF);
%  paramBiasFR  = ((dataOut.total_spikes_ON)-(dataOut.total_spikes_OFF))./((dataOut.total_spikes_ON)+(dataOut.total_spikes_OFF));
% Compare ways of computing bias:

figure, plot(paramBiasCnt, paramBiasFR,'sb','LineWidth', 2,'MarkerFaceColor','b')
mdl = LinearModel.fit(paramBiasCnt,paramBiasFR);
text(0.2,-0.6,sprintf('R squared = %0.2f', mdl.Rsquared.Ordinary))

% plot parameter 
figure, hist(paramBiasFR,30)
figure, hist(paramBiasCnt,30)


%% compute parameters

paramsAll = [];
param_March_Sqr_Over_Grid = [];
param_March_Sqr_Over_Grid.clus_num = [];
param_March_Sqr_Over_Grid.date = {};
param_March_Sqr_Over_Grid.index_count = [];
param_March_Sqr_Over_Grid.index_fr = [];
param_March_Sqr_Over_Grid.RF_area_um_sqr= [];
param_March_Sqr_Over_Grid.dir_num = [];
param_March_Sqr_Over_Grid.index_total_cnt = [];
% load data directories
dirNames = projects.vis_stim_char.analysis.load_dir_names;

for iDir = 1:length(dirNames.dataDirLong) % loop through directories
    clearvars -except dirNames param_March_Sqr_Over_Grid paramsAll iDir
    
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    script_load_data; load idxNeur ; load idxToMerge.mat; load idxFinalSel% load data
    
    load(fullfile(dirNames.local.marching_sqr_over_grid, 'dataOut'))
    idxKeep = find(dataOut.keep==1);
    
    % parameters
    spikesON = nan(1,length(dataOut.spikecount_at_ctr_ON)); spikesOFF = ...
        nan(1,length(dataOut.spikecount_at_ctr_OFF));
    for i=1:length(spikesON)
        spikesON(i) = sum(cellfun(@length,dataOut.spikecount_at_ctr_ON{i}));
    end
    for i=1:length(spikesOFF)
        spikesOFF(i) = sum(cellfun(@length,dataOut.spikecount_at_ctr_OFF{i}));
    end
    
    % clus num
    clusNo = nan(1,length(dataOut.clus_no));
    clusNo = cell2mat(dataOut.clus_no);
    param_March_Sqr_Over_Grid.clus_num = [param_March_Sqr_Over_Grid.clus_num clusNo];
    
    % date
    param_March_Sqr_Over_Grid.date = [param_March_Sqr_Over_Grid.date repmat(dirNames.dataDirShort(iDir),1,length(dataOut.clus_no)) ];
    param_March_Sqr_Over_Grid.index_count = [param_March_Sqr_Over_Grid.index_count (spikesON-spikesOFF)./(spikesON+spikesOFF)];
    
    % dir num
    param_March_Sqr_Over_Grid.dir_num = [param_March_Sqr_Over_Grid.dir_num ...
        repmat(iDir,1,length(dataOut.clus_no)) ];
    
    spikesON = []; spikesOFF = [];
    % spike rate
    spikesON = cellfun(@max,dataOut.firing_rate_ON);
    spikesOFF = cellfun(@max,dataOut.firing_rate_OFF);
    
    param_March_Sqr_Over_Grid.index_fr = [param_March_Sqr_Over_Grid.index_fr (spikesON-spikesOFF)./(spikesON+spikesOFF)];
    
    spikesON = dataOut.total_spikes_ON;
    spikesOFF = dataOut.total_spikes_OFF;
    param_March_Sqr_Over_Grid.index_total_cnt = [param_March_Sqr_Over_Grid.index_total_cnt ...
        (spikesON-spikesOFF)./(spikesON+spikesOFF)];
    
    
    param_March_Sqr_Over_Grid.RF_area_um_sqr = [param_March_Sqr_Over_Grid.RF_area_um_sqr dataOut.ON.RF_area_um_sqr];
    param_March_Sqr_Over_Grid;
    iDir
    
end
% compute rf size, latency, transience
fieldNameToCat = {'on_or_off' 'keep' 'latency_ON' 'latency_OFF' 'transience_ON' 'transience_OFF' };
localDirName = 'analysed_data/marching_sqr_over_grid/';
fileName='dataOut';
paramDataCat = projects.vis_stim_char.analysis.gather_indices_v2(...
    dirNames.dataDirLong,localDirName, fileName,fieldNameToCat);
idxON = find(paramDataCat{1}==1);
idxOFF = find(paramDataCat{1}==0);
idxBad = find(paramDataCat{2}==0);
idxON(find(ismember(idxON,idxBad))) = [];
idxOFF(find(ismember(idxON,idxBad))) = [];

paramCombo = nan(1,length(paramDataCat{1}));
paramCombo(idxON) = paramDataCat{3}(idxON);
paramCombo(idxOFF) = paramDataCat{4}(idxOFF);
param_March_Sqr_Over_Grid.latency = paramCombo;

paramCombo = nan(1,length(paramDataCat{1}));
paramCombo(idxON) = paramDataCat{5}(idxON);
paramCombo(idxOFF) = paramDataCat{6}(idxOFF);
param_March_Sqr_Over_Grid.transience = paramCombo;

param_March_Sqr_Over_Grid.on_idx = idxON;
param_March_Sqr_Over_Grid.off_idx = idxOFF;
param_March_Sqr_Over_Grid.keep = find(not(ismember([1:length(param_March_Sqr_Over_Grid.clus_num)],idxBad)));
param_March_Sqr_Over_Grid.invalid = idxBad;

mkdir(dirNames.marching_sqr_over_grid);
save(fullfile(dirNames.common.params,'param_March_Sqr_Over_Grid.mat'),'param_March_Sqr_Over_Grid')

%% plotting On Off Bias

% Compare ways of computing bias:

figure, plot(param_March_Sqr_Over_Grid.index_fr, param_March_Sqr_Over_Grid.index_count,'sb','LineWidth', 2,'MarkerFaceColor','b')
mdl = LinearModel.fit(param_March_Sqr_Over_Grid.index_fr, param_March_Sqr_Over_Grid.index_count);
text(0.2,-0.6,sprintf('R squared = %0.2f', mdl.Rsquared.Ordinary))
fileNameFig = 'on_off_marching_sqr_spk_cnt_vs_peak_fr';
supTitle = 'Marching Sqr Over Grid, On Off Bias Parameter - Peak Firing Rate';
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
    'font_size_all', 13 , ...
    'x_label', 'Param from Peak Spike Rate (spikes/sec)','y_label', 'Param from Spike Count',...
    'sup_title', supTitle);


% plot parameter 
figure, hist(param_March_Sqr_Over_Grid.index_fr,30);
fileNameFig = 'hist_params_on_off_bias_peak_fr';
supTitle = 'On Off Bias Parameter - Peak Firing Rate';
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
    'font_size_all', 13 , ...
    'x_label', 'Param from Peak Spike Rate (spikes/sec)','y_label', 'Count',...
    'sup_title', supTitle);

figure, hist(param_March_Sqr_Over_Grid.index_count,30)
% figure, plot(1:length(param_March_Sqr_Over_Grid.index_count), param_March_Sqr_Over_Grid.index_count, 1:length(param_March_Sqr_Over_Grid.index_count), param_March_Sqr_Over_Grid.index_fr)
dirNameFig = dirNames.common.figs;
fileNameFig = 'params_fr_vs_spk_cnt_compared';
supTitle = 'Peak Firing Rate vs Spike Count';
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
    'font_size_all', 13 , ...
    'x_label', 'Param from Spike Count','y_label', 'Param from Peak Spike Rate (spikes/sec)',...
    'sup_title', supTitle);



figure, hist(param_March_Sqr_Over_Grid.index_total_cnt,30)
currGca = findobj(gca,'Type','patch');
set(currGca,'FaceColor',[1 1 1 ]*0.5) %,'EdgeColor',[1 1 1 ]
title('ON-OFF Bias','Interpreter', 'none')
xlabel('Parameter Value'), ylabel('Cell Count');
% figure, plot(1:length(param_March_Sqr_Over_Grid.index_count), param_March_Sqr_Over_Grid.index_count, 1:length(param_March_Sqr_Over_Grid.index_count), param_March_Sqr_Over_Grid.index_fr)
dirNameFig = dirNames.common.figs;
fileNameFig = 'params_marching_sqr_over_grid_ON_OFF_bias';
supTitle = 'ON-OFF Bias';
figs.format_for_pub(   'journal_name','frontiers')
figs.save_for_pub(fullfile(dirNameFig , fileNameFig));


%% save to main parameter mat
descriptorInfo = 'marching square over grid: ON/OFF bias index (spike count)';
paramData = param_March_Sqr_Over_Grid.index_count;
projects.vis_stim_char.param.save_to_main_param_file( descriptorInfo, paramData);


descriptorInfo = 'marching square over grid: ON/OFF bias index (firing rate)';
paramData = param_March_Sqr_Over_Grid.index_fr;
projects.vis_stim_char.param.save_to_main_param_file( descriptorInfo, paramData);

%% Plot other parameters
% rf size, latency, transience
% fieldNameToCat = {'on_or_off' 'keep' 'latency_ON' 'latency_OFF' 'transience_ON' 'transience_OFF'};
% paramDataCat 
% idxON 
% idxOFF

figure, 
hist(param_March_Sqr_Over_Grid.latency,30);
hGCA = findobj(gca,'Type','patch');
set(hGCA,'FaceColor',[1 1 1]*0.5,'EdgeColor','w')
dirNameFig = dirNames.common.figs;
fileNameFig = 'hist_latency_parameter';
supTitle = 'Marching Sqr Over Grid: Latency Parameter';
title(supTitle),
xlabel('Time (s)')
ylabel('Cell Count (unit cells)')

figs.format_for_pub(  'journal_name','frontiers');
figs.save_for_pub(fullfile(dirNameFig, fileNameFig));


% save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
%     'font_size_all', 13 , ...
%     'x_label', 'Latency (msec)','y_label', 'Count',...
%     'sup_title', supTitle);

% paramCombo = nan(1,length(paramDataCat{1}));
% paramCombo(idxON) = paramDataCat{5}(idxON);
% paramCombo(idxOFF) = paramDataCat{6}(idxOFF);
figure, 
hist(param_March_Sqr_Over_Grid.transience,30)
hGCA = findobj(gca,'Type','patch');
set(hGCA,'FaceColor',[1 1 1]*0.5,'EdgeColor','w')
dirNameFig = dirNames.common.figs;
fileNameFig = 'hist_transience_parameter';
supTitle = 'Marching Sqr Over Grid: Transience Index Parameter';
title(supTitle),
xlabel('Time (s)')
ylabel('Cell Count (unit cells)')

figs.format_for_pub(  'journal_name','frontiers');
figs.save_for_pub(fullfile(dirNameFig, fileNameFig));



% save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
%     'font_size_all', 13 , ...
%     'x_label', 'Transience (msec)','y_label', 'Count',...
%     'sup_title', supTitle);

%% save latency and transience to main parameter mat

descriptorInfo = 'marching square over grid: latency';
paramData = param_March_Sqr_Over_Grid.latency;
projects.vis_stim_char.param.save_to_main_param_file( descriptorInfo, paramData);

descriptorInfo = 'marching square over grid: transience';
paramData = param_March_Sqr_Over_Grid.transience;
projects.vis_stim_char.param.save_to_main_param_file( descriptorInfo, paramData);



