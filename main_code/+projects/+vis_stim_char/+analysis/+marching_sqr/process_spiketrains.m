function dataOut = process_spiketrains(selClusIdx, varargin)
% dataOut = PROCESS_SPIKETRAINS(selClusIdx, varargin)

% settings
postSwitchTime_sec = 1;

% load all settings and data
load settings/stimParams_Marching_Sqr.mat
load settings/stimFrameInfo_marchingSqr.mat
script_load_data

% get dir names
dirNames = projects.vis_stim_char.analysis.load_dir_names;

dataOut = [] ;
dataOut.clus = selClusIdx;
dataOut.ts = {};
dataOut.segments = {};
dataOut.segmentsAdj = {};

for iClus=1:length(selClusIdx)
    
    filenameProf = sprintf('clus_merg_%05.0f', selClusIdx(iClus));
    load(fullfile(dirNames.prof, filenameProf))
    dataOut.ts{iClus} = neurM(marchingSqrRIdx).ts;

    [dataOut.segments{iClus} dataOut.segmentsAdj{iClus}]= spiketrains.segment_spiketrains_v2(...
        dataOut.ts{iClus}, stimChangeTs{marchingSqrRIdx}, 'post_switch_time_sec',2.5 );
    
    
      
end



end