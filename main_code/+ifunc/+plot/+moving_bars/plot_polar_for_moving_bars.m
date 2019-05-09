function plot_polar_for_moving_bars(data, Settings, barBrightness)
% plot_polar_for_moving_bars(data, Settings, barBrightness)


barAngles = double(Settings.BAR_DRIFT_ANGLE);
if strcmp(barBrightness,'on')
    onBar = double(Settings.BAR_BRIGHTNESS(1));
    plotColor = 'r';
elseif strcmp(barBrightness,'off')
    onBar = double(Settings.BAR_BRIGHTNESS(2));
    plotColor = 'b';
else
    fprintf('Error.\n')
end

for i=1:length(barAngles)
    rowInds = ifunc.mat.find_vals_in_cols(...
        data.Moving_Bars.processed_data.stimulus, [barAngles(i) NaN NaN onBar NaN]  );
    if isempty(rowInds)
       fprintf('Warning: No inds found; probably wrong parameter in Settings (plot_polar_for_moving_bars.m\n') 
    end
    
    % start stop time
    startStopTime(1) = 0;
    startStopTime(2) = max(data.Moving_Bars.frameno_info.stimFramesTsStartStopCol(:,2) - ...
        data.Moving_Bars.frameno_info.stimFramesTsStartStopCol(:,1));
    
    
    selRepeats = data.Moving_Bars.processed_data.repeatSpikeTimeTrain(rowInds);
    
    firingRate = ifunc.analysis.firing_rate.est_firing_rate_ks(selRepeats,...
        startStopTime);
    maxFiringRate(i) = max(firingRate);
    
end


ifunc.plot.plot_polar_for_rgc(barAngles, maxFiringRate, 'color', plotColor);


end