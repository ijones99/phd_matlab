function [segments stimFramesTsStart stimFramesTsStop ] = ...
    extract_epocs_from_data(stMatrix, frameno, selectSegment, framenoSeparationTimeSec, doPrint )
% [segments stimFramesTsStart stimFramesTsStop ] = ...
%     extract_epocs_from_data(stMatrix, frameno, selectSegment, framenoSeparationTimeSec, doPrint)
% Purpose: input data and frameno (frameno assumed to already be adjusted
% with "shiftframets()" to obtain a cell with the timestamps for each epoch
% within the stimulus. E.g., if switches in frameno occur at 1 2 3 4
% seconds, then times between 1 and 2 as well as 3 and 4 will be used to
% produce two cells of spiketimes between these two times.
% 
% This function is also designed to be used with data that was
% spikesorted from multiple experiments: selectSegment will allow one to
% control which segment of the data is selected for analysis 
if nargin < 5
   doPrint = 0; 
    
end

if nargin < 4
    framenoSeparationTimeSec  = 0.2;
end

acqRate = 2e4;
%timestamps -> inputted
timeStamps = stMatrix.ts;
% which part of the data contains the data (in 2e4 Hz)
segmentBoundaries = get_segment_boundaries(stMatrix, selectSegment,frameno);
% adjust the frameno to the segment
[timeStamps frameno] = select_timestamps_and_frameno_from_combined_dataset( ...
    timeStamps, frameno, segmentBoundaries);
% stim frames start and stop locations
stimFramesTsStartStop = get_stim_start_stop_ts(frameno, framenoSeparationTimeSec)/acqRate;% start and stop locations in seconds
stimFramesTsStart = stimFramesTsStartStop(1:2:end); % in seconds
stimFramesTsStop = stimFramesTsStartStop(2:2:end); % in seconds

if doPrint
    timeToPrint = 2*60;%mins
   plot(frameno(1:2e4*timeToPrint),'b'), hold on; % plot frameno at 2e4 Hz
   indLastStartStop = find(stimFramesTsStartStop>timeToPrint,1)-1;
   plot(stimFramesTsStartStop(1:indLastStartStop)*acqRate, ...
       frameno(round(stimFramesTsStartStop(1:indLastStartStop)*acqRate)),'r*');
end

segments = {};
for i=1:length(stimFramesTsStart)
    
    segments{end+1} = select_spiketrain_epoch(timeStamps, ...
        stimFramesTsStart(i), stimFramesTsStop(i)) - stimFramesTsStart(i) - 1/acqRate;
    
end

end