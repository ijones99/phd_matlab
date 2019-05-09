function [p2pStimValsPerPulse stimPulsePts ] = get_dac_epochs_in_data( stimDACData, numDACSwitchesPerStim )
% Function p2pStimValsPerPulse = get_dac_epochs_in_data( stimDACData, numDACSwitchesPerStim )
% 
% Arguments
%   stimDACData: dac1 or dac2 data
%   numDACSwitchesPerStim: 3 for biphasic or 4 for biphasic

voltSwitchTime = diff(stimDACData);
switchTimePts = find(voltSwitchTime~=0); % indices
...for time point switches (#phases + 1 per pulse:
    ...e.g. for biphasic pulse, 3 points per pulse. (see numDACSwitchesPerStim size)
    
stimPulsePts = switchTimePts(1:numDACSwitchesPerStim:end); % time points of every pulse
voltageMaxInds = switchTimePts(2:numDACSwitchesPerStim:end); % time points of max values
voltageMinInds = switchTimePts(3:numDACSwitchesPerStim:end); % time points of min values

% get voltage values.dac
p2pStimValsPerPulse = stimDACData(voltageMaxInds)-stimDACData(voltageMinInds);

end