function paramOut_transience = transience(firingRateMean, preferredIdx, integWinTime_sec)
%
% paramOut_transience = RESPONSE_PARAMS_CALC.TRANSIENCE(firingRateMean, ...
% preferredIdx, integWinTime_sec)
%
% Purpose: Calculate Transience Index (Transience).
%
% Arguments:
%   firingRateMean = [spotSize x avgFiringRate_sec x stimIntensity(ON or OFF)]
%   preferredIdx = [spotSize, stimIntensity(ON or OFF)];
%   integWinTime_sec = time interavl over which avg is computed
%
% We compared the response duration of each cell by measuring the area under 
% its normalized 1.5-s long poststimulus time histogram (PSTH) to its preferred 
% stimulus. The PSTH was normalized so that its peak response was 1. The 
% area under the curve thus varied depending on the duration of the 
% response of the cell (Fig. 2C). We report the index in seconds where 1 
% represents summed activity under curves equivalent to maximum firing rate 
% for 1 of the 1.5-s PSTH duration.  (Farrow et. al. 2011, J Neurophysiology)

PoststimTimeDur_sec = 1.5;

% selected mean firing rate
firingRateMeanSel = firingRateMean(preferredIdx(1),:, preferredIdx(2));

% time axis in seconds
axisTime = [integWinTime_sec:integWinTime_sec:PoststimTimeDur_sec];

% mean firing rate over duration
firingRateMeanPoststimulus = firingRateMeanSel(1:length(axisTime));

% normalize
firingRateNorm = firingRateMeanPoststimulus/max(firingRateMeanPoststimulus);

% area under curve
paramOut_transience = trapz(axisTime,firingRateNorm);

end






