function spikeTrains = extract_spiketrain_repeats_to_cell(spikeTrainsConcatenated, ...
    stimFramesTsStartStop,adjustToZero,varargin)
% FUNCTION spikeTrains = EXTRACT_SPIKETRAIN_REPEATS_TO_CELL(spikeTrainsConcatenated, stimFramesTsStartStop,adjustToZero)
%
% Purpose: chop continuous spike train into cells.
%   arguments
%   -> spikeTrainsConcatenated: spiketimes
%   -> stimFramesTsStartStop: times at which repeats (sweeps) start and
%       stop
%   -> adjustToZero: 1 to adjust each sweep to start at zero
%   varargin
%   ->  'repeat_time_duration': time duration for each repeat (in seconds)
%
%
% Author: ijones

repTimeDurSec = [];
acqRate = 2e4;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'repeat_time_duration')
            repTimeDurSec = varargin{i+1};
        end
    end
end

startTimes = stimFramesTsStartStop(1:2:end);
if isempty(repTimeDurSec )
    endTimes = stimFramesTsStartStop(2:2:end);
else
    endTimes = startTimes+repTimeDurSec*acqRate;
end

if length(startTimes) ~= length(endTimes)
    fprintf('error with startstop times\n');
    spikeTrains = [];
    return;
end

for iRepeat = 1:length(startTimes)
    
    spikeTrains{iRepeat} = spikeTrainsConcatenated(find(and( ...
        spikeTrainsConcatenated>=startTimes(iRepeat), ...
        spikeTrainsConcatenated<=endTimes(iRepeat)) ...
        ));
    if adjustToZero
        spikeTrains{iRepeat} = spikeTrains{iRepeat}- startTimes(iRepeat);
    end
end


end