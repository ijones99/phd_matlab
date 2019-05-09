%script save timestamps

global targetDir
% targetDir = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/5Mar2011_DSGCs_ij/analysed_data/rec12_21_7/5Channels'

patternToErase{1} = 'ntkLoadedDataElectrode*.mat';
patternToErase{2} = 'clustDataElectrode*.mat';
patternToErase{3} = 'mergDataElectrode*.mat';
patternToErase{4} = 'clusteredEventsPlotDataElectrode*.mat';
patternToErase{5} = 'clusteredEventsDataElectrode*.mat';
patternToErase{6} = 'MergedClustersElectrode*.mat';

for i=1:1
    for j=1:size(patternToErase,2)
    
        delete( fullfile(targetDir,patternToErase{j}))
        j
    end
    
end