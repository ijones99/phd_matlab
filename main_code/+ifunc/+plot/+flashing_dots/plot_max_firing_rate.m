function plot_max_firing_rate(data, dotDiameters, brightness, startStopTime,varargin)
% function plot_max_firing_rate(data, dotDiameters, brightness, startStopTime)
% ijones

P.plotArgs = [];
P = mysort.util.parseInputs(P, varargin, 'error');

stimulusVars = data.Flashing_Dots.processed_data.stimulus;
repeatResponse = data.Flashing_Dots.processed_data.repeatSpikeTimeTrain;
searchColumns = zeros(length(dotDiameters),2);
searchColumns(:,2) = dotDiameters;
searchColumns(:,1) = brightness;


[firingRate firingRateMax edges] = ...
    ifunc.analysis.firing_rate.compute_firing_rates_for_data(...
    stimulusVars,repeatResponse, searchColumns,startStopTime);

plot(dotDiameters,firingRateMax,P.plotArgs{:});


end