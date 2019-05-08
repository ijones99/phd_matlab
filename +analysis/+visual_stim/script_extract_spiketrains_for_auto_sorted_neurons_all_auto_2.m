% %% For reworking previous data:
% load profDataRec;
% wn.profDataWn = profDataRec;
% wn.rfCenterCoords = zeros(length(wn.profDataWn),2);
% for i=1:length(wn.profDataWn)
%     
%     wn.selClusterNums(i)   = wn.profDataWn{i}.clusNum;
%     try
%     wn.rfCenterCoords(i,:) = wn.profDataWn{i}.rfRelCtr;
%     catch
%         wn.rfCenterCoords(i,:) = wn.profDataWn{i}.rfRelCtrFit;
%     end
% end
% %% For reworking previous data:
% load 'wnCheckBrdPosData_01.mat'
% wn.rfCenterCoords = zeros(length(wnCheckBrdPosData), 2)
% for i=1:length(wnCheckBrdPosData)
%     
%     %     wn.selClusterNums(i)   = wn.profDataWn{i}.clusNum;
%     
%     wn.rfCenterCoords(i,:) = wnCheckBrdPosData{i}.rfRelCtr;
%     
% end


%% get frameno
pathDef = dirdefs();
expName = get_dir_date;
runNo = input('Enter run no >> ');
% configNo = input('Enter config no >> ');
configColumn = runNo; configIdx= 1;
doLoadFrameNo = 1;
% load data
load(fullfile(pathDef.dataIn,expName,'configurations'))
load(sprintf('%s%s_resultsForIan',pathDef.sortingOut, expName))
clear frameno
% load framenos
frameNoFileName = sprintf('frameno_run_%02d', runNo);
if ~exist([frameNoFileName,'.mat'],'file')
    frameno = {};
    if ~isfield(configs(runNo), 'flist')
        configs = analysis.visual_stim.add_flist_data_to_configs_file(configs, expName);
    end
    
    frameno = get_framenos(configs(runNo).flist);
    save(frameNoFileName, 'frameno')
elseif ~exist('frameno','var')
    if doLoadFrameNo
        load(frameNoFileName, 'frameno');
    end
end

%% extract_spiketrains_for_single_neurons get RF centers

[all.profData all.idxGoodFiles all.selClusterNums  all.rfCenterCoords] = ...
    analysis.visual_stim.extract_RF_data_from_sorted_clusters(runNo, configIdx, R(2), frameno(2));

for i =1:length(all.profData)
    fprintf('%d) Cluster %d: move [%d %d]\n', i, all.selClusterNums(i),  ...
        all.rfCenterCoords(i,1), all.rfCenterCoords(i,2));
%     progress_info(i,length(all.idxGoodFiles));
end

wnFileName = ['all_', num2str(runNo)];
save(wnFileName, 'all');
%% compare coordinates
% Data that was recorded at given positions during experiment
% Locations for RFs in the data that are close to the positions used during
% the experiment

thresholdDist = 18;%um

[matchList allCombos] = geometry.match_closest_points_in_two_sets(...
    all.rfCenterCoords, wn.rfCenterCoords, thresholdDist);
fprintf('Clusters that have RF: ')
for i =1:size(matchList,1)
    fprintf('%d) Cluster %d: move [%d %d]\n', i, all.selClusterNums(matchList(i,1)),  ...
        all.rfCenterCoords(matchList(i,1),1), all.rfCenterCoords(matchList(i,1),2));

end

% remove repeats from match list
remIdx=[];
for i=1:size(matchList,1)
    idxCurr = find(matchList(:,1)==i);
    if length(idxCurr) > 1
       [Y,I] = min(matchList(idxCurr,3))
        selIdxCurr = idxCurr(I);
        currRemIdx = idxCurr(not(ismember(idxCurr,selIdxCurr)));
        remIdx(end+1:end+length(currRemIdx))= currRemIdx;
    end
end
matchList(remIdx,:)=[]

%% extract data to profDataRec
profDataRec = all.profData(matchList(:,1));

for iFile =1:length(profDataRec)
    
     % select config inds
    %     fprintf('%s\n', cellMatchReg{iFile,1});
    %     fprintf('%d\n', cellMatchReg{iFile,2});
    numInitStim = 3;
    profDataRec{iFile}.R_idx = [1 2 3 matchList(iFile,2)+numInitStim]
    configIdx = profDataRec{iFile}.R_idx;    
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
    infoFieldNames = fields(profDataRec{iFile});
    for iFld=1:length(infoFieldNames)
        neur.info = addfield(neur.info,infoFieldNames{iFld} , ...
            getfield(profDataRec{iFile}, infoFieldNames{iFld}));
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
    
    neurName = sprintf('run_%02d_configno_%02d_auto%d',runNo, configNo, ...
        neur.info.auto_clus_no);
    iName = 1;
    while exist(fullfile(neuronsSavedDir,[neurName,'.mat']),'file')
        neurName = sprintf('run_%02d_configno_%02d_auto%d_%d',runNo, ...
            configNo, neur.info.auto_clus_no,iName);
        iName = iName +1
    end
    save(fullfile(neuronsSavedDir,neurName), 'neur');
    
    progress_info(iFile,length(profDataRec))
end
fprintf('Done.\n')
