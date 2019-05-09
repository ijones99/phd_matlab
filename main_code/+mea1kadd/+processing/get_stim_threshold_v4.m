function [voltThresh xOut yOut respPerc fpReps ] = get_stim_threshold_v4(...
    uniqueVoltages,lookupTbStim, Xread, varargin)
% [voltThresh xOut yOut respPerc fpReps ] = get_stim_threshold_v4(uniqueVoltages,lookupTbStim, Xread,varargin)


xAxisWinSet = [];
yThresh = [];
doPlot = 1;
spikeDeflectionDir = -1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'y_spacing')
            ySpacing = varargin{i+1};
        elseif strcmp( varargin{i}, 'x_axis_window')
            xAxisWinSet= varargin{i+1};
        elseif strcmp( varargin{i}, 'y_thresh')
            yThresh = varargin{i+1};
        elseif strcmp( varargin{i}, 'do_plot')
            doPlot = varargin{i+1};
        elseif strcmp( varargin{i}, 'spike_deflection_dir')
            spikeDeflectionDir = varargin{i+1};
    end
end

[respPerc fpReps ] = mea1kadd.processing.threshold_responses_v3(uniqueVoltages,lookupTbStim,...
    Xread,'x_axis_window',xAxisWinSet,'y_thresh', yThresh, ...
    'spike_deflection_dir', spikeDeflectionDir  );

idxIsnan = isnan(respPerc);
respPerc(idxIsnan) = [];
uniqueVoltages(idxIsnan) = [];


[fittedData voltThresh xOut yOut] = ...
    fit_sigmoidal_curve_to_percent_response(uniqueVoltages, respPerc);



end