function distToEl = get_distance_from_electrodes(xPt,yPt,elNos)
% distToEl = GET_DISTANCE_FROM_ELECTRODES(xPt,yPt,elNos)

[elLocs.x elLocs.y] = el2position(elNos);

xPt = repmat(xPt,1,size(elLocs.x,2));
yPt = repmat(yPt,1,size(elLocs.y,2));

distToEl = sqrt((xPt-elLocs.x).^2+(yPt-elLocs.y).^2);



end

