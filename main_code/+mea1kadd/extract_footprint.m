function [SponWfs, SponWfMean, SponWfMeanCtr spiketimes] =  extract_footprint(selClusNum, spikes, f, varargin) 
% [SponWfs, SponWfMean, SponWfMeanCtr spiketimes] =  EXTRACT_FOOTPRINT(selClusNum, spikes, f) 

Fs = 2e4;
preTs = 10;
postTs = 30;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'pre_ts')
            preTs = varargin{i+1};
        elseif strcmp( varargin{i}, 'post_ts')
            postTs = varargin{i+1};
        end
    end
end


spiketimesSec = spikes.spiketimes(find(spikes.assigns==selClusNum));
spiketimes = double(round(spiketimesSec*Fs));

lenSpiketimes = min(300, length(spiketimes));
SponWfs = mea1kadd.extract_epocs(f, spiketimes(1:lenSpiketimes), preTs,postTs);

SponWfMean = ( squeeze ( mean( SponWfs , 3 ) ) );
SponWfMeanCtr = mea1kadd.footprint_apply_offset(SponWfMean);


end
