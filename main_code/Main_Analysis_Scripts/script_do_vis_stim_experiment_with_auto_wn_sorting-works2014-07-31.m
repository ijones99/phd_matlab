% script_do_vis_stim_experiment_with_auto_wn_sorting

%% SCAN ARRAY FOR ACTIVITY

% send visual stimulus

% plot configs
configDirName = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/'

iConfigNumber=1:98
plotConfig = input('Plot electrode config [y/n].','s')
if strcmp(plotConfig,'y')
    figure, hold on
    gui.plot_hidens_els, hold on
    plot_electrode_config_by_num(configDirName, iConfigNumber,'plot_rand_color',...
        'label_with_number');
end
%% select configurations
configNos = [24 26];patternLength = length(configNos);
for i = 1:7
    configNos = [configNos configNos(end-1:end)+...
        7*ones(1,patternLength)];
end
fileNameConfig = configs.get_el_config_names_by_number(configDirName, configNos);

junk = input('Please start visual stimulus and press enter when ready >>');
% send configuration during visual stimulus
configs.send_configs_to_chip(configDirName, fileNameConfig)

%% make flist
[sortGroupNumber flist sortingRunName] = flists.make_and_save_flist;

% compute all activity maps
clear activity_map
for i=1:length(flist)
    activity_map{i} = wrapper.patch_scan.extract_activity_map(flist{i});
    progress_info(i,length(flist));
    
end
save(sprintf('activity_map_%02d',sortGroupNumber), 'activity_map');
%% plot activity maps on array
figure
gui.plot_hidens_els('marker_style', 'cx'), hold on
dirNameConfig = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/';
load(fullfile(dirNameConfig,'configCtrXY'));

for i=1:length(flist)
    hidens_generate_amplitude_map(activity_map{i},'no_border','no_colorbar', ...
        'no_plot_format','do_use_max');
    text(configCtrX(configNos(i)),configCtrY(configNos(i)),num2str(configNos(i)-1));
end
title('Config ID numbers (not file numbers)')
fprintf('Remember: send config to chip!\n');

%% run whitenoise stimulus
% !!! DO ON STIM COMPUTER

%%
% % ADD: Create flist
% [flist batchInfo.experiments(iBatchIdx).flistName ] =  ...
%     flists.make_flist_select('all',[],'no_flist_id','no_run_no');
def = dirdefs();
expName = get_dir_date;

runNo = input('Enter run no >> ');
flistName = sprintf('flist_wn_checkerboard_n_%02d',runNo);
flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')


%% setup for auto sorting

batchInfo = {};

batchInfo.data_path = def.expRecordings;
batchInfo.out_path = [def.sortingOut,'wn_checkerboard_during_exp/'];
batchInfo.in_path = [def.projHamster, 'sorting_in/wn_checkerboard_during_exp/'];
% /home/ijones/Projects/hamster_visual_characterization/sorting_in/
mkdir(batchInfo.in_path)

% loop to create batch file
doneCreatingBatchInfo = 'n';
iBatchIdx = 1;

cd(batchInfo.in_path)
batchInfo.experiments(iBatchIdx).expNames = expName;
batchInfo.experiments(iBatchIdx).sortingName = 'Sorting_01';
batchInfo.experiments(iBatchIdx).flistName = 'flist_all.m';

% make directories (file structure)
mkdir(expName);
cd(expName);
mkdir('Matlab')
% soft link
eval(sprintf('!ln -s %s%s/proc proc',def.expRecordings, expName ))
% make flist
cd ('Matlab')
[flist batchInfo.experiments(iBatchIdx).flistName ] =  ...
    flists.make_flist_select('all',[],'no_flist_id','no_run_no');

cd(fullfile(batchInfo.in_path,expName))
!mv Matlab/flist*.m .
for i=1:length(flist),fprintf('%d) %s\n', i,flist{i}),end
% make configs file
configs = spikesorting.felix_sorter.create_configs_file(batchInfo, 'exp_name', expName);

%%
cd(batchInfo.in_path)
fileNameIsNew = 0
while fileNameIsNew ~= 1
   batchFileName = input('Enter file name to save batch file. >> ','s');
   if ~exist([fullfile('batch_info',batchFileName), '.mat'],'file')
       save(fullfile(batchFileName),'batchInfo');
       fileNameIsNew = 1;
   else
       warning('File exists. Please choose another name...');
   end
    
end

%% !!!!!!!! RUN THIS ON HAL
tic 
spikesorting.felix_sorter.start_sorting(batchInfo, 5)
toc

%% get list of neurons found automatically (white noise)
runNo = input('Run number >> ');
% load configurations: configs(1)
load(fullfile(def.projHamster, 'sorting_in', 'wn_checkerboard_during_exp',...
    expName, 'configurations.mat'));
load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', ...
    sprintf('%s_resultsForIan.mat', expName)));


configColumn = runNo; configIdx= 1;
[tsMatrixAuto ] = spiketrains.extract_single_neur_spiketrains_from_felix_sorter_results(...
    R, configColumn, configIdx);
%% get frameno info
close all
mkdir(fullfile(dirNameFFile))
framenoName = strcat('frameno_', flistFileNameID,'.mat');
if ~exist(fullfile(dirNameFFile,framenoName))
    frameno = get_framenos(flist, 2e4*60*20);
    save(fullfile(dirNameFFile,framenoName),'frameno');
else
    load(fullfile(dirNameFFile,framenoName)); frameInd = single(frameno);
end

% get file names
fileNames = dir(strcat(dirNameSt,'*.mat'));

load white_noise_frames.mat
edgePix = 12;
white_noise_frames = white_noise_frames(1:edgePix,1:edgePix,:);
dirSTA = strrep(strrep(dirNameSt,'analysed_data', 'Figs'),'03_Neuron_Selection/','');
mkdir(dirSTA)


%% select good neurons
% idxGoodFiles = [];
numSquaresOnEdge=12;
profData = {};
idxGoodFiles = [];
for iFile = 1:length(tsMatrixAuto)
    try
    [profData{iFile}.staFrames profData{iFile}.staTemporalPlot ...
        profData{iFile}.plotInfo profData{iFile}.bestSTAInd h] =...
        ifunc.sta.make_sta( tsMatrixAuto(iFile).st{1}, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        frameno,'do_print');
    choice = input('Keep (k)? >> ','s');
    if strcmp(choice, 'k')
        idxGoodFiles(end+1) = iFile;
        
    end
    catch
        profData{iFile}.staFrames=[];
        profData{iFile}.staTemporalPlot=[];
        profData{iFile}.plotInfo=[];
        profData{iFile}.bestSTAInd=[];
        warning('Too few spikes')
    end
    close all
    iFile
end
save('idxGoodFiles', 'idxGoodFiles')
%% load profData (for later processing steps)
numSquaresOnEdge=12;
profData = {};
load idxGoodFiles
for iFile = 1:length(idxGoodFiles)
    %     try
    [profData{iFile}.staFrames profData{iFile}.staTemporalPlot ...
        profData{iFile}.plotInfo profData{iFile}.bestSTAInd h] =...
        ifunc.sta.make_sta( tsMatrixAuto(idxGoodFiles(iFile)).st{1}, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        frameno,'do_print');
    
    
    %     catch
    %         profData{iFile}.staFrames=[];
    %         profData{iFile}.staTemporalPlot=[];
    %         profData{iFile}.plotInfo=[];
    %         profData{iFile}.bestSTAInd=[];
    %         warning('Too few spikes')
    %     end
%     close all
    iFile
end


%% get RFs
% ADD: profData should have 91, same as tsMatrixAuto

outAuto = {};
idxEmptyFile = [];

for iFileSel = 1:length(idxGoodFiles)
    %     try
    
    outAuto{iFileSel}.clusNum = tsMatrixAuto(idxGoodFiles(iFileSel)).clus_num;
    outAuto{iFileSel}.staIm = profData{iFileSel}.staFrames(:,:,profData{iFileSel}.bestSTAInd);
    outAuto{iFileSel}.staImAdj = beamer.beamer2array_mat_adjustment(outAuto{iFileSel}.staIm);
    iFileSel
    
    %     catch
    %         iFileSel
    %         warning('Too few spikes.')
    %         profData{iFileSel}.staFrames =[];
    %         profData{iFileSel}.staTemporalPlot  =[];
    %         profData{iFileSel}.plotInfo =[];
    %         profData{iFileSel}.bestSTAInd =[];
    %         outAuto{iFileSel}.clusNum =[];
    %         outAuto{iFileSel}.staIm=[];
    %         outAuto{iFileSel}.staImAdj =[];
    %         idxEmptyFile(end+1) = iFileSel;
    %     end
end
%% compare RFs

thresholdVal = 0.95;
numNeurs = length(outAuto);
comparisonMat = zeros(numNeurs);
for i=1:numNeurs
   for j=1: numNeurs
       if i~=j
           try
               comparisonMat(i,j) = corr2(outAuto{i}.staIm, outAuto{j}.staIm);
           catch
               comparisonMat(i,j)=0;
           end
       end
   end
end

figure, imagesc(comparisonMat), 
axis square, colorbar, caxis([0 1])
[rows,cols,vals] = find(comparisonMat>thresholdVal);
if ~isempty(rows)
    warning('Duplicates found');
end
%%
% find duplicates
idxDup = unique(rows);
allNotKeeps = [];
for i=idxDup
   idxIdxDupCurr = find(cols==i)';
   idxDupCurr = [i rows(idxIdxDupCurr)'];
   
   spikeCount = [];
   
   for j=1:length(idxDupCurr)
       
      spikeCount(end+1) = length(tsMatrixAuto(idxDupCurr(j)).st{1})
   end
   [Y idxMaxSC ] = max( spikeCount );
   notKeep = idxDupCurr(find(~ismember(spikeCount, Y)));
   allNotKeeps = [allNotKeeps notKeep];
end

%% selected RFs
% idxSel = [];
% for i = idxGoodFiles
%     figure, imagesc(outAuto{i}.staIm);
%     choice = input('Good? >> ','s');
%     if strcmp(choice, 'g')
%         idxSel(end+1) = i
%     end
%     close all
% end
% save idxGoodFiles idxGoodFiles 
%% Find centers
savePlots = 1;
idxSel = idxGoodFiles;

for i = 1:length(idxSel)
    [xFitPercent yFitPercent zInterp] = fit.find_rf_center_by_fitting_gaussian(...
        outAuto{i}.staImAdj,'mask_size_um',100);
    outAuto{i}.rfRelCtr = [round(xFitPercent*900/2) round(yFitPercent*900/2)]
    outAuto{i}.staImInterp=zInterp;

    fileName = sprintf('%d_RF_localization',outAuto{i}.clusNum);
    plotDir = sprintf('../Figs/Visual_Stim/%d/',outAuto{i}.clusNum);
    title(sprintf('Cluster %d Receptive Field', outAuto{i}.clusNum));

    if savePlots
        save.save_plot_to_file(plotDir, fileName, 'fig');
        save.save_plot_to_file(plotDir, fileName, 'eps');
    end
end

for i =1:length(idxSel)
    fprintf('%d) Cluster %d: move [%d %d]\n', i, outAuto{i}.clusNum,  ...
        outAuto{i}.rfRelCtr(1),outAuto{i}.rfRelCtr(2));

end

profDataMat = cells.merge_cells(outAuto, profData(idxSel));
save profDataMat.mat profDataMat