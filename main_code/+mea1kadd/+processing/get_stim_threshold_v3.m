function [voltThresh xOut yOut ] = get_stim_threshold_v3(m_stim, uniqueVoltages,lookupTbStim, Xread, selStimEl, readoutEl,varargin)
% [voltThresh xOut yOut ] = get_stim_threshold_v2(m_stim, uniqueVoltages,lookupTbStim, fpRepsAll, selStimEl, readoutEl,varargin)


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

respPerc = mea1kadd.processing.threshold_responses(m_stim, uniqueVoltages,lookupTbStim,...
    Xread, selStimEl, selStimEl,'x_axis_window',xAxisWinSet,'y_thresh', yThresh, ...
    'spike_deflection_dir', spikeDeflectionDir  );

fittedData= fit_sigmoidal_curve_to_percent_response(uniqueVoltages, respPerc);

hFit = plot(fittedData,uniqueVoltages, respPerc);

xi=get(hFit,'XData');
yi=get(hFit,'YData');
diffFromPt = abs(yi{2}-0.5);
[Y idxClosest ] = min(diffFromPt);

% coeff = coeffvalues(fittedData);
xOut  = [];yOut =[];
if Y < 0.1
    voltThresh = xi{2}(idxClosest);
    xOut = xi{2};
    yOut = yi{2};
else
    warning('curve does not reach 50%');
    voltThresh = nan;
end



% voltThresh = coeff(2);

if voltThresh > max(uniqueVoltages) | voltThresh < min(uniqueVoltages)
    warning('no proper fit achieved')
    voltThresh = nan;
end
end