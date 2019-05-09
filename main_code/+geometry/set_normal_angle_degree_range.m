function angleOut = set_normal_angle_degree_range(angleIn )
% angleOut = SET_NORMAL_ANGLE_DEGREE_RANGE(angleIn )
%
% Purpose: set angle to between 0 and 359;
%
% check angle is under 360
angleOut = angleIn;
if abs(angleOut) >= 360
   timesDiv = floor(angleOut/360);
    angleOut = angleOut-360*timesDiv;
end

% bring to positive value
if angleOut < 0
    angleOut = angleOut+360; 
end

end