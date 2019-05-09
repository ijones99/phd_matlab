function [firingRate edges]= est_firing_rate_from_psth(spikeTimesRep,startStopTime, varargin)

acqRate= 2e4;
P.sigma = 0.025; % sigma for smoothing
P.bin_width = 0.04; % bin width
P = mysort.util.parseInputs(P, varargin, 'error');
P.sigma  = P.sigma*acqRate;
P.bin_width  = P.bin_width*acqRate;

psthSegment = {};
sumPsth = {};
for i=1:length(spikeTimesRep)
    currSpikeTimesRep = spikeTimesRep{i};
    if iscolumn(currSpikeTimesRep)
        currSpikeTimesRep = currSpikeTimesRep';
    end
    [psthSegment{i} edges ] = get_psth_2(currSpikeTimesRep, startStopTime(1), startStopTime(2),...
        P.bin_width);
    if i==1
        sumPsth = psthSegment{i}    ;
    else
        sumPsth = sumPsth+psthSegment{i};
    end
end

% Reference: (book) Analysis of Parallel Spike ...
% Trains Series: Springer Series in Computational 
% Neuroscience, Vol. 7 Grün, Sonja; Rotter, Stefan 
% (Eds.): Chapter Chapter 2 Estimating the Firing 
% Rate - Shigeru Shinomoto

% firingRate = conv_gaussian_with_spike_train(sumPsth, P.sigma, P.bin_width);
numRepeats = length(spikeTimesRep);
% firingRate  = acqRate*firingRate/(P.bin_width*numRepeats);
firingRate = ifunc.analysis.firing_rate.psth2firingrate(sumPsth,numRepeats,P.bin_width/acqRate);
end