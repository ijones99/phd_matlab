function [data] = extract_waveforms_from_ntk2(ntk2, spikeTimesSec )
% extract_waveforms_from_ntk2(ntk2, spikeTimes )
%     waveforms: [4834x30x6 single]
%     spiketimes: [1x4834 single]

acqRate = 20000;
spikeTimesRaw = round(spikeTimesSec*acqRate);
% window around which to cut waveforms
preSpikeTime = 14;
postSpikeTime = 15;

spikeWinLength = preSpikeTime+postSpikeTime+1;
numChannels = size(ntk2.sig,2);

% correct matrix orientation for timestamps
if size(spikeTimesRaw,2)>size(spikeTimesRaw,1)
    spikeTimesRaw= spikeTimesRaw';
end

% limit data length so as not to overrun available data
maxDataLengthAllowed = length(ntk2.sig)-spikeWinLength;
spikeTimesRaw(find(spikeTimesRaw>maxDataLengthAllowed)) = [];

minDataLengthAllowed = spikeWinLength;
spikeTimesRaw(find(spikeTimesRaw<=minDataLengthAllowed)) = [];

% create indices to cut out waveforms from raw data
timeStampRep = sort(repmat(spikeTimesRaw, spikeWinLength ,1));
periWindowIndsOverlay = -preSpikeTime:postSpikeTime;periWindowIndsOverlay = periWindowIndsOverlay';
windowOverlayInds = repmat(periWindowIndsOverlay,length(spikeTimesRaw),1);

try
    waveformInds = timeStampRep+windowOverlayInds;
    
    
    % waveformIndsAllChs = repmat(waveformInds, 1,numChannels);
    waveformData = ntk2.sig(waveformInds,:);
    waveformData = reshape(waveformData,[spikeWinLength,length(spikeTimesRaw),numChannels]);
    data.waveform  = permute(waveformData ,[2 3 1]);
    data.el_idx = ntk2.el_idx;
    data.channel_nr = ntk2.channel_nr;
    data.averaged = mean(data.waveform,1);
    data.x = ntk2.x;
    data.y = ntk2.y;
    data.el_idx = ntk2.el_idx;
    data.averaged = permute(data.averaged, [2 3 1]);
    
catch
    data = [];
    fprintf('error extracting waveforms\n');
    
end
end