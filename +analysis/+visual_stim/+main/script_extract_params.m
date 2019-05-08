%%

% stCurr = spiketrains.extract_st_from_R(Rall.R{currRIdx, runNo}, currClusNo);
%
% neur = analysis.visual_stim.compute_vis_stim_parameters3(neur,...
%     spotsSettings, barsSettings,'save_plot','plot');%


% SPOTS
% stimChangeTs
% neur.spt.st

% BARS
% stimChangeTs

% load data
% --- done in other script: script_load_analysis_data ---

pathDef = dirdefs();%expName = '17Jun2014';
dirSettings = 'settings/'
expName = get_dir_date
load all_1
load refClusInfo
load refClusCtrLoc.mat
load refFileCtrLoc.mat
% load data from R
R = analysis.visual_stim.load_R_data;
% load and save frameno info
frameno = analysis.visual_stim.load_frameno
stimChangeTs = analysis.visual_stim.load_stim_change_ts; %


% enter options
runNo = 1;
rIdxMB = input('idx moving bar>>');
fprintf('Moving bar: %s\n', refFileCtrLoc.flist{rIdxMB});
rIdxMS = input('idx marching square>>');
fprintf('marching square: %s\n', refFileCtrLoc.flist{rIdxMS});
rIdxWN = input('idx whitenoise checkerboard>>');
fprintf('whitenoise checkerboard: %s\n', refFileCtrLoc.flist{rIdxWN});

refFileCtrLoc.flist{rIdxMB}
% load settings
dirSettings = 'settings/';
spotsSettings = file.load_single_var(dirSettings, 'stimFrameInfo_spots.mat');
barsSettings = file.load_single_var(dirSettings,  'stimFrameInfo_movingBar_2Reps.mat');
marchingSqrSettings = file.load_single_var(dirSettings,  'stimFrameInfo_marchingSqr.mat');

% % white noise info
% rIdxWN = cells.cell_find_str2(refFileCtrLoc.stim_names,'wn_checkerboard');
% if length(rIdxWN)>1
%     x = input('More than one wn recording found >> ');
% end
% rIdxWN = rIdxWN(1);
% find wn_checkerboard file
flistName = refFileCtrLoc.flist{rIdxWN};
flist = {}; eval(sprintf('flist{end+1} = ''%s'';', flistName));

% load data
h5DataWN = h5.load_h5_data(flist);


%
neurParams = {};
runNo = 1;

mkdir(fullfile(pathDef.neuronsSaved,expName));
% refClusInfo has data for all clusters
for iClus = 1:length(refClusInfo.clus_no)
    currClusNo = refClusInfo.clus_no(iClus);
    % spot info
    neurParams{iClus}.spt.st = spiketrains.extract_st_from_R(R{refClusInfo.R_idx(iClus), runNo}, currClusNo)';
    neurParams{iClus}.spt.stim_change_ts = stimChangeTs{refClusInfo.R_idx(iClus)};
    neurParams{iClus}.spt.flist= refClusInfo.flist{iClus};
    neurParams{iClus}.spt.r_idx= refClusInfo.R_idx(iClus);
    neurParams{iClus}.spt.settings = spotsSettings;
        
    
    % bar info
    neurParams{iClus}.mb.st = spiketrains.extract_st_from_R(R{rIdxMB, runNo}, currClusNo)';
    neurParams{iClus}.mb.stim_change_ts = stimChangeTs{rIdxMB };
    neurParams{iClus}.mb.flist= refFileCtrLoc.flist{rIdxMB};
    neurParams{iClus}.mb.r_idx= rIdxMB;
    neurParams{iClus}.mb.settings = barsSettings;
    
    neurParams{iClus}.ms.st = spiketrains.extract_st_from_R(R{rIdxMS, runNo}, currClusNo)';
    neurParams{iClus}.ms.stim_change_ts = stimChangeTs{rIdxMS };
    neurParams{iClus}.ms.flist= refFileCtrLoc.flist{rIdxMS};
    neurParams{iClus}.ms.r_idx= rIdxMS;
    neurParams{iClus}.ms.settings = marchingSqrSettings;
    
    neurParams{iClus}.info.clus_ctr_xy =  refClusInfo.clus_ctr_xy(iClus,:);
    neurParams{iClus}.info.clus_no = refClusInfo.clus_no(iClus);
    
    % add sta info
    idxAllData = cells.cell_find_number_in_field(all.profData,'clusNum',currClusNo);
    neurParams{iClus}.sta = all.profData{idxAllData} ;
    
    
    % add footprint info
    neurParams{iClus}.sta.st = spiketrains.extract_st_from_R(R{rIdxWN, runNo}, currClusNo)';
    currNumTsForFootprint = 100;
    
    ts = neurParams{iClus}.sta.st ;
    if length(ts) < currNumTsForFootprint
        currNumTsForFootprint = length(ts)
    end
    
    preSpikeTime = 10;
    postSpikeTime = 10;
    neurParams{iClus}.footprint = h5.extract_waveforms_from_h5(h5DataWN{1}, ts(1:currNumTsForFootprint), ...
        'pre_spike_time', preSpikeTime,'post_spike_time',postSpikeTime );
    neurParams{iClus}.footprint.source = 'whitenoise checkerboard';
    neurParams{iClus}.footprint.r =  rIdxWN;
    
    % add refClusInfo
    idxRefClusInfo = find(refClusInfo.clus_no==refClusInfo.clus_no(iClus));
    neurParams{iClus}.info.idxR = refClusInfo.R_idx(idxRefClusInfo);
    neurParams{iClus}.info.file_ctr_xy = refClusInfo.file_ctr_xy(idxRefClusInfo,:);
    neurParams{iClus}.info.flist = refClusInfo.flist{idxRefClusInfo};
    
    neurParams{iClus} = analysis.visual_stim.compute_vis_stim_parameters3(neurParams{iClus},...
        spotsSettings, barsSettings);%,'save_plot','plot'
    
    neur = neurParams{iClus};
    
    fileNameNeur = sprintf('%s_run_%d_clus_%d', expName, runNo, currClusNo);
    save(fullfile(pathDef.neuronsSaved,expName, fileNameNeur), 'neur')
    close all
    progress_info(iClus, length(refClusInfo.clus_no));
end

neur = neurParams
%% add to neur paramout
for iAppend = 1:length(neurParams)
    paraOutputMat.neur_names{end+1} = num2str(neurParams{iAppend}.info.clus_no);
    try
        paraOutputMat.params(end+1,1:6)=struct2array(...
            rmfield(neurParams{iAppend}.paramOut,'spt_pref_brightness'));
    catch
        paraOutputMat.params(end+1,1:6) = nan(1,6);
    end
end


