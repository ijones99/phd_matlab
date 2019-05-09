function [xyOut] = intercepts_for_offset_parallel_to_angle(angleDegIn, distIn)

angleRadIn = angleDegIn*2*pi()/360;

xyOut(1) = cos(angleRadIn)*distIn;
xyOut(2) = sin(angleRadIn)*distIn;


end