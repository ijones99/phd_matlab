function comparisonMat = compare_all_spiketrains(spikeTrainsCell,spikePrecisionPlusMinus)

comparisonMat = zeros(length(spikeTrainsCell));

selPairs = nchoosek(1:length(spikeTrainsCell),2);

for i=1:length(selPairs)
    st1 = spikeTrainsCell{selPairs(i,1)};
    st2 = spikeTrainsCell{selPairs(i,2)};
    
    [numMatchingSpikes matchingIdx] = ...
     spiketrain_analysis.compare_spiketrains(st1, st2, ...
     spikePrecisionPlusMinus);
 
    comparisonMat(selPairs(i,1),selPairs(i,2)) = numMatchingSpikes/max(length(st1),length(st2));

 
end





end