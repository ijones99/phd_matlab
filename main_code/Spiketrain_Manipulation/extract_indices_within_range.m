function timestampInds = extract_indices_within_range(allSpikeTimes, minTime, maxTime)
% timestampInds = EXTRACT_INDICES_WITHIN_RANGE(allSpikeTimes, minTime, maxTime)

timestampInds = find(and(allSpikeTimes>minTime,allSpikeTimes<=maxTime));




end