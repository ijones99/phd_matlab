function [xyOut] = angle2two_pt_vec(angleDegIn)
% Output 2 points along a vector

lineLength = 1;

angleRadIn = angleDegIn*2*pi()/360;

xyOut = zeros(2);

% get slope
m = geometry.deg2slope(angleDegIn);

xyOut(:,1) = [0 0];
xyOut(:,2) = [+lineLength +lineLength*m];

end