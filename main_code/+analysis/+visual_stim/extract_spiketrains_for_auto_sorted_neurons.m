% script_extract_spiketrains_for_single_neurons
%%
% paths
pathDef = dirdefs();
expName = get_dir_date;
runNo = input('run no >');
% matchRegIdx = input('Enter match reg idx # > ');
doLoadFrameNo = 1

for iFile = 1:size(cellMatchReg,1)
    
    autoClusNo = cellMatchReg{iFile,2};
    manualClusName = cellMatchReg{iFile,1};
    
    % load data
    flist = {}; run(fullfile(pathDef.dataIn,expName,'flist_all'))
    load(fullfile(pathDef.dataIn,expName,'configurations'))
    load(sprintf('%s%s_resultsForIan',pathDef.sortingOut, expName))
    % load framenos
    frameNoFileName = sprintf('frameno_run_%02d', runNo);
    if ~exist([frameNoFileName,'.mat'],'file')
        frameno = {};
        for i=1:length(configs(runNo).flistidx)
            frameno{end+1} = get_framenos(flist{i});
            progress_info(i,length(configs(runNo).flistidx(i)));
        end
        save(frameNoFileName, 'frameno')
        
        if doLoadFrameNo
            load(frameNoFileName, 'frameno');
        end
        
    end
    % select config inds
    fprintf('%s\n', cellMatchReg{iFile,1});
    fprintf('%d\n', cellMatchReg{iFile,2});
    spotsNum = input('Enter spots # > ');
    spotsName = sprintf('spots_%02d', spotsNum)
    spotsConfigIdx = cells.cell_find_str(configs.info,spotsName);
    configIdx = [1 2 3 spotsConfigIdx];
    configs(runNo).info(configIdx)'
    
    % extract spike times
    configColumn = 1;
    
    [tsMatrix ] = spiketrains.extract_single_neur_spiketrains_from_felix_sorter_results(...
        R, configColumn, configIdx,'clus_no', autoClusNo);
    
    neur = [];
    neur.info.exp_name = expName;
    neur.info.run_no = runNo;
    neur.info.auto_clus_no = autoClusNo;
    neur.info.ums_clus_name = manualClusName;
    
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
    
    neurName = sprintf('run_%02d_ums%s_auto%d',runNo, manualClusName, autoClusNo);
    save(fullfile(neuronsSavedDir,neurName), 'neur');
end
