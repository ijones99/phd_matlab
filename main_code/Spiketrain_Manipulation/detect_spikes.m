function [pks locs amps] = detect_spikes(spiketrain, varargin)
% function [pks locs amps] = detect_spikes(spiketrain, varargin)
% ----- Settings -----
% minSpikeSeparation = 12; % samples
% threshFactor = 3; % threshold (times the standard deviation)
% spikeDuration = 15; % samples
% baselineDuration = 30; % samples before stimulus to use as a baselin

% ----- Settings -----
minSpikeSeparation = 12; % samples
threshFactor = 3; % threshold (times the standard deviation)
spikeDuration = 15; % samples
baselineDuration = 30; % samples before stimulus to use as a baseline


%% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'minpeakseparation')
            minSpikeSeparation = varargin{i+1};
        elseif strcmp( varargin{i}, 'threshold_factor')
            threshFactor = varargin{i+1};
        elseif strcmp( varargin{i}, 'baseline_duration')
            baselineDuration = varargin{i+1};
        end
    end
end
%% main calculation
stdSpiketrain = std(spiketrain(1:baselineDuration));

data = diff(spiketrain); % get derivative of data; move one to right to account 
% for differential operation where 1 value is lost
absData = abs(data); % get abs value of data

% get peaks
[pksDiff,locsDiff] = findpeaks(absData,'threshold',stdData*threshFactor,...
    'minpeakdistance',minSpikeSeparation )

% get indices for part of data of interest
locsDiffMat = repmat(locsDiff',spikeDuration,1); 
localIndRangeNeg = -round(spikeDuration/2); % min distance from spike
localIndRangePos = spikeDuration + localIndRangeNeg -1; %max distance from spike
localRange = [localIndRangeNeg:localIndRangePos]+1;
localRangeMat = repmat(localRange',1,length(locsDiff));
indsOfInterest = localRangeMat+locsDiffMat; % add together the data and range
indsOfInterestVector = sort(reshape(indsOfInterest,...
    1,size(indsOfInterest,1)*size(indsOfInterest,2)));

% get offset data
baselineValues = spiketrain(indsOfInterest(end,:)); % baseline for each segment

baselineValueMatrix = repmat(baselineValues',spikeDuration,1);
baselineValueVector = reshape(baselineValueMatrix,1,size(baselineValueMatrix,1)*size(baselineValueMatrix,2));


% cut out irrelevant parts
selData = zeros(size(spiketrain,2), size(spiketrain,1));
selData(indsOfInterestVector) = spiketrain(indsOfInterestVector)'-baselineValueVector;

% take abs value
selDataAbs = abs(selData);

% find equal values along data
sameValueNeighboringInds = indsOfInterestVector(find(diff(selDataAbs(indsOfInterestVector))==0)+1);
selDataAbsMod = selDataAbs;
selDataAbsMod(sameValueNeighboringInds) = selDataAbs(sameValueNeighboringInds)-threshFactor*stdSpiketrain-1;
%% find peaks
close all
[pks,locs] = findpeaks(selDataAbsMod,'threshold',stdSpiketrain,...
    'minpeakdistance',minSpikeSeparation )

amps = selDataAbsMod(locs);

end