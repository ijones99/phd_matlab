function angleOut = beamer2chip_angle_transfer_function(angleIn)
% angleOut = BEAMER2CHIP_ANGLE_TRANSFER_FUNCTION(angleIn)
%
% purpose: translate angle vectors from what is projected (what one sees on the
% monitor) to what is actually projected on the chip.
%
% NOTE ON DIRECTIONS: using Matlab and Psychtoolbox standard directions:
%   0 degrees East, moving counterclockwise. 
angleInRot = angleIn-90;

if angleInRot > 359
    angleInRot  = angleInRot -360;
end


if angleInRot <= 180
   angleOut =  angleInRot-2*(angleInRot-90);
else
   angleOut =  angleInRot-2*(angleInRot-270);
end



end