function ts = get_spiketimes_from_meadata(spikes, meaData, dataChunkParts)
% function ts = get_spiketimes_from_meadata(spikes, ...
% meaData, spikeTimes, dataChunkParts)

spikeTimes = [spikes.assigns' round(2e4*spikes.spiketimes')];
ts = {};
for i=1:length(meaData)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), ...
        dataChunkParts(i), ...
        dataChunkParts(i+1));
    ts{i} = spikeTimes(selSpikeTimeInds,:);
    ts{i}(:,2) = ts{i}(:,2)-dataChunkParts(i);
end

end