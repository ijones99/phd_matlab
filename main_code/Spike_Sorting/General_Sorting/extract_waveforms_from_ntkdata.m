function [data] = extract_waveforms_from_ntkdata(ntkData, spikeTimesSec )
% extract_waveforms_from_ntk2(ntk2, spikeTimes )
%     waveforms: [repeats x number electrodes x number waveform samples (width) ] [4834x30x6 single]
%     spiketimes: [1x4834 single]

acqRate = 20000;
spikeTimesRaw = round(spikeTimesSec*acqRate);
% window around which to cut waveforms
preSpikeTime = 14;
postSpikeTime = 15;

spikeWinLength = preSpikeTime+postSpikeTime+1;
numChannels = size(ntkData.sig,2);

% correct matrix orientation for timestamps
if size(spikeTimesRaw,2)>size(spikeTimesRaw,1)
    spikeTimesRaw= spikeTimesRaw';
end

% limit data length so as not to overrun available data
maxDataLengthAllowed = length(ntkData.sig)-spikeWinLength;
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
    waveformData = ntkData.sig(waveformInds,:);
    waveformData = reshape(waveformData,[spikeWinLength,length(spikeTimesRaw),numChannels]);
    data.waveform  = permute(waveformData ,[2 3 1]);
    data.el_idx = ntkData.elNos;
    data.channel_nr = ntkData.chNos;
    data.averaged = mean(data.waveform,1);
    
    data.averaged = permute(data.averaged, [2 3 1]);
    
catch
    data = [];
    fprintf('error extracting waveforms\n');
    
end
end