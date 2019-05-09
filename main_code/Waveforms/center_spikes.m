function spikes = center_spikes(spikes)

numEls = 7;
indsMaxAmp = get_max_amp_spikes(spikes, numEls);

% spikes 30x118x86
for i=1:size(spikes,3) % cycle through all of the spikes
    selSpikeAmps = spikes(:,indsMaxAmp,i);
    
    [junk, spikesAmpIdx] = min(selSpikeAmps,[], 1);
    meanLocMinSpikeAmp = round(mean(spikesAmpIdx));
    
    waveformMidPt = round(size(spikes,1)/2);
    amtShift = waveformMidPt - meanLocMinSpikeAmp;
          
    if amtShift >= abs(waveformMidPt)   
        fprintf('Warning: cannot shift\n')
    end
   
    spikes(:,:,i) = circshift(spikes(:,:,i), [amtShift 0 0 ]);
    
    if amtShift < 0
        spikes(end+amtShift:end,:,i) = NaN;
    elseif amtShift > 0
        spikes(1:amtShift,:,i) = NaN;
    end
end

end