function [xyOut] = xy_vector_locations_for_angle(angleDegIn, distOffset)

lineLength = 250;

angleRadIn = angleDegIn*2*pi()/360;

xyOut = zeros(2);

if distOffset==0
    % get slope
    m = geometry.deg2slope(angleDegIn);
    
    xyOut(:,1) = [-lineLength -lineLength*m]/2;
    xyOut(:,2) = [+lineLength +lineLength*m]/2;
    
else
    
    xyOut(:,1) = [ 0  0];
    xyOut(:,2) = [distOffset/cos(angleRadIn) distOffset/sin(angleRadIn) ];
end

end