%% ++++++++++++ MOVING BAR FOR DS ++++++++++++
dirNames = projects.vis_stim_char.analysis.load_dir_names;
%% process data
dataOutAll = {};
idxFinalSelAll = {}; 
for iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    %     dataOutAll{iDir} = file.load_single_var('../analysed_data/moving_bar_ds/dataOut.mat');
    load idxFinalSel.mat
    idxFinalSelAll{iDir} = idxFinalSel.keep;
end
%%
cpu.open_matlabpool(8)
for iDir =4%:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory

    dataOut = projects.vis_stim_char.analysis.moving_bars_ds.process_data(...
    idxFinalSelAll{iDir}); % process data for specified indices.
end
%% plot sample rasters
h= figure;
for iDir =4%:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    clearvars -except iDir dirNames h
    load idxFinalSel
    % plot data for specified indices.
    dataOut = projects.vis_stim_char.analysis.moving_bars_ds.plot_rasters(...
        idxFinalSel.keep, 'offset', 2,'rgb', 2,'speed',2,'angle',2,'color','r','fig',h);
end
%% quality check (mean activity in pref direction)

dirNames = projects.vis_stim_char.analysis.load_dir_names;
for iDir =1:length(dirNames.dataDirLong) %
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
%     clearvars -except iDir dirNames
    load idxFinalSel

    paramOutRF = file.load_single_var(...
        '../analysed_data/marching_sqr_over_grid', 'dataOut.mat');
    dataOut = file.load_single_var(...
        '../analysed_data/moving_bar_ds', 'dataOut.mat');
    
    paramOut = projects.vis_stim_char.analysis.moving_bars_ds.measure_activity_per_cell(...
        dataOut, paramOutRF )
    
    progress_info(iDir, length(dirNames.dataDirLong))
    
    onOffCount = [paramOut.mean_ds_spk_cnt_slow_off;...
        paramOut.mean_ds_spk_cnt_slow_on];
       
    dataOut.mean_norm_spk_cnt_pref_angle = max(onOffCount,[],1);
    save(fullfile('../analysed_data/moving_bar_ds', 'dataOut.mat'),'dataOut');
end


%% calculate parameters
dirNames = projects.vis_stim_char.analysis.load_dir_names;
for iDir =1:length(dirNames.dataDirLong) %
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
%     clearvars -except iDir dirNames
    load idxFinalSel

    paramOutRF = file.load_single_var(...
        '../analysed_data/marching_sqr_over_grid', 'dataOut.mat');
    dataOut = file.load_single_var(...
        '../analysed_data/moving_bar_ds', 'dataOut.mat');
    
    paramOut = projects.vis_stim_char.analysis.moving_bars_ds.compute_params(...
        dataOut, paramOutRF )
    
    progress_info(iDir, length(dirNames.dataDirLong))
end

dirNames = projects.vis_stim_char.analysis.load_dir_names;
absDirNames = dirNames.dataDirLong;
localDirName = 'analysed_data/moving_bar_ds/';
h =figure; figs.scale(h,75,100);
fieldNamesCat = {'clus_num' 'date' 'ds_fr_slow_on' 'ds_fr_fast_on' 'ds_spk_cnt_slow_on'...
    'ds_spk_cnt_fast_on'  'ds_fr_slow_off' 'ds_fr_fast_off' 'ds_spk_cnt_slow_off' ...
    'ds_spk_cnt_fast_off'};
fileName = 'param_DSIndex.mat';
paramCatCell = projects.vis_stim_char.analysis.gather_indices_v2(...
    absDirNames, localDirName, fileName, fieldNamesCat);

param_Moving_Bars_DS = [];

for i=1:length(fieldNamesCat)
    eval(sprintf('param_Moving_Bars_DS.%s = paramCatCell{i};',fieldNamesCat{i}))
end

mkdir(dirNames.common.params);
save(fullfile(dirNames.common.params,'param_Moving_Bars_DS.mat'),'param_Moving_Bars_DS')
%%  Obtain and plot all indices
dirNames = projects.vis_stim_char.analysis.load_dir_names;
absDirNames = dirNames.dataDirLong;
localDirName = 'analysed_data/moving_bar_ds/';
fileName = 'param_DSIndex';

h =figure; figs.scale(h,75,100);
fieldName = 'ds_fr_slow_on';
paramCat = projects.vis_stim_char.analysis.gather_indices(...
    absDirNames, localDirName, fileName, fieldName)
subplot(2,2,1), hist(paramCat,50), title(fieldName,'Interpreter', 'none');

fieldName = 'ds_fr_fast_on';
paramCat = projects.vis_stim_char.analysis.gather_indices(...
    absDirNames, localDirName, fileName, fieldName)
subplot(2,2,2), hist(paramCat,50), title(fieldName,'Interpreter', 'none');

fieldName = 'ds_spk_cnt_slow_on';
paramCat = projects.vis_stim_char.analysis.gather_indices(...
    absDirNames, localDirName, fileName, fieldName)
subplot(2,2,3), hist(paramCat,50), title(fieldName,'Interpreter', 'none');

fieldName = 'ds_spk_cnt_fast_on';
paramCat = projects.vis_stim_char.analysis.gather_indices(...
    absDirNames, localDirName, fileName, fieldName)
subplot(2,2,4), hist(paramCat,50), title(fieldName,'Interpreter', 'none');

h =figure; figs.scale(h,75,100);
fieldName = 'ds_fr_slow_off';
paramCat = projects.vis_stim_char.analysis.gather_indices(...
    absDirNames, localDirName, fileName, fieldName)
subplot(2,2,1), hist(paramCat,50), title(fieldName,'Interpreter', 'none');

fieldName = 'ds_fr_fast_off';
paramCat = projects.vis_stim_char.analysis.gather_indices(...
    absDirNames, localDirName, fileName, fieldName)
subplot(2,2,2), hist(paramCat,50), title(fieldName,'Interpreter', 'none');

fieldName = 'ds_spk_cnt_slow_off';
paramCat = projects.vis_stim_char.analysis.gather_indices(...
    absDirNames, localDirName, fileName, fieldName)
subplot(2,2,3), hist(paramCat,50), title(fieldName,'Interpreter', 'none');

fieldName = 'ds_spk_cnt_fast_off';
paramCat = projects.vis_stim_char.analysis.gather_indices(...
    absDirNames, localDirName, fileName, fieldName)
subplot(2,2,4), hist(paramCat,50), title(fieldName,'Interpreter', 'none');

%% plot response rasters with offset
h= figure;
dirNames = projects.vis_stim_char.analysis.load_dir_names;
hold on
iAngle = 1:8;
idxFinalSelectAll = {};
for iDir = 1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load idxFinalSel
    idxFinalSelectAll{iDir} = idxFinalSel.keep;
end
% cpu.open_matlabpool(7)
for iDir =4%:length(dirNames.dataDirLong) % loop through directories
    
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory

    % plot data for specified indices.
    currIdx = paraOutputMat.params(find(idxAssigns{8}==4),:);
    dataOut = projects.vis_stim_char.analysis.moving_bars_ds.plot_rasters_with_rf_pos_correction(...
        idxFinalSelectAll{iDir},'rgb', 1:2,'speed',1,'color',{'k','r'},...
         'xlim',[-3 3],'offset',2, 'single_windows');%,2,'angle',iAngle
end

%% plot response polars with offset
h= figure;
dirNames = projects.vis_stim_char.analysis.load_dir_names;
hold on
iAngle = 1:8;
idxFinalSelectAll = {};
for iDir = 1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load idxFinalSel
    idxFinalSelectAll{iDir} = idxFinalSel.keep;
end
% cpu.open_matlabpool(7)
for iDir =4%:length(dirNames.dataDirLong) % loop through directories
    
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory

    % plot data for specified indices.

    dataOut = projects.vis_stim_char.analysis.moving_bars_ds.plot_polars_with_rf_pos_correction(...
        idxFinalSelectAll{iDir},'rgb', 1:2,'speed',1,'color',{'k','r'},...
        'xlim',[-1 1],'offset',2,'sel_idx', 1);%,2,'angle',iAngle
    
end


%% save response rasters with offset
h= figure;
dirNames = projects.vis_stim_char.analysis.load_dir_names;
hold on
iAngle = 1:8;
idxFinalSelectAll = {};
for iDir = 1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load idxFinalSel
    idxFinalSelectAll{iDir} = idxFinalSel.keep;
end
cpu.open_matlabpool(8)
parfor iDir =1:length(dirNames.dataDirLong) % loop through directories
    
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory

    % plot data for specified indices.
    dataOut = projects.vis_stim_char.analysis.moving_bars_ds.save_rasters_with_rf_pos_correction(...
        idxFinalSelectAll{iDir});%,2,'angle',iAngle
    
end

%% plot rasters of selected clusters
dataOutAll = {};
nrmSpkCntAll = [];
for iDir =1:length(dirNames.dataDirLong) % loop through directories
    
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
   load ../analysed_data/moving_bar_ds/dataOut.mat;
   dataOutAll{iDir} = file.load_single_var('../analysed_data/moving_bar_ds/dataOut.mat');
   nrmSpkCntAll = [nrmSpkCntAll  dataOutAll{iDir}.mean_norm_spk_cnt_pref_angle];
    
end

%%
chooseClus = 3;
selSpeed = 1;
chooseClusIdx = find(idxAssigns{bestClusNum}==chooseClus);
selRGCs = paraOutputMat.params( chooseClusIdx,1:2);
h=figure;
spDims = subplots.dimensions_for_ratio(size(selRGCs,1),1.5);
for iClus = 1:size(selRGCs,1)
    subplot(spDims(1),spDims(2),iClus)
    % index for cluster
    idxDir = selRGCs(iClus,1);
    clusNumIdx = find(dataOutAll{idxDir}.clus_num==selRGCs(iClus,2));
    currData = dataOutAll{selRGCs(iClus,1)}.rasters{clusNumIdx};
    projects.vis_stim_char.analysis.moving_bars_ds.plot_rasters_with_rf_pos_correction_for_cell_group(...
        currData,'rgb', 1:2,'speed',selSpeed);
    
    spkCntNrm = dataOutAll{selRGCs(iClus,1)}.mean_norm_spk_cnt_pref_angle(clusNumIdx);
    title(sprintf('%2.3f', spkCntNrm ));
    
end
supTitle = sprintf('Param-cluster Num %d, speed = %d', chooseClus, selSpeed);
suptitle(supTitle);
figs.maximize(h)

mean(paraOutputMat.params(chooseClusIdx,3))





%% compute parameters with offset

dirNames = projects.vis_stim_char.analysis.load_dir_names;
hold on
iAngle = 1:8;

idxFinalSelectAll = {};
for iDir = 1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load idxFinalSel
    idxFinalSelectAll{iDir} = idxFinalSel.keep;
end
cpu.open_matlabpool(8)
parfor iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    dataOut = projects.vis_stim_char.analysis.moving_bars_ds.compute_response_with_rf_pos_correction(...
        idxFinalSelectAll{iDir},'rgb', 1:2,'speed',1);
    iDir
end

for iDir = 1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load ../analysed_data/moving_bar_ds/dataOut.mat
    load ../analysed_data/moving_bar_ds/param_DSIndex.mat
    for i=1:size(dataOut.on_max_fr,1)
        data = [dataOut.on_max_fr(i,:);dataOut.off_max_fr(i,:)];
        [maxNum, maxIndex] = max(data(:));
        [row, col] = ind2sub(size(data), maxIndex);
        onVal = data(1,col); offVal = data(2,col);
        paramOut.on_off_idx(i) = (onVal - offVal)/(onVal + offVal);
        
    end
   save('../analysed_data/moving_bar_ds/param_DSIndex.mat','paramOut');
end

%% plot DS and get raster too

load ../analysed_data/moving_bar_ds/dataOut.mat
h=figure,  figs.maximize(h);

% plot a bunch
selIdx = 1:size(dataOut.off_max_fr,1);
subplotDims = subplots.dimensions_for_ratio(length(selIdx), 1.6);

for i=1:length(selIdx)
    subplots.subplot_tight(subplotDims(1),subplotDims(2),i,0.03)
  
    ifunc.plot.plot_polar_for_rgc([0:45:350], ...
        dataOut.on_max_fr(selIdx(i),:),'color','r')
        hold on;
    ifunc.plot.plot_polar_for_rgc([0:45:350], ...
        dataOut.off_max_fr(selIdx(i),:),'color','k')
    title(num2str(i))
end

% plot rasters for all
figure, hold on
for i=1:length(selIdx)
    subplots.subplot_tight(subplotDims(1),subplotDims(2),i,0.02)
    
    selSpeed = 1;
    currData = dataOut.rasters{i};
    projects.vis_stim_char.analysis.moving_bars_ds.plot_rasters_with_rf_pos_correction_for_cell_group(...
        currData,'rgb', 1:2,'speed',selSpeed);
end


% select 1
figure, hold on
for i=5    
    selSpeed = 1;
    currData = dataOut.rasters{i};
    projects.vis_stim_char.analysis.moving_bars_ds.plot_rasters_with_rf_pos_correction_for_cell_group(...
        currData,'rgb', 1:2,'speed',selSpeed, 'separate_reps');
end


figure
ifunc.plot.plot_polar_for_rgc([0:45:350], ...
    dataOut.on_max_fr(i,:),'color','r')



%% Concatenated parameters

% ON or OFF vals
paramCat =  projects.vis_stim_char.analysis.gather_indices(dirNames.dataDirLong, ...
     'analysed_data/moving_bar_ds','param_DSIndex.mat' , 'on_off_idx'  ) 
 
paramCat =  projects.vis_stim_char.analysis.gather_indices(dirNames.dataDirLong, ...
     'analysed_data/moving_bar_ds','param_DSIndex.mat' , 'ds_fr_fast_on'  ) 
 
%  load data
load('~/ln/vis_stim_hamster/data_analysis/parameters/param_Moving_Bars_DS.mat')

%% plot DS data
paramCat =  projects.vis_stim_char.analysis.gather_indices(dirNames.dataDirLong, ...
     'analysed_data/moving_bar_ds','param_DSIndex.mat' , 'ds_fr_fast_on'  ) 

figure, hist(param_Moving_Bars_DS.ds_fr_fast_on,30);
title('DS Index');
xlabel('Index');
ylabel('Cell Count');
fileName = 'moving_bars_ds_index';
dirName = '~/ln/vis_stim_hamster/Figs/';
figs.format_hist_for_pub('journal_name', 'frontiers');
figs.format_for_pub;
figs.save_for_pub(fullfile(dirName,fileName))
 
 %%
 load ~/ln/vis_stim_hamster/data_analysis/parameters/mainParams.mat
 figure, plot(mainParams.param(:,8),paramCat,'cs')
 
 %%
 dirNames = projects.vis_stim_char.analysis.load_dir_names;
hold on
iAngle = 1:8;

idxFinalSelectAll = {};
for iDir = 1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load idxFinalSel
    idxFinalSelectAll{iDir} = idxFinalSel.keep;
end
cpu.open_matlabpool(7)
parfor iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    dataOut = projects.vis_stim_char.analysis.moving_bars_ds.compute_response_with_rf_pos_correction(...
        idxFinalSelectAll{iDir},'rgb', 1:2,'speed',1);
    iDir
end

 
dirNames = projects.vis_stim_char.analysis.load_dir_names;
absDirNames = dirNames.dataDirLong;
localDirName = 'analysed_data/moving_bar_ds/';
h =figure; figs.scale(h,75,100);
fieldNamesCat = {'clus_num' 'date' 'on_max_fr' 'off_max_fr' };
fileName = 'dataOut.mat';
paramCatCell = projects.vis_stim_char.analysis.gather_indices_v2(...
    absDirNames, localDirName, fileName, fieldNamesCat);

param_Moving_Bars_DS_with_offset_corr = [];

for i=1:2
    eval(sprintf('param_Moving_Bars_DS_with_offset_corr.%s = paramCatCell{i};',fieldNamesCat{i}))
end
for i=1:length(paramCatCell{1})
   maxOn = max( paramCatCell{3}(:,i));
   maxOff = max( paramCatCell{4}(:,i));
   if maxOn
end

mkdir(dirNames.common.params);
save(fullfile(dirNames.common.params,'param_Moving_Bars_DS_with_offset_corr.mat'),'param_Moving_Bars_DS_with_offset_corr')