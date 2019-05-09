function  [segmentsTs ] = ...
    extract_repeat_ts_from_data(timeStamps, framenoInfo, selectSegment)

acqRate = 2e4;

% start and end of stimulus seconds
stimStartTime = framenoInfo.stimFramesTsStartStop(1)/acqRate;
stimEndTime = framenoInfo.stimFramesTsStartStop(end)/acqRate;

% all stimulus stop points
stopPoints = [stimStartTime framenoInfo.joinPoints/acqRate stimEndTime]; % all stim change points

if isempty(framenoInfo.joinPoints) % one stimulus
    segmentBoundaries = [stimStartTime stimEndTime];
elseif length(framenoInfo.joinPoints) >= 1 % more than one stimulus
    segmentBoundaries = stopPoints([selectSegment selectSegment+1]);
end

% stim frames start and stop locations
stimFramesTsStartStop = framenoInfo.stimFramesTsStartStop/acqRate;% start and stop locations in seconds

% take relevant time stamps
stimFramesTsStartStop(find(or(stimFramesTsStartStop<segmentBoundaries(1),...
    stimFramesTsStartStop>segmentBoundaries(2)))) = [];

stimFramesTsStart = stimFramesTsStartStop(1:2:end); % in seconds
stimFramesTsStop = stimFramesTsStartStop(2:2:end); % in seconds

segmentsTs = {};
for i=1:length(stimFramesTsStart)
    
    segmentsTs{end+1} = select_spiketrain_epoch(timeStamps, ...
        stimFramesTsStart(i), stimFramesTsStop(i)) - stimFramesTsStart(i);
    
end



end