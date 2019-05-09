function [onOff,stimIdx, spikeCountsMean] = find_preferred_stim(spikeTimes, stimFrameInfo, timeDur)
% FIND_PREFERRED_STIM(spikeTimes, stimFrameInfo, timeDur)
%
% Purpose: Find optimal spot size and brightness for spot stimuli.
% The mean number of spikes counted during the first 400 msec following the 
% the presentation of each spot is found. 
%
% Arguments
%   spikeTimes: cells containing responses to dot sizes
%   stimFrameInfo = 
%        rep: [1x60 double]
%        rgb: [1x60 uint8]
%    dotDiam: [1x60 double]
%
% select preferred stimulus
% row: 1 = ON; 2 = OFF

if nargin < 3
    timeDur = 0.400;
end

% count ON/OFF cells during first 400msec
% ON
spikeCounts = response_params_calc.general.count_spikes(...
    spikeTimes, 'seconds', timeDur);
onIdx = find(stimFrameInfo.rgb>0);
offIdx = find(stimFrameInfo.rgb==0);
spikeCountsON = spikeCounts(onIdx);
spikeCountsOFF = spikeCounts(offIdx);

% obtain average spike counts for pref. stim. and also for that of pref
% stim. size but opposite intensity values
% row: 1 = ON; 2 = OFF

spikeCountsMean= [];
[spikeCountsMean uniqueStimIdx]  = response_params_calc.general.mean_spike_count(...
    spikeCountsON, stimFrameInfo.dotDiam(onIdx));

[spikeCountsMean(2,:) uniqueStimIdx]  = response_params_calc.general.mean_spike_count(...
    spikeCountsOFF, stimFrameInfo.dotDiam(offIdx));

% select preferred stimulus
% row: 1 = ON; 2 = OFF
% stimIdx = index for stim
[onOff,stimIdx,vals] = find(spikeCountsMean==max(max(spikeCountsMean)));
if length(unique(onOff))>1
    warning('Max. found for both on and OFF');
    onOff = NaN;stimIdx = NaN; vals = NaN;
end
end