%% check square flash responses

%%
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
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')


%% setup for auto sorting

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
% % ana.startHDSorting
%     P.spikeCutting.maxSpikes = 600000; % 20000000;This is crucial for computation time
%
%     P.noiseEstimation.minLength = 400000; % 300000;This also effects computation time
tic 
spikesorting.felix_sorter.start_sorting(batchInfo, 8)
toc
fprintf('ALL DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
%% stim changes
interStimTime=0.5;
    for i=1:length(configs(runNo).flist)
        currFrameno = get_framenos(configs(runNo).flist{i});
        stimChangeTs{i} = get_stim_start_stop_ts2(currFrameno{1},interStimTime);
    end

%% plot flashes
expName = get_dir_date;
rasterColor = {'r','k'};

rVals = [1 2 3];
% fileInfo = dir('../proc/*ntk');
% fileTimes = [1040; 1116; 1208; 1357];
% load data
RflashingSqr = load(sprintf('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/flashing_sqr_during_exp/%s_resultsForIan',expName));

allClus = unique(RflashingSqr.R{2}(:,1));
% allClus = wn.selClusterNums;
for iClusNo = 1:length(allClus)%$wn.selClusterNums(1:end) % go through all clusters
%     for iClusNo = 1:length(refClusInfo.clus_no)%$wn.selClusterNums(1:end) % go through all clusters
    % figure
    h=figure, hold on
    figs.set_size_fig(h,[  641          27        1230         987]);
    
    try
        for iR = 1:length(rVals)
            % plot all cluster responses to one spot
            runNo=1;
            
            currRIdx = rVals(iR)%refClusInfo.R_idx(iClusNo);
            subplot(length(rVals),1,iR)
            % stim changes
            currStimChangeTs = stimChangeTs{currRIdx};
            
            
            rasterSpacing=1;
            
            onIdx = 1:2:length(currStimChangeTs);
            idxRaster = [onIdx' onIdx'+2];
            
            xlim([0 4])
            ylim([-1 10])
            
            
            currClusNo = allClus(iClusNo);%   refClusInfo.clus_no(iClusNo);
            stCurr = spiketrains.extract_st_from_R(RflashingSqr.R{currRIdx, runNo}, currClusNo);
            plot.raster_series(stCurr/2e4, currStimChangeTs/2e4, idxRaster, 'color','r');
            %         titleName = {'ON', 'OFF'};
            title(sprintf('Full-Field Flashing: Clus # %d, R# %d', allClus(iClusNo), currRIdx));            
%             title(sprintf('Full-Field Flashing: Clus # %d, R# %d, File time: %d', refClusInfo.clus_no(iClusNo), currRIdx,fileTimes(iR)));
            %         subPCnt = subPCnt+1;
        end
    catch
        fprintf('error');
    end
    
       pause(0.5)
        doSave = 0;
        if doSave
            saveToDir = '../Figs/Preparation_Rundown_Testing/', mkdir(saveToDir);
            fileName = sprintf('ffFlash%d', allClus(iClusNo));
            save.save_plot_to_file(saveToDir, fileName, 'fig'  )
        end
        close all
end
