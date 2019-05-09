function [onOff,stimIdx, spikeCountsMax] = spots_peak_firing_rate(R, clusNo, stimChangeTs, stimFrameInfo, timeDur)
% FIND_PREFERRED_STIM(spikeTimes, stimFrameInfo, timeDur)
%
% Purpose:
%
% Arguments
%   spikeTimes: cells containing responses to dot sizes
%   stimFrameInfo = 
%        rep: [1x60 double]
%        rgb: [1x60 uint8]
%    dotDiam: [1x60 double]
%
% select preferred stimulus

if nargin < 5
    timeDur = 0.400;
end

spikeTimes = spiketrains.extract_st_from_R(R,clusNo);

adjustToZero = 1;
spikeTimesCell = extract_spiketrain_repeats_to_cell(spikeTimes, ...
    stimChangeTs,adjustToZero);

% count ON/OFF cells during first 400msec
% ON
spikeCounts = response_params_calc.general.count_spikes(...
    spikeTimesCell, 'seconds', timeDur);
onIdx = find(stimFrameInfo.rgb>0);
offIdx = find(stimFrameInfo.rgb==0);
spikeCountsON = spikeCounts(onIdx);
spikeCountsOFF = spikeCounts(offIdx);

% obtain average spike counts for pref. stim. and also for that of pref
% stim. size but opposite intensity values
% row: 1 = ON; 2 = OFF

spikeCountsMax= [];
[spikeCountsMax uniqueStimIdx]  = response_params_calc.general.max_spike_count(...
    spikeCountsON, stimFrameInfo.dotDiam(onIdx));

[spikeCountsMax(2,:) uniqueStimIdx]  = response_params_calc.general.max_spike_count(...
    spikeCountsOFF, stimFrameInfo.dotDiam(offIdx));
