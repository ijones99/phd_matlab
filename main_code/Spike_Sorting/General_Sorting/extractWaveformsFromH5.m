function [waveformData] = extractWaveformsFromH5(h5, spikeTimes )
% extract_waveforms_from_h5(h5, spikeTimes )
%     waveforms: [4834x30x6 single]
%     spiketimes: [1x4834 single]

preSpikeTime = 14;
postSpikeTime = 30;
acqRate = 2e4;
spikeWinLength = preSpikeTime+postSpikeTime+1;
numChannels = size(h5.getData,2);

% correct orientation for timestamps
if size(spikeTimes,2)>size(spikeTimes,1)
    spikeTimes= spikeTimes';
end

maxDataLengthAllowed = length(h5.getData)-spikeWinLength;
spikeTimes(find(spikeTimes>maxDataLengthAllowed)) = [];

timeStampRep = sort(repmat(spikeTimes, spikeWinLength ,1));
periWindowIndsOverlay = -preSpikeTime:postSpikeTime;periWindowIndsOverlay = periWindowIndsOverlay';
windowOverlayInds = repmat(periWindowIndsOverlay,length(spikeTimes),1);
waveformInds = timeStampRep+windowOverlayInds;
% waveformIndsAllChs = repmat(waveformInds, 1,numChannels);
waveformInds = round(waveformInds);
if max(waveformInds > size(h5.getData,1))
    waveformInds(find(waveformInds>size(h5.getData,1))) = [];
    fprintf('Warning: concatenating spike times.\n');
end
waveformData = h5.getData(waveformInds,:);
waveformData = reshape(waveformData,[spikeWinLength,length(spikeTimes),numChannels]);
waveformData  = permute(waveformData ,[2 1 3]);

end