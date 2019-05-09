function angleOut = angle2std_range(angleIn)
% angleOut = ANGLE2STD_RANGE(angleIn)

if angleIn < 0
    multVal = floor(abs(angleIn/360))+1;
    angleIn = angleIn+multVal*360;
end

angleOut = rem(angleIn,360);


end