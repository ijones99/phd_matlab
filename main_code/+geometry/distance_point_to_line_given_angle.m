function d = line_dist_pt_to_line_given_angle(angleDegIn, xyLoc)
% d = LINE_DIST_PT_TO_LINE_GIVEN_ANGLE(angleDegIn, xyLoc)


distIn = 100;



[xyOut] = geometry.angle2xy(angleDegIn, distIn)

for i=1:length(angleDegIn)
    
    d(i) = geometry.distance_point_to_line(xyLoc, [0 0],xyOut(i,:));




end