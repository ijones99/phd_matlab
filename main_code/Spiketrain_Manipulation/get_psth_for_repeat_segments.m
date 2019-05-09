function meanPsthSmoothed = get_psth_for_repeat_segments(segments, selSegmentInds,startTime, stopTime, binWidth)

sigma = 0.025;

numBins = (stopTime-startTime)/binWidth+1;

psthSegment = zeros(length(selSegmentInds), numBins)

for i=1:length(selSegmentInds)
    [psthSegment(i,:) edges ] = ...
        get_psth_2(segments{selSegmentInds(i)}, startTime, stopTime, binWidth)
end

meanPsth = mean(psthSegment,1);

meanPsthSmoothed = conv_gaussian_with_spike_train(meanPsth, sigma, binWidth);


end