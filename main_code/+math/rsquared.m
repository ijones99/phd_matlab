function [rsq] = rsquared(x,y)
% [rsq] = RSQUARED(x,y)

[idxRem,cols,vals] = find(isnan([mats.set_orientation(x,'col') mats.set_orientation(y,'col')]));

x(idxRem) = [];
y(idxRem) = [];

p = polyfit(x,y,1);

yfit = polyval(p,x);

yresid = y - yfit;

SSresid = sum(yresid.^2);

SStotal = (length(y)-1) * var(y);

rsq = 1 - SSresid/SStotal;

end
