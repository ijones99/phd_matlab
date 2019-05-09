function [yIntercept lineSlope ] = line_formula( line1 )
% [yIntercept lineSlope ] = LINE_FORMULA( line1 )
% line1 = [x1 y1]
%         [x2 y2]

lineSlope = geometry.lineslope(line1);
% y = mx + b; b = y-mx
yIntercept  = line1(1,2)-lineSlope*line1(1,1);


end