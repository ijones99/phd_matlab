function xyOut = vector_xy_components(directionsIn, L, angularUnits)
% xyOut = GEOMETRY.VECTOR_XY_COMPONENTS(directionsIn, L, angularUnits)
%
% Purpose: compute xy components of vectors
%
% Arguments:
%   directionsIn:
%   L: 
%   angularUnits:


% default vector length = 1
if nargin<2
    L = ones(1,length(directionsIn));
end

% default degrees
if nargin<3
    angularUnits = 'deg';
end

% if degrees are used:
if strcmp(angularUnits,'deg')
    directionsIn_rad = directionsIn*(2*pi()/360);
else
    directionsIn_rad = directionsIn;
end

% calculate xy values
xyOut(:,1) = [cos(directionsIn_rad).*L]';
xyOut(:,2) = [sin(directionsIn_rad).*L]';

end
