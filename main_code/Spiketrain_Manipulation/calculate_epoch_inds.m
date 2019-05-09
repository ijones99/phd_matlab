function epochInds = calculate_epoch_inds(timePointsSamples, preTimeMsec, postTimeMsec)
% epochInds = CALCULATE_EPOCH_INDS(data, timePointsSamples, preTimeMsec, postTimeMsec)
%   CALCULATE_EPOCH_INDS calculates the epoch indices for given timepoints.
%   These indices can be used to access data.
% 
% author ijones

recRate = 2e4;
% convert
preTime = (preTimeMsec*recRate)/1000;
postTime = (postTimeMsec*recRate)/1000;

% initialize output
epochData = zeros(length(timePointsSamples), preTime+postTime+1);

% create matrix of timePointsSamples
if isrow(timePointsSamples)
    timePointsSamples = timePointsSamples';
end
timePointsSamplesDup = repmat(timePointsSamples,1,size(epochData,2));
t = -preTime:postTime;
incrementTimes = repmat(t,size(epochData,1),1);

epochInds = timePointsSamplesDup+incrementTimes;

end
