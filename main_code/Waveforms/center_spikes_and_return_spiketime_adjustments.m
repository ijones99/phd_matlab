function outputAdjustments = center_spikes_and_return_spiketime_adjustments(spikes)

% Purpose: alignes spike waveforms and returns adjustments
% (in samples) that should be made to each spike time.


numEls = 7;
indsMaxAmp = get_max_amp_spikes(spikes, numEls);
outputAdjustments = zeros(1,size(spikes,3));
% spikes 30x118x86
for i=1:size(spikes,3) % cycle through all of the spikes
    selSpikeAmps = spikes(:,indsMaxAmp,i);
    
    [junk, spikesAmpIdx] = min(selSpikeAmps,[], 1);
    meanLocMinSpikeAmp = round(mean(spikesAmpIdx));
    
    waveformMidPt = round(size(spikes,1)/2);
    outputAdjustments(i) = -(waveformMidPt - meanLocMinSpikeAmp);
          
    if outputAdjustments(i) >= abs(waveformMidPt)   
        fprintf('Warning: cannot shift\n')
    end
   
    
end

end