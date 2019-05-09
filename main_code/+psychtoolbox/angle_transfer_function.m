function angleOut = angle_transfer_function(angleIn)
% angleOut = ANGLE_TRANSFER_FUNCTION(angleIn)
%
% purpose: translate angle vectors from what is projected (what one sees on the
% monitor) to what is actually projected on the chip.
%
% NOTE ON DIRECTIONS: using Matlab and Psychtoolbox standard directions:
%   0 degrees East, moving counterclockwise. 

angleIn = geometry.angle2std_range( angleIn);

if angleIn <= 180
   angleOut =  angleIn-2*(angleIn-90);
else
   angleOut =  angleIn-2*(angleIn-270);
end

% standardize angle range
angleOut = rem(angleOut,360);

end