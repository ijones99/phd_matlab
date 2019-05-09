binWidthMs = []; %msec bin width

[heatMap, neuronTs] = compare_ts(binWidthMs  );

% 
%%
% make row vector
heatMapOrig = heatMap;
heatMap = reshape(heatMap, size(heatMap,1)*size(heatMap,2),1);

% sort by matching vals
[heatMapValues indRankHeatMap] = sort(heatMap,'descend');

% create 2d matrices
heatMap = reshape(heatMap, size(heatMapOrig,1),size(heatMapOrig,2));
indRankHeatMap = reshape(indRankHeatMap, size(heatMapOrig,1),size(heatMapOrig,2));

rankData = struct('neurs', {}, 'matchVal', 0);
rankData = {};

for i=1: size(heatMapOrig,1)*size(heatMapOrig,2)
    [yNeur, xNeur] = find(indRankHeatMap == i);
    rankData{i}.neurs = {yNeur, xNeur};
    rankData{i}.matchVal = heatMapOrig(yNeur, xNeur);
    
end



