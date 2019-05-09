function angleOut = beamer2array_vector_transposition(angleIn)
% angleOut = BEAMER2ARRAY_VECTOR_TRANSPOSITION(angleIn)
%
% rotate 90 degrees counterclockwise and flipud
%
%%
for i=1:length(angleIn)
    angleOut(i) = -(angleIn(i)+90);
    
    % check angle is under 360
    if abs(angleOut(i)) >= 360
        timesDiv = floor(angleOut(i)/360);
        angleOut(i) = angleOut(i)-360*timesDiv;
    end
    
    % bring to positive value
    if angleOut(i) < 0
        angleOut(i) = angleOut(i)+360;
    end
    
    
end
end