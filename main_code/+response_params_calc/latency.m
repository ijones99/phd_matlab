function paramOut_Latency_sec = latency(firingRateMean, edges, preferredIdx, integWinTime_sec)
% paramOut_Latency = RESPONSE_PARAMS_CALC.LATENCY(firingRateMean, preferredIdx, integWinTime_sec)
%
% purpose: Calculate "Response Latency:" 
% Response Latency (Latency).
%
% Arguments:
%   firingRateMean = [spotSize x avgFiringRate_sec x stimIntensity(ON or OFF)]
%   preferredIdx = [spotSize, stimIntensity(ON or OFF)];
%   integWinTime_sec = time interval over which avg is computed
%
% out: (in seconds)
%
% The latency of each cell was estimated by measuring the time to the peak of...
% its response during the presentation of its preferred stimulus, i.e., the spot 
% size that produced the most spikes, during the increasing-spot-stimulus paradigm. 
% The response was measured as the mean firing rate measured over an integration 
% window of 25 ms. (Farrow et. al. 2011, J Neurophysiology)
%
% 

firingRateMeanSel = firingRateMean(preferredIdx(1),:, preferredIdx(2));
[Y,idxMaxFR] = max(firingRateMeanSel);

% zero point in edges
zeroIdx = find(edges==0);
if isempty(zeroIdx)
    zeroIdx = 1;
end

% time to max firing rate
paramOut_Latency_sec = (idxMaxFR(1)-zeroIdx-1 ) *integWinTime_sec;

end