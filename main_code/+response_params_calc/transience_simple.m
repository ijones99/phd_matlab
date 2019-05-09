function paramOut_transience = transience_simple(firingRateMean, edges, timeDur_sec)
%
% paramOut_transience = RESPONSE_PARAMS_CALC.TRANSIENCE_SIMPLE(firingRateMean, ...
% edges, timeDur_sec)
%
% Purpose: Calculate Transience Index (Transience).
%
% Arguments:
%   firingRateMean = [spotSize x avgFiringRate_sec x stimIntensity(ON or OFF)]
%   edges: x axis values
%   timeDur_sec: length of time over which to calculate transience.
%
% We compared the response duration of each cell by measuring the area under 
% its normalized 1.5-s long poststimulus time histogram (PSTH) to its preferred 
% stimulus. The PSTH was normalized so that its peak response was 1. The 
% area under the curve thus varied depending on the duration of the 
% response of the cell (Fig. 2C). We report the index in seconds where 1 
% represents summed activity under curves equivalent to maximum firing rate 
% for 1 of the 1.5-s PSTH duration.  (Farrow et. al. 2011, J Neurophysiology)

acqRate = 2e4;

% zero point
idxStart = find(edges==0);
if isempty(idxStart)
    idxStart = 1;
end

% end point
idxStop = vectors.get_closest_value(timeDur_sec*2e4 , edges);

% time axis in seconds
axisTime = edges(idxStart:idxStop)/acqRate;

% mean firing rate over duration
firingRateMeanPoststimulus = firingRateMean(idxStart:idxStop);

% normalize
firingRateNorm = firingRateMeanPoststimulus/max(firingRateMeanPoststimulus);

% area under curve
paramOut_transience = trapz(axisTime,firingRateNorm);

end






