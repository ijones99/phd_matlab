function angleInDegreesOUT = angle_positive_value(angleInDegreesIN )
% angleInDegreesOUT = ANGLE_POSITIVE_VALUE(angleInDegreesIN )

if abs(angleInDegreesIN) > 360
    angleInDegreesIN = rem(angleInDegreesIN,360);
end

if angleInDegreesIN < 0
    angleInDegreesOUT = 360+angleInDegreesIN;
    
else
    
    angleInDegreesOUT = angleInDegreesIN;
end

end
