function [framenoInfo] = get_frameno_info(dirName , varargin)

P.pauseInterval = 0.2; 
P.doPlot = 0;
P = mysort.util.parseInputs(P, varargin, 'error');

framenoInfo.dirName = dirName; % T directory name
framenoName = dir(fullfile('../analysed_data/',framenoInfo.dirName,'frameno*shift860*' )); 
load(fullfile('../analysed_data/',framenoInfo.dirName, framenoName(1).name));% load the frameno

% already shifted
% frameno = shiftframets( frameno); % take into account the projector delay

[framenoInfo.stimFramesTsStartStop ] = ...
    get_stim_start_stop_ts(frameno, P.pauseInterval, P.doPlot);



end