%% run whitenoise stimulus
% !!! DO ON STIM COMPUTER

%%
% ~/ln/IanSortingOut/flashing_sqr_during_exp/05Nov2014*
% % ADD: Create flist
% [flist batchInfo.experiments(iBatchIdx).flistName ] =  ...
%     flists.make_flist_select('all',[],'no_flist_id','no_run_no');
initDir = pwd;
def = dirdefs();
expName = get_dir_date;

runNo = input('Enter run no >> ');
flistName = sprintf('flist_flashing_sqr_n_%02d',runNo);
[flist ] =  ...
    flists.make_flist_select(flistName,[],'no_flist_id','no_run_no');
% flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
% dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
% dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
% dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')


% setup for auto sorting

batchInfo = {};
batchInfo.data_path = def.expRecordings;
batchInfo.out_path = [def.sortingOut,'flashing_sqr_during_exp/'];
batchInfo.in_path = [def.projHamster, 'sorting_in/flashing_sqr_during_exp/'];
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
    'add_dir_to_path', 'flashing_sqr_during_exp');

% %%
% cd(batchInfo.in_path)
% fileNameIsNew = 0
% while fileNameIsNew ~= 1
%    batchFileName = input('Enter file name to save batch file. >> ','s');
%    if ~exist([fullfile('batch_info',batchFileName), '.mat'],'file')
%        save(fullfile(batchFileName),'batchInfo');
%        fileNameIsNew = 1;
%    else
%        warning('File exists. Please choose another name...');
%    end
%     
% end

%% !!!!!!!! RUN THIS ON HAL
% % ana.startHDSorting
%     P.spikeCutting.maxSpikes = 600000; % 20000000;This is crucial for computation time
%
%     P.noiseEstimation.minLength = 400000; % 300000;This also effects computation time
tic 
spikesorting.felix_sorter.start_sorting(batchInfo, 6)
toc
matlabpool close
fprintf('ALL DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')

%%

%% get list of neurons found automatically (white noise)
runNo = input('Run number >> ');
% load configurations: configs(1)

load(fullfile(def.projHamster, 'sorting_in', 'flashing_sqr_during_exp',...
    expName, 'configurations.mat'));
% load sorted data
load(fullfile(def.sortingOut, 'flashing_sqr_during_exp', ...
    sprintf('%s_resultsForIan.mat', expName)));

% configcolumn/run number is a set of stimuli;configIdx is the
configColumn = runNo; configIdx= 1;
% get frameno info
cd(initDir)
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
% fileNames = dir(strcat(dirNameSt,'*.mat'));
% make STA directory
% dirSTA = strrep(strrep(dirNameSt,'analysed_data', 'Figs'),'03_Neuron_Selection/','');
% mkdir(dirSTA)

interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno{1},interStimTime);

% plot flashes
rasterColor = {'r','k'};


allClus = unique(R{1}(:,1));
h=figure, hold on
figs.set_size_fig(h,[  1          1        1730         1400]);
numClus = length(allClus);
subplotSize = ceil(sqrt(numClus));

for iClusNo = 1:numClus%length(allClus)%$wn.selClusterNums(1:end) % go through all clusters
    %     for iClusNo = 1:length(refClusInfo.clus_no)%$wn.selClusterNums(1:end) % go through all clusters
    % figure
    subplot(subplotSize, subplotSize, iClusNo)
    
    % plot all cluster responses to one spot
    runNo=1;
    
    rasterSpacing=1;
    
    onIdx = 1:2:length(stimChangeTs);
    idxRaster = [onIdx' onIdx'+2];
    
    
%     
    grid on
    currClusNo = allClus(iClusNo);%   refClusInfo.clus_no(iClusNo);
    stCurr = spiketrains.extract_st_from_R(R{1, runNo}, currClusNo);
    plot.raster_series(stCurr/2e4, stimChangeTs/2e4, idxRaster, 'color','r');
    ylim([-0.5 length(stimChangeTs)/2])
    xlim([0 mean(diff(stimChangeTs/2e4)*2)])
    
    
end
configNoSel = input('Config number >> ');
hold on
titleName = sprintf('Full-Field Flash for %s - Config %d',expName,configNoSel);

suptitle(titleName)
saveToDir = '../Figs/ActivityCheck/', mkdir(saveToDir);
fileName = strrep(titleName,' ','_');
save.save_plot_to_file(saveToDir, fileName, 'fig'  )

