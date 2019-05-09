function [SponWfs, SponWfMean, SponWfMeanCtr SponWfCtr] = ...
    extract_footprint_from_spiketimes(spikeTimes, f,varargin) 
% [SponWfs, SponWfMean, SponWfMeanCtr SponWfCtr] =   ...
%   EXTRACT_FOOTPRINT_FROM_SPIKETIMES(spikeTimes, f) 

Fs = 2e4;

% init vars
preStimT = 10;
postStimT = 30;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'pre_stim')
            preStimT = varargin{i+1};
        elseif strcmp( varargin{i}, 'post_stim')
            postStimT = varargin{i+1};
        end
    end
end




SponWfs = mea1kadd.extract_epocs(f,spikeTimes, preStimT,postStimT);
SponWfMean = ( squeeze ( mean( SponWfs , 3 ) ) );
[SponWfMeanCtr offsetVals ] = mea1kadd.footprint_apply_offset(SponWfMean);

SponWfCtr = SponWfs - repmat(offsetVals,[size(SponWfs,1) ,1,size(SponWfs,3)]);


end
