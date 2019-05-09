% script_extract_spiketrains_for_single_neurons

% paths
pathDef = dirdefs();
expName = get_dir_date;
runNo = 1;
autoClusNo = 1606;

% load data
flist = {}; run(fullfile(pathDef.dataIn,expName,'flist_all'))
load(fullfile(pathDef.dataIn,expName,'configurations'))
load(sprintf('%s%s_resultsForIan',pathDef.sortingOut, expName))
% framenos
frameno = {};
for i=configs.flistidx
    frameno{end+1} = get_framenos(flist{i});
    progress_info(i,length(configs.flistidx));
end
save(sprintf('frameno_run_%02d', runNo), 'frameno')
%% select config inds
configIdx = [1 2 3 21];
configs.info(configIdx)';

%% extract spike times
configColumn = 1;

[tsMatrix ] = spiketrains.extract_single_neur_spiketrains_from_felix_sorter_results(...
    R, configColumn, configIdx,'clus_no', autoClusNo);

 neur.wn_checkerbrd.st = tsMatrix.st{1};
 neur.ms.st = tsMatrix.st{2};
 neur.mb.st = tsMatrix.st{3};
 neur.ms.spt = tsMatrix.st{4};
 
i=1; neur.wn_checkerbrd.frameno = frameno{configIdx(i)};
i=2; neur.ms.frameno = frameno{configIdx(i)};
i=3; neur.mb.frameno = frameno{configIdx(i)};
i=4; neur.spt.frameno = frameno{configIdx(i)};