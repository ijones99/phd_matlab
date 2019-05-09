function [distances  idxCombos ] = get_distance_between_points(coordVals)
% [distances  idxCombos ] = GET_DISTANCE_BETWEEN_POINTS(coordVals)
%
% coordVals: point values, coordVals.x, coordVals.y
%

idxCombos =  nchoosek(1:length(coordVals.x),2);


for i=1:size(idxCombos,1)
    distances(i) = sqrt((coordVals.x(idxCombos(i,1))-coordVals.x(idxCombos(i,2))).^2+...
        (coordVals.y(idxCombos(i,1))-coordVals.y(idxCombos(i,2))).^2);
end

distances = distances';
end

[distances  idxCombos ] = geometry.get_distance_between_points(rfCtrLoc);

rfProximityThreshUm = 10;
idxProxRfs = find(distances<rfProximityThreshUm );

for j = 1:size(idxCombos,1)
    
fprintf('%d) [%d %d] pairs %d and %d',j, rfCtrLoc.
end