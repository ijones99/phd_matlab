function [xyOut] = angle2xy(angleDegIn, distIn)
% [xyOut] = ANGLE2XY(angleDegIn, distIn)
% xyOut: column one has x vals; column two has y vals



xyOut = nan(length(angleDegIn),2);

angleRadIn = angleDegIn*2*pi()/360;

xyOut(:,1) = cos(angleRadIn).*distIn;
xyOut(:,2) = sin(angleRadIn).*distIn;


end