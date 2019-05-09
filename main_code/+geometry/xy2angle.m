function angleout = xy2angle(x,y)
% angleout = XY2ANGLE(x,y)

angleout  = geometry.rad2deg(atan2(y,x));


end
