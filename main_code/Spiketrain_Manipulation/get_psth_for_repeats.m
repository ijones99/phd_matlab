function [psthDataSmoothed psthDataMeanSmoothed ] = get_psth_for_repeats(repeats, repeatLengthSec, doSmooth)

%
% author: ijones

if nargin < 3
    doSmooth = 0;
end

%% settings
acqRate = 20000; % samples per second
sigmaVal = 0.025; %msec
binSize = 0.025;
%% compute psth
psthData = zeros(length(repeats), round(repeatLengthSec/binSize)+1);
for iRep = 1:length(repeats)
    psthData( iRep,:) = get_psth(repeats{iRep},0,repeatLengthSec, 0, ...
        repeatLengthSec, binSize);
   
end
psthDataSmoothed = zeros(1, length(psthData( 1,:))); % init matrix
for i=1:size(psthData,1) % smooth each binned dataset
   psthDataSmoothed(i,:)  = conv_gaussian_with_spike_train(psthData(i,:), ...
       sigmaVal, binSize);
end
% smooth the mean psth
[psthDataMeanSmoothed ] = mean(psthDataSmoothed,1);

end