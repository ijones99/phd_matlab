function [ctrMass amps ]= center_of_mass(waveforms, xyCoord )
% function [ctrMass amps ] = CENTER_OF_MASS(waveforms, xyCoord  )
%   args
%       waveforms: [   numCH   numSamples]
%       xyCoord: .x and .y coords in um
%
%   Note: is not true center of mass for neuron, since elements outside of
%   the electrode configuration are not counted. For this, a fitted
%   Gaussian would be necessary.

amps = max(waveforms,[],2)'-min(waveforms,[],2)';

ampsScaled = scaledata(amps,0,1);

if ~isfield(xyCoord,'x')
   error('xyCoords must be in struct form of var.x and var.y');
end


if iscolumn(xyCoord.x)
    xyCoord.x = xyCoord.x';
     xyCoord.y = xyCoord.y';
end

ctrMass.x = sum(xyCoord.x.*ampsScaled)/sum(ampsScaled);
ctrMass.y = sum(xyCoord.y.*ampsScaled)/sum(ampsScaled);





end