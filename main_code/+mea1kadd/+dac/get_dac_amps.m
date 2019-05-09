function [amps idxPulse ] = get_dac_amps(DAC)
% [amps idxPulse ] = GET_DAC_AMPS(DAC)

pulseWidth = 10;


DAC = double(DAC)-mean(double(DAC(1:10)));
% locations of DAC changes
diffDAC = diff(double(DAC));
idxPulse = find(diffDAC>0);

idxClose = find(diff(idxPulse) < pulseWidth);
idxPulse(idxClose) = [];

% get voltages
idx = repmat(idxPulse,1,2*pulseWidth)+...
    repmat([-pulseWidth:pulseWidth-1],size(idxPulse,1),1);

selData = double(DAC(idx));

amps = max(selData,[],2)- min(selData,[],2) ;





end
