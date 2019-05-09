function [xyOut] = intercepts_for_offset_parallel_to_angle(angleDegIn, distIn)

angleRadIn = angleDegIn*2*pi()/360;

xyOut(1) = distIn/cos(angleRadIn);
xyOut(2) = distIn/sin(angleRadIn);


end