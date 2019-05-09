function [els x y idx ] = select_els_in_mea_region(xMin,xMax,yMin,yMax)
% [els x y idx ] = SELECT_ELS_IN_MEA_REGION(xMin,yMax,yMin,yMax)

allEls = [0:26399];
[allX allY]= mea1kadd.el2xy_v2(allEls);

idxRestrictX = intersect(find(allX>=xMin),find(allX<=xMax));
idxRestrictY = intersect(find(allY>=yMin),find(allY<=yMax));
idx = intersect(idxRestrictX,idxRestrictY);

els = allEls(idx);
x = allX(idx);
y = allY(idx);



end
