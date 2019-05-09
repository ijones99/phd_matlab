function [footprint amtShift] = center_footprints(footprint)

numEls = 7;
indsMaxAmp = ifunc.footprints.get_max_amp_footprint(footprint, numEls);
amtShift = zeros(1,size(footprint,3));
% footprint 30x118x86
for i=1:size(footprint,3) % cycle through all of the footprint
    selSpikeAmps = footprint(:,indsMaxAmp,i);
    
    [junk, footprintAmpIdx] = min(selSpikeAmps,[], 1);
    meanLocMinSpikeAmp = round(mean(footprintAmpIdx));
    
    waveformMidPt = round(size(footprint,1)/2);
    amtShift(i) = waveformMidPt - meanLocMinSpikeAmp;
    %      fprintf('shift %d.\n',amtShift(i)     )
    if amtShift(i) >= abs(waveformMidPt)
        fprintf('Warning: cannot shift\n')
    end
    
    footprint(:,:,i) = circshift(footprint(:,:,i), [amtShift(i) 0 0 ]);
    
    if amtShift(i) < 0
        footprint(end+amtShift(i):end,:,i) = NaN;
    elseif amtShift(i) > 0
        footprint(1:amtShift(i),:,i) = NaN;
    end
end

end