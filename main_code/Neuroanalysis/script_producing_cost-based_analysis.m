% script_for_natural_movies_stimulus analysis
flist = {};
flist_for_birds_mov_orig_stat_surr_med;
% flist_for_birds_dyn_med_and_shuffled_med;
loadStimFrameTs = 0;

recDir = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';
genDataDir = fullfile(recDir,'/29Mar2012/analysed_data/');
% fileNameID = 'T13_14_30_5_birds_dyn_med_and_shuffled_med_plus_others';
fileNameID = 'T13_14_30_2_birds_mov_orig_stat_surr_med_plus_others';
specDataDir = fullfile(genDataDir, fileNameID);
framenoFileName = strcat('frameno_', fileNameID, '.mat');
% load light timestamp framenos
load(fullfile(genDataDir,fileNameID,framenoFileName));

% shift timestamps for stimulus frames
frameno = shiftframets(frameno);

if ~loadStimFrameTs
    % get stop and start times
    interStimIntervalSec=.2;
    stimFramesTsStartStop = get_stim_start_stop_ts(frameno, interStimIntervalSec);
    
    % save
    save(fullfile(specDataDir,'stimFramesTsStartStop.mat'), 'stimFramesTsStartStop');
else
    load(fullfile(specDataDir,'stimFramesTsStartStop.mat'));
end