function angleOut = standardize_angle_range(angleIn)
% angleOut = STANDARDIZE_ANGLE_RANGE(angleIn)

if angleIn < 0
    multVal = floor(abs(angleIn/360))+1;
    angleIn = angleIn+multVal*360;
end

angleOut = rem(angleIn,360);




end