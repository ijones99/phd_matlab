% script_extract_spiketrains_for_single_neurons
%%
% paths
pathDef = dirdefs();
expName = get_dir_date;
runNo = input('run no >');
% matchRegIdx = input('Enter match reg idx # > ');
doLoadFrameNo = 1

load profData.mat

% prune profData to actual data recorded
% load config info
expName = get_dir_date; 
pathConfig = [def.projHamster, 'sorting_in/', expName,'/'];
load(fullfile(pathConfig,'configurations'));

if ~isfield(configs(1),'flist')
    configs = analysis.visual_stim.add_flist_data_to_configs_file(configs, expName);
end


for i=1:length(profData)
    fprintf('%d, ', profData{i}.clusNum);
end, fprintf('\n')
clusNosRec = input('Enter cluster numbers >> ')
% readback
fprintf('Readback:\n')
for i=1:length(clusNosRec)
   fprintf('%d) clus_%d\n',i ,clusNosRec(i))
end
% select profData clusters according to cluster
profDataRec = {};
for i=1:length(clusNosRec)
    for j=1:length(profData)
       if  profData{j}.clusNum == clusNosRec(i)
           profDataRec{i} = profData{j};
           profDataRec{i}.R_idx = j;
       end
    end
end

save('profDataRec.mat','profDataRec');
%% load data from R sorting of all stimuli and find equivalent cluster
% values in this R cell.

[profDataAllSorted idxGoodFiles selClusterNums  rfCenterCoords] = ...
    analysis.visual_stim.extract_RF_data_from_sorted_clusters(1,1);


% clear frameno
% configNo = 1;
% doLoadFrameNo = 1;
% R_idx = 1;
% frameNoFileName = sprintf('frameno_run_%02d_config_no_%02d', runNo, configNo);
% numSquaresOnEdge= [12 12];
% if ~exist([frameNoFileName,'.mat'],'file')
%     frameno = {};
%     for i=1:length(configs(runNo).flist)
%         frameno{end+1} = get_framenos(configs(runNo).flist{i});
%         progress_info(i,length(configs(runNo).flist));
%     end
%     save(frameNoFileName, 'frameno')
% elseif ~exist('frameno','var')
%     if doLoadFrameNo
%         load(frameNoFileName, 'frameno');
%     end
%     
% end
% load(fullfile(def.sortingOut,sprintf('%s_resultsForIan.mat', expName)));
% % obtain receptive fields from all clusters
% clustersAllSortedTogether = unique(R{R_idx ,configNo}(:,1))';
% sortedTogetherData = {};
% configColumn = runNo; configIdx= 1;
% [tsMatrixAuto ] = spiketrains.extract_single_neur_spiketrains_from_felix_sorter_results(...
%     R, configColumn, configIdx);
% for i=1:length(clustersAllSortedTogether)
%     [sortedTogetherData{i}.staFrames sortedTogetherData{i}.staTemporalPlot ...
%         sortedTogetherData{i}.plotInfo sortedTogetherData{i}.bestSTAInd h] =...
%         ifunc.sta.make_sta( tsMatrixAuto(i).st{1}, ...
%         white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
%         frameno{1});
%     figure, imagesc(sortedTogetherData{i}.staFrames(:,:,sortedTogetherData{i}.bestSTAInd));
%     close all
% end
% % do comparison of RFs
% thresholdVal = 0.95;
% numNeurs = length(profData);
% comparisonMat = zeros(numNeurs);
% for i=1:numNeurs
%    for j=1: numNeurs
%        if i~=j
%            try
%                comparisonMat(i,j) = corr2(profData{i}.staIm, profData{j}.staIm);
%            catch
%                comparisonMat(i,j)=0;
%            end
%        end
%    end
% end
% 
% figure, imagesc(comparisonMat)

%% Get R idx from config file and put into profData
flistConfigs = {};
configNo = 1;
for i=1:length(configs(configNo).flist)
    flistConfigs{i} = configs(configNo).flist{i};
    
end
flistConfigs = flistConfigs';
flistRec = flistConfigs;
fprintf('Edit flistRec to reflect notebook notes.')
open flistRec
% idxR has the length: #spots+initial stim(wn_check,...
% marching_sqr, moving bars
idxR = find(ismember(flistConfigs, flistRec));
idxRFileName = sprintf('run_%02d_configno_%02d',runNo, configNo);
save(fullfile(idxRFileName), 'idxR')

%%
clear frameno
configNo = 1;
for iFile =1:length(profDataRec)
    
    % load data
    load(fullfile(pathDef.dataIn,expName,'configurations'))
    load(sprintf('%s%s_resultsForIan',pathDef.sortingOut, expName))
    % load framenos
    frameNoFileName = sprintf('frameno_run_%02d_config_no_%02d', runNo, configNo);
    if ~exist([frameNoFileName,'.mat'],'file')
        frameno = {};
        for i=1:length(configs(runNo).flist)
            frameno{end+1} = get_framenos(configs(runNo).flist{i});
            progress_info(i,length(configs(runNo).flist));
        end
        save(frameNoFileName, 'frameno')
    elseif ~exist('frameno','var')  
        if doLoadFrameNo
            load(frameNoFileName, 'frameno');
        end
   
    end
    % select config inds
    %     fprintf('%s\n', cellMatchReg{iFile,1});
    %     fprintf('%d\n', cellMatchReg{iFile,2});
    numInitStim = 3;
    spotsConfigIdx =  idxR(numInitStim+iFile);
    configIdx = [1 2 3 spotsConfigIdx];
    %     configs(runNo).info(configIdx)'
    
    % extract spike times
  
    
    [tsMatrix ] = spiketrains.extract_single_neur_spiketrains_from_felix_sorter_results(...
        R, configNo, configIdx,'clus_no', profDataRec{iFile}.clusNum);
    
    neur = [];
    neur.info.exp_name = expName;
    neur.info.run_no = runNo;
    neur.info.auto_clus_no = profDataRec{iFile}.clusNum;
    %     neur.info.ums_clus_name = manualClusName;
    try
        neur.info.rfRelCtr = profDataRec{iFile}.rfRelCtrFit;
    catch
        neur.info.rfRelCtr = profDataRec{iFile}.rfRelCtr;
    end
    neur.wn_checkerbrd.st = tsMatrix.st{1};
    neur.ms.st = tsMatrix.st{2};
    neur.mb.st = tsMatrix.st{3};
    if length(tsMatrix.st)==4
    neur.spt.st = tsMatrix.st{4};
    else
        neur.spt.st = [];
    end
        
    i=1; neur.wn_checkerbrd.frameno = frameno{configIdx(i)};
    i=2; neur.ms.frameno = frameno{configIdx(i)};
    i=3; neur.mb.frameno = frameno{configIdx(i)};
    i=4; neur.spt.frameno = frameno{configIdx(i)};
    
    %dirs
    neuronsSavedDir = fullfile(pathDef.neuronsSaved,expName,'/');
    if ~exist(neuronsSavedDir,'dir'), mkdir(neuronsSavedDir), end
    
    neurName = sprintf('run_%02d_configno_%02d_auto%d',runNo, configNo, neur.info.auto_clus_no);
    save(fullfile(neuronsSavedDir,neurName), 'neur');
end
fprintf('Done.\n')
