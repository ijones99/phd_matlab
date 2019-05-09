function line2 = beamer2array_vector_offset_and_transpose2(degIn, offset)
% line2 = BEAMER2ARRAY_VECTOR_OFFSET_AND_TRANSPOSE2(degIn, offset)
%
% purpose: angle for line on screen will be converted into the line 
% vector that is seen on the chip when an image is projected by the beamer.
%


% hard-code values
angleVecToOffset = [270 90 180 0 315 135 225 45]';

if offset >= 0
    angleVecToOffset(:,2) = [180 0 270 90 225 45 315 135]';
    
else
    angleVecToOffset(:,2) = [0   180 90 270 45 225 135 315]';
end

if isempty(find(angleVecToOffset(:,1)==degIn))
    error('Angle must be multiple of 45.')
end

% set angle range
degVecOnScreen = geometry.set_normal_angle_degree_range(degIn );
degOffsetOnScreen =  angleVecToOffset(find(angleVecToOffset(:,1) == degVecOnScreen),2);

% convert
degVecOnChip = beamer.beamer2array_vector_transposition(degVecOnScreen);
degOffsetOnChip = beamer.beamer2array_vector_transposition(degOffsetOnScreen);

% vector after transpose
[x y] = geometry.unit_vector_components_from_angle(degVecOnChip);
[x_offset y_offset] = geometry.unit_vector_components_from_angle(degOffsetOnChip);
x_offset = x_offset*abs(offset);
y_offset = y_offset*abs(offset);
line2 = [0 0; x y]+[x_offset y_offset ;x_offset y_offset ];


% FOR TESTING
% figure, hold on, xlim([-5 5]),ylim([-5 5]), axis square
% lineX = line1; plot(lineX(:,1),lineX(:,2),'k','LineWidth', 2);plot(lineX(1,2),lineX(2,2),'ko')
% lineX = line2; plot(lineX(:,1),lineX(:,2),'b','LineWidth', 2);plot(lineX(1,2),lineX(2,2),'bo')

end

