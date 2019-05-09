function [data] = extract_waveforms_from_h5(h5Data, spikeTimesSamples, varargin )
% extract_waveforms_from_h5Data(h5Data, spikeTimes )
%     waveforms: [4834x30x6 single]
%     spiketimes: [1x4834 single]
% varargin
%   pre_spike_time in samples
%   post_spike_time in samples

if iscell(h5Data)
    h5DataExpand = h5Data{1};
    clear h5Data;
    h5Data = h5DataExpand ;
    clear h5DataExpand;
end

spikeTimesSamples = round(spikeTimesSamples);

% window around which to cut waveforms
preSpikeTime = 60;
postSpikeTime = 60;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'pre_spike_time')
            preSpikeTime = varargin{i+1};
        elseif strcmp( varargin{i}, 'post_spike_time')
            postSpikeTime = varargin{i+1};
        end
    end
end

spikeWinLength = preSpikeTime+postSpikeTime+1;
channelNumbers = h5Data.getChannelNr;
numChannels = length(channelNumbers);

% correct matrix orientation for timestamps
if size(spikeTimesSamples,2)>size(spikeTimesSamples,1)
    spikeTimesSamples= spikeTimesSamples';
end

% limit data length so as not to overrun available data
% maxDataLengthAllowed = length(h5Data.getData)-spikeWinLength;
% spikeTimesSamples(find(spikeTimesSamples>maxDataLengthAllowed)) = [];
%
% minDataLengthAllowed = spikeWinLength;
% spikeTimesSamples(find(spikeTimesSamples<=minDataLengthAllowed)) = [];

% create indices to cut out waveforms from raw data
timeStampRep = sort(repmat(spikeTimesSamples, spikeWinLength ,1));
periWindowIndsOverlay = -preSpikeTime:postSpikeTime;periWindowIndsOverlay = periWindowIndsOverlay';
windowOverlayInds = repmat(periWindowIndsOverlay,length(spikeTimesSamples),1);


waveformInds = timeStampRep+windowOverlayInds;

% waveformIndsAllChs = repmat(waveformInds, 1,numChannels);
waveformData = h5Data.getData(round(waveformInds),:);
waveformData = reshape(waveformData,[spikeWinLength,length(spikeTimesSamples),numChannels]);
data.waveform  = permute(waveformData ,[2 3 1]);
data.el_idx = h5Data.MultiElectrode.electrodeNumbers;
data.channel_nr = channelNumbers;
data.average = mean(data.waveform,1);
data.average = permute(data.average, [2 3 1]);

data.median = median(data.waveform,1);
data.median = permute(data.median, [2 3 1]);
electrodePositions = h5Data.MultiElectrode.electrodePositions;
data.x = electrodePositions(:,1);
data.y = electrodePositions(:,2);
    
    
end
