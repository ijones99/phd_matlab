% script_do_vis_stim_experiment_with_auto_wn_sorting

%% SCAN ARRAY FOR ACTIVITY

% send visual stimulus

% plot configs
% configDirName = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/'
configDirName = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/30x6_spc1_tile7x14_main_ds_scan'
numRows = 8; confInt = 15:7:numRows*7 ;
iConfigNumber=sort([confInt+1 confInt+5]);
% iConfigNumber = 1:98;
% plotConfig = 'n';
plotConfig = input('Plot electrode config? [y/n]','s')
if strcmp(plotConfig,'y')
    figure, hold on
    gui.plot_hidens_els, hold on
    plot_electrode_config_by_num(configDirName, iConfigNumber,'plot_rand_color',...
        'label_with_number');
end
%% select configurations
% configNos = [24 26];patternLength = length(configNos);
% for i = 1:7
%     configNos = [configNos configNos(end-1:end)+...
%         7*ones(1,patternLength)];
% end
configNos = iConfigNumber;
fileNameConfig = configs.get_el_config_names_by_number(configDirName, configNos);

junk = input('Please start visual stimulus and press enter when ready >>');
% send configuration during visual stimulus
configs.send_configs_to_chip(configDirName, fileNameConfig,'rec_time',15)%

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
configDirName = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/30x6_spc1_tile7x14_main_ds_scan';
load(fullfile(configDirName,'configCtrXY'));

for i=1:length(flist)
    hidens_generate_amplitude_map(activity_map{i},'no_border','no_colorbar', ...
        'no_plot_format','do_use_max'); %'remove_noisy_chs',
    text(configCtrX(configNos(i)),configCtrY(configNos(i)),num2str(configNos(i)-1),...
        'Color',  [1 1 1]);
end
!mkdir ../Figs/Activity_Scan
save.save_plot_to_file('../Figs/Activity_Scan/', 'Amp_Map','fig');

% plot activity map
figure
gui.plot_hidens_els('marker_style', 'cx'), hold on
title('Activity Map')
plot.activity_map.hidens_plot_activity_map(activity_map)
for i=1:length(flist)
    text(configCtrX(configNos(i)),configCtrY(configNos(i)),num2str(configNos(i)-1),...
        'Color',  [1 1 1]);
end
save.save_plot_to_file('../Figs/Activity_Scan/', 'Freq_Map','fig');
title('Config ID numbers (not file numbers)')
fprintf('Remember: send config to chip!\n');
%% center on config
configs.center_on_config

%% SEND CONFIG!!!

%% run whitenoise stimulus
% !!! DO ON STIM COMPUTER

%%
% % ADD: Create flist
% [flist batchInfo.experiments(iBatchIdx).flistName ] =  ...
%     flists.make_flist_select('all',[],'no_flist_id','no_run_no');
initDir = pwd;
def = dirdefs();
expName = get_dir_date;

runNo = input('Enter run no >> ');
flistName = sprintf('flist_wn_checkerboard_n_%02d',runNo);
[flist ] =  ...
    flists.make_flist_select(flistName,[],'no_flist_id','no_run_no');
% flist = {}; eval(flistName);
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
configs = spikesorting.felix_sorter.create_configs_file(batchInfo, 'exp_name', expName,...
    'add_dir_to_path', 'wn_checkerboard_during_exp');

%%
cd(batchInfo.in_path)
fileNameIsNew = 0
dirNameBatch = '~/ln/sorting_in/batch_info/';
while fileNameIsNew ~= 1
    batchFileName = input('Enter file name to save batch file. >> ','s');
    if ~exist([fullfile('batch_info',batchFileName), '.mat'],'file')
        save(fullfile(dirNameBatch,batchFileName),'batchInfo');
        fileNameIsNew = 1;
    else
        warning('File exists. Please choose another name...');
    end
    
end

%% !!!!!!!! RUN THIS ON HAL
% % ana.startHDSorting
%     P.spikeCutting.maxSpikes = 600000; % 20000000;This is crucial for computation time
%
%     P.noiseEstimation.minLength = 400000; % 300000;This also effects computation time
tic
spikesorting.felix_sorter.start_sorting(batchInfo, 3)
toc
fprintf('ALL DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
%%
cd(initDir)
def = dirdefs();
expName = get_dir_date;



runNo = input('Enter run no >> ');
flistName = sprintf('flist_wn_checkerboard_n_%02d',runNo);
eval(sprintf('!cp ~/ln/sorting_in/wn_checkerboard_during_exp/%s/flist_all.m flist_wn_checkerboard_n_%02d.m',...
    expName,runNo))
flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')

%% get list of neurons found automatically (white noise)
runNo = input('Run number >> ');
% load configurations: configs(1)
load(fullfile(def.projHamster, 'sorting_in', 'wn_checkerboard_during_exp',...
    expName, 'configurations.mat'));
% load sorted data
load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', ...
    sprintf('%s_resultsForIan.mat', expName)));

% configcolumn/run number is a set of stimuli;configIdx is the
configColumn = runNo; configIdx= 1;
%% get frameno info
close all
clear frameno
mkdir(fullfile(dirNameFFile))
framenoName = strcat('frameno_', flistFileNameID,'.mat');
if ~exist(fullfile(dirNameFFile,framenoName))
    frameno = get_framenos(flist, 2e4*60*20);
    save(fullfile(dirNameFFile,framenoName),'frameno');
else
    load(fullfile(dirNameFFile,framenoName));
end

% get file names
fileNames = dir(strcat(dirNameSt,'*.mat'));
% make STA directory
dirSTA = strrep(strrep(dirNameSt,'analysed_data', 'Figs'),'03_Neuron_Selection/','');
mkdir(dirSTA)



%% during experiment: get & select RF centers
% load data
flist={}; flist_marching_sqr_over_grid_n_01
load('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/marching_sqr_over_grid_during_exp/25Nov2014_resultsForIan.mat');
frameno = get_framenos(flist)
save('frameno_marching_sqr_over_grid','frameno')
load settings/stimParams_Marching_Sqr_over_Grid.mat

profData = analysis.visual_stim.marching_sqr_over_grid.get_rf(R, frameno, Settings);

%%
figure
doSelRFCtr = input('select receptive field center points ? [y] >> ','s');
xyRFCtrCoords = [];

imDir = '../Figs/marching_sqr_over_grid/single_clusters';
mkdir(imDir)

for i=1:length(profData)
    
    subplot(2,2,1);
    imagesc(profData{i}.staImBrightAdj);
    axis equal, colormap gray;
    
    subplot(2,2,2);
    imagesc(profData{i}.staImDarkAdj);
    axis equal, colormap gray;
    
    
    subplot(2,2,3);
    myImInterp = plot.scaled_im(profData{i}.staImBrightAdj,3);
    plot.scaled_im(profData{i}.staImBrightAdj,3);
    axis equal, colormap gray;
    title(sprintf('ON, maxRF=%1.3f', max(max(profData{i}.staImBrightAdj))));
    
    subplot(2,2,4);
    myImInterp = plot.scaled_im(profData{i}.staImDarkAdj,3);
    plot.scaled_im(profData{i}.staImDarkAdj,3);
    axis equal, colormap gray
    title(sprintf('ON, maxRF=%1.3f', max(max(profData{i}.staImDarkAdj))));
    %     pause(0.1)
    
    titleName = sprintf('idx-%d-rf-clus-%d', i, profData{i}.info.clus_no);
    suptitle(titleName);
    if strcmp(doSelRFCtr,'y')
        currRFCtr = ginput(1);
        szIm = size(myImInterp); szIm = szIm(2:-1:1);
        currRFCtrCtrd = currRFCtr-szIm/2;
        % !!! need offset
        [xOut yOut  ] = geometry.scale_xy_pt(currRFCtrCtrd(1),currRFCtrCtrd(2),...
            [-1 1].*szIm/2,  [-1 1].*szIm/2,...
            [-400 400],[-400 400]);
        xyRFCtrCoords(i,:) = [xOut yOut];
    end
    fileName = sprintf('idx_%d_rf_clus_%d', i, profData{i}.info.clus_no);
    save.save_plot_to_file(imDir,fileName,{'fig','eps'});
end

doSaveRFCtrPoints = input('Save receptive field center points ? [y] >> ','s');
if doSaveRFCtrPoints == 'y'
    save('xyRFCtrCoords','xyRFCtrCoords')
end

% [wn.profData wn.idxGoodFiles wn.selClusterNums  wn.rfCenterCoords] = ...
%     analysis.visual_stim.extract_RF_data_from_sorted_clusters(1, configIdx, R, frameno)

% % idxGoodFiles refers to R cell
% for i =1:length( wn.idxGoodFiles)
%     fprintf('%d) Cluster %d: move [%d %d]\n', i, wn.selClusterNums(i),  ...
%         wn.rfCenterCoords(i,1), wn.rfCenterCoords(i,2));
% end
%
% wnFileName = ['wn_', num2str(runNo)];
% save(wnFileName, 'wn');
%
%% show progress while doing spots (minutes recorded)
MBperMin=213;
possibleStimNames = {...
    'spots', ...                        %1
    'spots_with_moving_gratings'...     %2
    };
for i=1:length(possibleStimNames)
    fprintf('%d) %s\n', i,possibleStimNames{i});
end
fprintf('\n')
stimTrackingSelection = input('Select one above [1 ... ] >> ');
if stimTrackingSelection == 1
    fullLengthMins = 3.2;
elseif stimTrackingSelection == 2
    fullLengthMins = 3.2;
end
fullLengthMins = 3.2;
currFileSize = 0;
for i=1:1e9
    fileData = dir('../proc/*ntk');
    [~,idx] = sort([fileData.datenum]);
    
    if fileData(idx(end)).bytes~=currFileSize;
        fprintf('%3.1f mins left: ',...
            fullLengthMins-fileData(idx(end)).bytes/1e6/MBperMin )
        fprintf('%s', fileData(idx(end)).name);
        texts.print_dots(100*(fileData(idx(end)).bytes/1e6/MBperMin)/fullLengthMins,10)
        fprintf('\n')
    end
    currFileSize = fileData(idx(end)).bytes;
    pause(0.25);
    
end

%% if wn does not exist...
wn = {};
load profDataRec;
% numRecCells = input('Number of recorded cells >> ');
wn.profData = profDataRec;%(1:numRecCells);
for i =1:length( wn.profData)
    try
        wn.rfCenterCoords(i,:) = wn.profData{i}.rfRelCtr;
    catch
        wn.rfCenterCoords(i,:) = wn.profData{i}.rfRelCtrFit;
    end
    wn.selClusterNums(i) = wn.profData{i}.clusNum;
end
%  wn.profData{1}, for example, is the data for the first sorted neuron
save wn wn

%% if only wnCheckBrdPosData exists
load wnCheckBrdPosData_01
wn = {};

% numRecCells = input('Number of recorded cells >> ');

for i =1:length(wnCheckBrdPosData)
    
    wn.rfCenterCoords(i,:) = wnCheckBrdPosData{i}.rfRelCtr;
    currClusNumNPos = strfind(wnCheckBrdPosData{i}.fileName,'n');
    currClusNo = str2num(wnCheckBrdPosData{i}.fileName(currClusNumNPos+1:end));
    wn.selClusterNums(i) = currClusNo;
end
%  wn.profData{1}, for example, is the data for the first sorted neuron
save wn wn



%% reworking data: create wn structure for reviewing data
wn = {};
load profDataSel;
% numRecCells = input('Number of recorded cells >> ');
wn.profData = profDataSel;%(1:numRecCells);
for i =1:length( wn.profData)
    wn.rfCenterCoords(i,:) = wn.profData{i}.rfRelCtr;
    wn.selClusterNums(i) = wn.profData{i}.clusNum;
end
%  wn.profData{1}, for example, is the data for the first sorted neuron
save wn wn


%% fix later
% input recorded cluster numbers
clusNumsRec = input('Enter cluster numbers >> ');
% get idx for wn (check for accuracy with paper logbook)
idxWn = find(ismember(wn.selClusterNums, clusNumsRec));
% apply to data
wn.profData = wn.profData(idxWn);
wn.idxGoodFiles = wn.idxGoodFiles(idxWn);
wn.rfCenterCoords = wn.rfCenterCoords(idxWn,:);
wn.selClusterNums = wn.selClusterNums(idxWn);
% fix idx Good Files
idxGoodFiles = idxGoodFiles(idxWn);
save wn wn

%% alternative loading for manually-sorted data
wn.rfCenterCoords = zeros(length(wnCheckBrdPosData),2)
for i=1:length(wnCheckBrdPosData)
    wn.rfCenterCoords(i,:) = wnCheckBrdPosData{i}.rfRelCtr;
end



