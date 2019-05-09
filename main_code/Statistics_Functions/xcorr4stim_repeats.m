function avgXCorr = xcorr4stim_repeats(psthDataSmoothed,doNormalize, lags)
% function avgXCorr = xcorr4stim_repeats(psthDataSmoothed,doNormalize, lags)
% calculates the correlation coefficient, as described in Meister 1996
% paper
%
% author: ijones

if nargin < 2
    doNormalize = 0;
    lags = 100;
elseif nargin < 3
    lags = 100;
end 

allPairs = combnk(1:size(psthDataSmoothed,1),2); % all combinations of pairs
dataLength = size(psthDataSmoothed,2); % length of the binned data

pairXCorr = zeros(length(allPairs),lags*2+1);

for iCC = 1:length(allPairs)
   
    pairXCorr(iCC,:) = xcorr(psthDataSmoothed(allPairs(iCC,1),:),  ...
        psthDataSmoothed(allPairs(iCC,2),:),lags);
    
end

avgXCorr = mean(pairXCorr,1);

if doNormalize
    avgXCorr = avgXCorr/max(avgXCorr); % normalize to one
end


end
