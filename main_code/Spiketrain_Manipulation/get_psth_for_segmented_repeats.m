function  psthData = get_psth_for_segmented_repeats(segmentTs,stimStartTs, ...
    stimEndTs, doConvolve)


if nargin < 4
    doConvolve = 0;
end


plotStartTimeZ = stimStartTs;
plotEndTimeZ = stimEndTs;
binSize = 0.025;
sigma = 0.025;

for iSegment = 1:length(segmentTs)
    psthData( iSegment,:) = get_psth_3(segmentTs{iSegment},binSize,stimEndTs-stimStartTs);
    if doConvolve
        psthData( iSegment,:)  = conv_gaussian_with_spike_train(psthData( ...
            iSegment,:), sigma, binSize);
    end
end





        
end