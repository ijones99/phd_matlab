function [psthDataMeanSmoothed psthData psthDataSmoothed] = ...
    plot_psth_for_repeats(timeStamps, frameno, repeatsToPlot, binSize)
% function plot_rasters_for_repeats(timeStamps, frameno, repeatsToPlot)
% Is used for natural movie stimuli
% shift timestamps for stimulus frames
%
% author: ijones
frameno = shiftframets(frameno);

%% raster plot settings
rowSpacing = 1; % spacing between the plotted rows
rangeLim = 0.42;
acqRate = 20000; % samples per second
sigmaVal = 0.025; %msec

% get the stimulus start stop timestamps
stimFramesTsStartStop = get_stim_start_stop_ts(frameno, 0.2);
%% plot raster
% DEFINITIONS
% stimulus group: a group of repetitions of the same stimulus
% repetition: one stimulus within a group
% index stimulus timestamp: index for the timestamp of the stimulus start
% or stop

plotStartTimeZ = -0;
plotEndTimeZ = 30;
spikeMarkerHeight = 0.8;
stimMarkerHeight = 1;
numRepsPerGroup = length(repeatsToPlot);
iPlotCounter = 1;
% cycle through the stimulus groups
% the first timestamp for a series cluster
indStimTsStartFirst = repeatsToPlot(1)*2-1;
indStimTsStart = repmat(indStimTsStartFirst,1,numRepsPerGroup)+[0:2:numRepsPerGroup*2-2];

% go through each repetition for the stimulus (along the x
% direction)
psthData = [];
for iIndStimTsStart = 1:length(indStimTsStart)
    stimStartTs = stimFramesTsStartStop(indStimTsStart(iIndStimTsStart))/acqRate;
    stimEndTs = stimFramesTsStartStop(indStimTsStart(iIndStimTsStart)+1)/acqRate;
    
    if isempty(psthData)
        psthData  = get_psth(timeStamps,stimStartTs,stimEndTs, plotStartTimeZ, ...
            plotEndTimeZ, binSize);
    else
   
        psthData( iIndStimTsStart,:) = get_psth(timeStamps,stimStartTs,stimEndTs, plotStartTimeZ, ...
            plotEndTimeZ, binSize);
    end
    iPlotCounter = iPlotCounter+1;
    
end
psthDataMean = mean(psthData,1); % take mean of psthData
psthDataSmoothed = zeros(size(psthDataMean)); % init matrix
for i=1:size(psthData,1) % smooth each binned dataset
   psthDataSmoothed(i,:)  = conv_gaussian_with_spike_train(psthData(i,:), ...
       sigmaVal, binSize);
  
end
% smooth the mean psth
[psthDataMeanSmoothed ] = conv_gaussian_with_spike_train(psthDataMean, sigmaVal, binSize);
plot([0:binSize:(length(psthDataMeanSmoothed)-1)*binSize], psthDataMeanSmoothed, ...
    'LineWidth',1);

end