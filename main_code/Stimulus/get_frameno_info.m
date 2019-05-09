function [framenoInfo] = get_frameno_info(dirName )
% [framenoInfo] = get_frameno_info(dirName )

pauseInterval = 0.2; 

framenoInfo.name = dirName; % T directory name
framenoName = dir(fullfile('../analysed_data/',framenoInfo.name,'frameno*shift860*' )); 
load(fullfile('../analysed_data/',framenoInfo.name, framenoName.name));% load the frameno

[framenoInfo.stimFramesTsStartStop framenoInfo.joinPoints] = ...
    get_stim_start_stop_ts(frameno, pauseInterval);

framenoInfo.stimFramesTsStartStopCol = reshape(framenoInfo.stimFramesTsStartStop,2, length(framenoInfo.stimFramesTsStartStop)/2)';





end