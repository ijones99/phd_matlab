function paramOut = bias_index2(ONcntStAvg,OFFcntStAvg)
% paramOut = RESPONSE_PARAMS_CALC.BIAS_INDEX2(ONcntStAvg,OFFcntStAvg, timeMetric)
%
% Purpose: compute "bias index." 
%
% Arguments: 
%   timeStampsONPrefSz: cell with spike times in seconds for each stimulus repeat (ON stim)
%   timeStampsOFFPrefSz: cell with spike times in seconds for each stimulus repeat (OFF stim)
%   timeMetric: 'sec' or 'samples'
%
% BI = (ON-OFF)/(ON+OFF). Sum of spikes during first 400 msec
%
%  The first parameter estimated whether the cell responded best to 
% increments or decrements in light intensity or both. This parameter was 
% calculated from the cells' responses to a flashed spot in the area-response
% protocol. For each cell, the spot size was selected that gave the largest 
% response. The Bias Index was calculated by comparing the response to the
% spot of optimal size and sign of contrast (hence referred to as the preferred
% stimulus) with its response to a spot of the same size but for the nonpreferred
% sign of contrast. The sum of the spikes during the first 400 ms after 
% the presentation of the stimuli was compared such that: BI = (ON-OFF)/(ON+OFF).
%
% This index ranges from +1 for ON cells through 0 for ON-OFF cells to −1 for OFF cells.
%
% (Karl Farrow et. al 2011, J Neurophysiology)

% time period over which to count


% calculate index: (ON-OFF)/(ON+OFF)
paramOut = (ONcntStAvg - OFFcntStAvg)/(ONcntStAvg + OFFcntStAvg);


end
