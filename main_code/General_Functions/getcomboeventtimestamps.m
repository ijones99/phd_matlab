
function [traceTimeStamps, eventTimeStamps] = getcomboeventtimestamps(inputSignal,preTime, postTime, acquisitionRate, thresholdMultiplier)
%   geteventtimestamps: input signal vector; output vector with timestamps
%   for all spike traces from all channels. These timestamps range from
%   -preTime to +postTime for each event (i.e. spike)

% function [traceTimeStamps, eventTimeStamps] = geteventtimestamps(ntk2,preTime (frames), postTime (frames), acquisitionRate, thresholdMultiplier)
% 
% author ijones
%




% init variable where ones denote timestamps where ntk2.sig exceeds
% threshold
combinedPointsExceedingThreshold = zeros(size(inputSignal,1),1);

%rms value of inputSignal
    for i = 1:size(inputSignal,2)
        signalRMS(i) = rms(inputSignal(:,i));
    end
    
    %calculate threshold value
    thresholdValue = -1*thresholdMultiplier*signalRMS;

    % collect exceeded threshold timestamps from each channel and combine them.
for o=1:size(inputSignal,2)
    
    
    %get timestamps where inputSignal exceeds threshold
    pointsExceedingThreshold = inputSignal(:,o) < thresholdValue(o);
    combinedPointsExceedingThreshold = (combinedPointsExceedingThreshold + pointsExceedingThreshold);
    
end

% if there are overlaps, reduce all positive values to 1
combinedPointsExceedingThreshold(combinedPointsExceedingThreshold>1) = 1;

%timepoints where threshold is crossed
spikeTimes = zeros(1,size(combinedPointsExceedingThreshold,1));
spikeTimes(2:end) = combinedPointsExceedingThreshold(2:end)-combinedPointsExceedingThreshold(1:end-1);

%remove negative ones
spikeTimes(spikeTimes<0)=0;

%remove spikes at begining and end
spikeTimes(1:preTime) = 0;
spikeTimes(end-postTime:end) = 0;


%get indices for spike times
eventTimeStamps = find(spikeTimes==1);
numberOfSpikes = size(eventTimeStamps,2);



% row for number of threshold crossings, and columns corresponding to the
% mask that will be applied to the inputSignal
spikeWindow = -preTime:postTime;
spikeWindow = repmat(spikeWindow,numberOfSpikes,1);

% make a matrix of the spikes times: col for times, rows of equal values
matrixOfSpikeTimes = repmat(eventTimeStamps',1,size(spikeWindow,2));

% each row has the timestamps for one spike
traceTimeStamps = matrixOfSpikeTimes + spikeWindow;

%reshape the mask into a 1-dimensional vector
traceTimeStamps = reshape(traceTimeStamps,1,size(traceTimeStamps,1)*size(traceTimeStamps,2));

% trim the ends of the indices (no negatives, or values that exceed matrix
% size)
traceTimeStamps(traceTimeStamps>size(inputSignal,1) ) = [];
traceTimeStamps(traceTimeStamps<1 ) = [];

%sort the reshaped vector and remove duplicate values
traceTimeStamps = unique(traceTimeStamps);

end
