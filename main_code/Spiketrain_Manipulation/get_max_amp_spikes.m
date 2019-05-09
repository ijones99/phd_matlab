function indsMaxAmp = get_max_amp_spikes(spikes, numEls)

    spikesMean = mean(spikes,3);
    spikesAmp = max(spikesMean,[], 1) - min(spikesMean,[], 1);
    [Y,I] = sort(spikesAmp,'descend');
    indsMaxAmp = I(1:numEls);
    
    
end