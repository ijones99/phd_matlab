function paramOut_Latency_sec = latency2(firingRateMean, edges)
% paramOut_Latency = RESPONSE_PARAMS_CALC.LATENCY2(firingRateMean, integWinTime_sec)
%
% purpose: Calculate "Response Latency:" 
% Response Latency (Latency).
%
% Arguments:
%   firingRateMean = [avgFiringRate_sec ]
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


[Y,idxMaxFR] = max(firingRateMean);

% zero point in edges
zeroIdx = find(edges==0);
if isempty(zeroIdx)
    zeroIdx = 1;
end

integWinTime_sec = diff(edges(end-1:end))/2e4
% time to max firing rate
paramOut_Latency_sec = (idxMaxFR(1)-zeroIdx-1 ) *integWinTime_sec;

end