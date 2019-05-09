function [waveformData] = extract_waveforms_from_ntk2(ntk2, spikeTimes )
% extract_waveforms_from_ntk2(ntk2, spikeTimes )
%     waveforms: [4834x30x6 single]
%     spiketimes: [1x4834 single]

preSpikeTime = 14;
postSpikeTime = 15;
acqRate = 2e4;
spikeWinLength = preSpikeTime+postSpikeTime+1;
numChannels = size(ntk2.sig,2);

% correct orientation for timestamps
if size(spikeTimes,2)>size(spikeTimes,1)
    spikeTimes= spikeTimes';
end

maxDataLengthAllowed = length(ntk2.sig)-spikeWinLength;
spikeTimes(find(spikeTimes>maxDataLengthAllowed)) = [];

timeStampRep = sort(repmat(spikeTimes, spikeWinLength ,1));
periWindowIndsOverlay = -preSpikeTime:postSpikeTime;periWindowIndsOverlay = periWindowIndsOverlay';
windowOverlayInds = repmat(periWindowIndsOverlay,length(spikeTimes),1);
waveformInds = timeStampRep+windowOverlayInds;
% waveformIndsAllChs = repmat(waveformInds, 1,numChannels);
waveformInds = round(waveformInds);
if max(waveformInds > size(ntk2.sig,1))
    waveformInds(find(waveformInds>size(ntk2.sig,1))) = [];
    fprintf('Warning: concatenating spike times.\n');
end
waveformData = ntk2.sig(waveformInds,:);
waveformData = reshape(waveformData,[spikeWinLength,length(spikeTimes),numChannels]);
waveformData  = permute(waveformData ,[2 1 3]);

end