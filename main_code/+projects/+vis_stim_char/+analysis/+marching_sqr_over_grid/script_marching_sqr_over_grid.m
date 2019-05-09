%% Initial run
dirName = [];
param_BiasIndex = [];
param_BiasIndex.clus_num = [];
param_BiasIndex.date = {};
param_BiasIndex.index = [];
param_BiasIndex.total_spikes_ON = [];
param_BiasIndex.total_spikes_OFF = [];

% load data directories
dirName = projects.vis_stim_char.analysis.load_dir_names;

for iDir = 1:length(dirName.dataDirLong) % loop through directories
    
    cd([dirName.dataDirLong{iDir},'Matlab/']); % enter directory
    clearvars -except dirName iDir param_BiasIndex % clear vars
    script_load_data; load idxNeur ; load idxToMerge.mat; load idxFinalSel% load data
    
    dataOut = projects.vis_stim_char.analysis.marching_sqr_over_grid.process_spiketrains(...
        idxFinalSel.keep);
    
    mkdir(dirName.marching_sqr_over_grid);
    save(fullfile(dirName.marching_sqr_over_grid,'dataOut'),'dataOut')
    progress_info(iDir,length(dirName.dataDirLong),'batch mode: ')
end

save(fullfile(dirName.common.marching_sqr_over_grid, 'param_BiasIndex.mat'),'param_BiasIndex')


%% Create figure
minNumSpikes = 20;
idxFewSpikes = find(param_BiasIndex.total_spikes_ON+param_BiasIndex.total_spikes_OFF<minNumSpikes);
idxEnoughSpikes = find(~ismember(1:length(param_BiasIndex.total_spikes_ON),idxFewSpikes));

idxCurr = (param_BiasIndex.total_spikes_ON-param_BiasIndex.total_spikes_OFF)./...
    (param_BiasIndex.total_spikes_ON+param_BiasIndex.total_spikes_OFF);

idxCurrGood = idxCurr(idxEnoughSpikes);


figure, hist(idxCurrGood,50)

% FILE NAME
fileNameFig = 'param_on_off_bias_index';
% fileNameFig = sprintf('speed_var_length_300_clus_%d', i, clusNum(i));

% TITLE NAME
titleNameFig = 'ON OFF Bias Index';

xlabel('bias', 'FontName', 'Courier');
ylabel('Spike Rate (spikes/sec)', 'FontName', 'Courier')

set(gca,'FontSize',13, 'FontName', 'Courier')
set(findall(gcf,'type','text'),'FontSize',13,'FontName', 'Courier')

title(titleNameFig, ...
    'FontName', 'Courier', 'FontSize',14,'Interpreter', 'none')

% DIR NAME
dirNameFig = [dirName.common.marching_sqr_over_grid,'Figs/'];
mkdir(dirNameFig);

% SAVE
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'});


%% can run once dataOut has been saved to ../analysed_data/marching_sqr_over_grid/
dirName = projects.vis_stim_char.analysis.load_dir_names;

vals_RF_area=[];
vals_RF_area.ON = [];
vals_RF_area.OFF = [];

for iDir = 1:length(dirName.dataDirLong)
    close all
    cd([dirName.dataDirLong{iDir},'Matlab/']); % enter directory
    clearvars -except dirName iDir param_BiasIndex vals_RF_area % clear vars
    script_load_data; load idxNeur ; load idxToMerge.mat; load idxFinalSel% load data
    
    load(fullfile(dirName.marching_sqr_over_grid,'dataOut'))
    progress_info(iDir,length(dirName.dataDirLong),'batch mode: ')
    
    %     dataOut = projects.vis_stim_char.analysis.marching_sqr_over_grid.get_rf_size(dataOut)

    vals_RF_area.ON(end+1:end+length(dataOut.ON.RF_area_um_sqr)) = dataOut.ON.RF_area_um_sqr;
    vals_RF_area.OFF(end+1:end+length(dataOut.OFF.RF_area_um_sqr)) = dataOut.OFF.RF_area_um_sqr;
    
%     save(fullfile(dirName.marching_sqr_over_grid,'dataOut'))
   
end

currDir = [dirName.common.marching_sqr_over_grid];
mkdir(currDir);
save(fullfile(currDir, 'vals_RF_area.mat'),'vals_RF_area');

%% Plot RF Area plots

figure, hist(param_RF_area.ON(find(param_RF_area.ON>0)),50)

% FILE NAME
fileNameFig = 'rf_area_ON';
% fileNameFig = sprintf('speed_var_length_300_clus_%d', i, clusNum(i));

% TITLE NAME
titleNameFig = 'Receptive Field Area ON';

xlabel('Area (um^2)', 'FontName', 'Courier');
ylabel('Count', 'FontName', 'Courier')

set(gca,'FontSize',13, 'FontName', 'Courier')
set(findall(gcf,'type','text'),'FontSize',13,'FontName', 'Courier')

title(titleNameFig, ...
    'FontName', 'Courier', 'FontSize',14,'Interpreter', 'none')

% DIR NAME
dirNameFig = [dirName.common.marching_sqr_over_grid,'Figs/']
mkdir(dirNameFig);

% SAVE
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'});

figure, hist(param_RF_area.OFF(find(param_RF_area.OFF>0)),50)

% FILE NAME
fileNameFig = 'rf_area_OFF';
% fileNameFig = sprintf('speed_var_length_300_clus_%d', i, clusNum(i));

% TITLE NAME
titleNameFig = 'Receptive Field Area OFF';

xlabel('Area (um^2)', 'FontName', 'Courier');
ylabel('Count', 'FontName', 'Courier')

set(gca,'FontSize',13, 'FontName', 'Courier')
set(findall(gcf,'type','text'),'FontSize',13,'FontName', 'Courier')

title(titleNameFig, ...
    'FontName', 'Courier', 'FontSize',14,'Interpreter', 'none')

% DIR NAME
dirNameFig = [dirName.common.marching_sqr_over_grid,'Figs/']
mkdir(dirNameFig);

% SAVE
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'});

%% Plot RF Diameter plots

figure, hist(2.*sqrt(param_RF_area.ON(find(param_RF_area.ON>0))/3.14),50)

% FILE NAME
fileNameFig = 'rf_diameter_ON';
% fileNameFig = sprintf('speed_var_length_300_clus_%d', i, clusNum(i));

% TITLE NAME
titleNameFig = 'Receptive Field Diameter ON';

xlabel('Diameter (um)', 'FontName', 'Courier');
ylabel('Count', 'FontName', 'Courier')

set(gca,'FontSize',13, 'FontName', 'Courier')
set(findall(gcf,'type','text'),'FontSize',13,'FontName', 'Courier')

title(titleNameFig, ...
    'FontName', 'Courier', 'FontSize',14,'Interpreter', 'none')

% DIR NAME
dirNameFig = [dirName.common.marching_sqr_over_grid,'Figs/']
mkdir(dirNameFig);

% SAVE
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'});

figure, hist(2.*sqrt(param_RF_area.OFF(find(param_RF_area.OFF>0))/3.14),50)

% FILE NAME
fileNameFig = 'rf_diameter_OFF';
% fileNameFig = sprintf('speed_var_length_300_clus_%d', i, clusNum(i));

% TITLE NAME
titleNameFig = 'Receptive Field Diameter OFF';

xlabel('Diameter (um)', 'FontName', 'Courier');
ylabel('Count', 'FontName', 'Courier')

set(gca,'FontSize',13, 'FontName', 'Courier')
set(findall(gcf,'type','text'),'FontSize',13,'FontName', 'Courier')

title(titleNameFig, ...
    'FontName', 'Courier', 'FontSize',14,'Interpreter', 'none')

% DIR NAME
dirNameFig = [dirName.common.marching_sqr_over_grid,'Figs/']
mkdir(dirNameFig);

% SAVE
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'});







