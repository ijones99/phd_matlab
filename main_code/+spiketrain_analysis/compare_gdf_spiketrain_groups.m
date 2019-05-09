function [comparisonMat clusNos1 clusNos2 ] = compare_gdf_spiketrain_groups(gdf1, gdf2, spikePrecisionPlusMinus)

% get cells
clusNos1 = unique(gdf1(:,1));
st1Cell = {};
for i=1:length(clusNos1)
    I = find(gdf1(:,1)==clusNos1(i));
    st1Cell{i} = gdf1(I,2);
end

clusNos2 = unique(gdf2(:,1));
st2Cell = {};
for i=1:length(clusNos2)
    I = find(gdf2(:,1)==clusNos2(i));
    st2Cell{i} = gdf2(I,2);
end


comparisonMat = zeros(length(st1Cell),length(st2Cell));


for i=1:length(st1Cell)
    
    for j=1:length(st2Cell)
        
        st1 = st1Cell{i}; 
        st2 = st2Cell{j}; 
        
        [numMatchingSpikes matchingIdx] = ...
            spiketrain_analysis.compare_spiketrains(st1, st2, ...
            spikePrecisionPlusMinus);
        
        comparisonMat(i,j) = numMatchingSpikes/max(length(st1),length(st2));
        
        
    end
end

end