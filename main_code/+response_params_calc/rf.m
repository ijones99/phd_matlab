function paramOut_rf = rf(spotDiamMM, meanSpikeCountPerSpotDiam)
%
% paramOut_rf = RESPONSE_PARAMS_CALC.RF(spotDiamMM, meanSpikeCountPerSpotDiam)
%
% Purpose: Calculate Receptive Field Index (RF Index).
%
% Arguments: 
%   spotDiamMM = spot sizes for stimulus
%   meanSpikeCountPerSpotDiam = spike count per spot size
%
% This index is an estimate of a cell's preference for stimuli that are larger
% and/or smaller than its optimal spot stimulus. It was calculated as the area 
% under the normalized, size-response curve (Fig. 2B). The size-response curve 
% represents the total number of spikes produced during the presentation of 
% spots of different diameters. After the peak was normalized to 1, the area 
% under the curve can then be calculated. The index is reported as a fraction
% of the total possible area under the curve. A value of 1 would mean the cell
% responded with its maximum response at each stimulus size. Smaller values 
% indicate a reduction in the cell's response when presented stimuli larger
% and/or smaller than the optimum.

% normalize spike counts
spikeCntCurve_norm = meanSpikeCountPerSpotDiam/max(meanSpikeCountPerSpotDiam);

% calc total possible AUC
totalPossibleAUC = trapz(spotDiamMM, ones(1,length(spikeCntCurve_norm)));

% AUC for response
AUC = trapz(spotDiamMM, spikeCntCurve_norm);

% AUC of responses over total possible AUC
paramOut_rf = AUC/totalPossibleAUC;