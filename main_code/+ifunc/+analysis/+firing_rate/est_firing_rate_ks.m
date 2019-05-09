function [firingRate edges]= est_firing_rate_ks(spikeTimesRep,startStopTime, varargin)
% [firingRate edges]= EST_FIRING_RATE_KS(spikeTimesRep,startStopTime, varargin)
%
% arguments:
%   spikeTimesRep: a cell of repetitions (or a single vector is also valid)
%   startStopTime: [0 to stim end time]

acqRate= 2e4;
P.sigma = 0.025*acqRate; % sigma for smoothing
P.bin_width = 0.025*acqRate; % bin width
P.inputScale = 'samples'; % or 'seconds'
scaleData = 1;
shiftData = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'sigma')
            P.sigma = varargin{i+1};
        elseif strcmp( varargin{i}, 'bin_width')
            P.bin_width = varargin{i+1};
        elseif strcmp( varargin{i}, 'inputScale')
            P.inputScale = varargin{i+1};
        elseif strcmp( varargin{i}, 'scale_data')
            scaleData  = varargin{i+1};
        elseif strcmp( varargin{i}, 'shift_data')
            shiftData   = varargin{i+1};
        end
    end
end

if not(iscell(spikeTimesRep))
    spikeTimesRepNew{1} = spikeTimesRep;
    clear spikeTimesRep ;
    spikeTimesRep = spikeTimesRepNew;
    clear spikeTimesRepNew;
end

psthSegment = {};
sumPsth = {};
for i=1:length(spikeTimesRep)
    [psthSegment{i} edges ] = get_psth_2(spikeTimesRep{i}*scaleData+shiftData , startStopTime(1), startStopTime(2),...
 P.bin_width);
if i==1
    sumPsth = psthSegment{i}    ;
    
else
    if isempty(sumPsth)
        % in case sum is empty
        sumPsth = zeros(1,length(edges));
    end
    if isempty(psthSegment{i})
        % in case sum is empty
        psthSegment{i} = zeros(1,length(edges));
    end
    sumPsth = sumPsth+psthSegment{i};
end
end

if strcmp(P.inputScale, 'samples')
    sigma =  P.sigma/acqRate;
    binWidth =  P.bin_width/acqRate;
else
    sigma =  P.sigma;
    binWidth =  P.bin_width;
    
end
    
% Reference: (book) Analysis of Parallel Spike ...
% Trains Series: Springer Series in Computational 
% Neuroscience, Vol. 7 Grün, Sonja; Rotter, Stefan 
% (Eds.): Chapter Chapter 2 Estimating the Firing 
% Rate - Shigeru Shinomoto

firingRate = conv_gaussian_with_spike_train(sumPsth, sigma, binWidth);

numRepeats = length(spikeTimesRep);

firingRate  = firingRate/(numRepeats);



end