function bar_offset_from_rf(angleDegIn, xyLoc)


distIn = 100;



[xyOut] = geometry.angle2xy(angleDegIn, distIn)

for i=1:length(angleDegIn)
    
    d(i) = geometry.distance_point_to_line(xyLoc, [0 0],xyOut(i,:));




end