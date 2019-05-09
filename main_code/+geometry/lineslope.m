function slopeOut = lineslope(line1)
% function SLOPEOUT = lineslope(line1)
%
% line1 = [.5 1; 1 0];

slopeOut = diff(line1(:,2))/diff(line1(:,1));



end