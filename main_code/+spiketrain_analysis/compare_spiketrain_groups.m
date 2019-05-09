function comparisonMat = compare_spiketrain_groups(st1Cell, st2Cell, spikePrecisionPlusMinus)

comparisonMat = zeros(length(st1Cell),length(st2Cell));


for i=1:length(st1Cell)
    
    for j=1:length(st2Cell)
        
        st1 = st1Cell{i}; 
        st2 = st2Cell{j}; 
        
        [numMatchingSpikes matchingIdx] = ...
            spiketrain_analysis.compare_spiketrains(st1, st2, ...
            spikePrecisionPlusMinus);
        
        comparisonMat(j,j) = numMatchingSpikes/max(length(st1),length(st2));
        
        
    end
end

end