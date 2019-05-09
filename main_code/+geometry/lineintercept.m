function yIntercept = lineintercept( line1 )
% yIntercept = LINEINTERCEPT( line1 )

lineSlope = geometry.lineslope(line1);
yIntercept  = line1(2,1)-lineSlope*line1(1,1);


end