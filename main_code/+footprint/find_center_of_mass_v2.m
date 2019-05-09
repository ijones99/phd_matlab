function [ctrMass amps ]= find_center_of_mass_v2(waveforms, xyCoord )
% function [ctrMass amps ] = CENTER_OF_MASS(waveforms, xyCoord  )
%   args
%       waveforms: [   numCH   numSamples]
%       xyCoord: .x and .y coords in um
%
%   Note: is not true center of mass for neuron, since elements outside of
%   the electrode configuration are not counted. For this, a fitted
%   Gaussian would be necessary.

amps = max(waveforms,[],2)'-min(waveforms,[],2)';

ampsScaled = amps/sum(amps);

if ~isfield(xyCoord,'x')
   error('xyCoords must be in struct form of var.x and var.y');
end


if iscolumn(xyCoord.x)
    xyCoord.x = xyCoord.x';
     xyCoord.y = xyCoord.y';
end

% find max amp and xy locations
idxMaxAmp = find(amps == max(amps)); idxMaxAmp = idxMaxAmp(1);
xyLocMaxAmp.x = xyCoord.x(idxMaxAmp);
xyLocMaxAmp.y = xyCoord.y(idxMaxAmp);

% find closest els
[ distance] = geometry.get_distance_between_2_points(xyLocMaxAmp.x , xyLocMaxAmp.y ,...
    xyCoord.x, xyCoord.y);
idxClosestEls = find(distance < 20);

if 1==1
    ctrMass.x = sum(xyCoord.x(idxClosestEls).*ampsScaled(idxClosestEls))/sum(ampsScaled(idxClosestEls));
    ctrMass.y = sum(xyCoord.y(idxClosestEls).*ampsScaled(idxClosestEls))/sum(ampsScaled(idxClosestEls));
else
    ctrMass.x = sum(xyCoord.x.*ampsScaled)/sum(ampsScaled);
    ctrMass.y = sum(xyCoord.y.*ampsScaled)/sum(ampsScaled);
end




end