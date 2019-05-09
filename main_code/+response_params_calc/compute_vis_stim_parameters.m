function neur = compute_vis_stim_parameters(neur, spotsSettings, barsSettings,varargin)
% neur = COMPUTE_VIS_STIM_PARAMETERS(neur, spotsSettings, barsSettings)
%
%
% spotsSettings -> load ~/Matlab/settings/stimFrameInfo_spots.mat
% barsSettings -> load(fullfile('~/Matlab/settings', 'stimFrameInfo_movingBar_2reps'))

doMakePlot = 0;
doSavePlot = 0;
plotFileTypes{1} = 'fig';
barOffset = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot')
            doMakePlot  = 1;
        elseif strcmp( varargin{i}, 'save_plot')
            doSavePlot  = 1;
        elseif strcmp( varargin{i}, 'bar_offset')
                       
            barOffset = varargin{i+1};
        end
    end
end

clear paramOut

stimFrameInfo = spotsSettings;
% get switch times
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(neur.spt.frameno,interStimTime);

if length(stimChangeTs)/2 ~= length(stimFrameInfo.rep)
    error('timestamps do not match.')
end
framenoSeparationTimeSec = 0.5;
adjustToZero = 1;
neur.spt.spikeTrains = extract_spiketrain_repeats_to_cell(neur.spt.st, ...
    stimChangeTs,adjustToZero);

% find preferred stim
[onOff,stimIdx, spikeCountsMean] = response_params_calc.spt.find_preferred_stim(...
    neur.spt.spikeTrains, stimFrameInfo);

ONcntStAvg = spikeCountsMean(1,stimIdx);
OFFcntStAvg = spikeCountsMean(2,stimIdx);

% BIAS
paramOut.bias = response_params_calc.bias_index2(ONcntStAvg,OFFcntStAvg);

% latency
% load ~/Matlab/settings/stimFrameInfo_spots.mat

% calculate mean firing rate
spotDiams = unique(stimFrameInfo.dotDiam);
dotRGBVal = sort(unique(stimFrameInfo.rgb),'descend');
startStopTime = [-0.2 2]*2e4;
integWinTime_sec = 0.010;
clear peakFR
% ON: 1 OFF: 2
% peakFR      6x61x2 : [diam_vals x samples x brightness];
for jRGB = 1:length(dotRGBVal)
    for iDiam=1:length(spotDiams)
        selResponseIdx = find(stimFrameInfo.dotDiam == ...
            spotDiams(iDiam)&stimFrameInfo.rgb == dotRGBVal(jRGB) );
        [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
            neur.spt.spikeTrains(selResponseIdx ),startStopTime,'bin_width', integWinTime_sec*2e4);
        peakFR(iDiam, :, jRGB) = firingRate;
        %         figure, plot(0.025*(1:length(edges)), firingRate);
    end
end

preferredIdx = [stimIdx onOff];
% LATENCY
firingRateMeanPref = peakFR(preferredIdx(1),:, preferredIdx(2));
paramOut.latency = response_params_calc.latency_simple(firingRateMeanPref, ...
    edges);

% TRANSIENCE
timeDurSec = 1.5;
paramOut.transience = ...
    response_params_calc.transience_simple(firingRateMeanPref, ...
    edges,timeDurSec);
% RF
paramOut.rf = response_params_calc.rf(spotDiams, spikeCountsMean(onOff,:));

% DS index
neur.mb.presentationTimeRangeSec = [0 2];
% load(fullfile('~/Matlab/settings', 'stimFrameInfo_movingBar_2reps'))
stimFrameInfo = barsSettings;
barDirUnique = unique(stimFrameInfo.angle,'stable');
barRGBVal = sort(unique(stimFrameInfo.rgb),'descend');
startStopTime = neur.mb.presentationTimeRangeSec*2e4;

firingRateAll = [];

% get switch times
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(neur.mb.frameno,interStimTime);
framenoSeparationTimeSec = 0.5;

if length(stimChangeTs)/2 ~= length(stimFrameInfo.rep)
    error('timestamps do not match.')
end

adjustToZero = 1;
neur.mb.spikeTrains = extract_spiketrain_repeats_to_cell(neur.mb.st, ...
    stimChangeTs,adjustToZero);

peakFR_mb = [];
for jRGB = 1:length(barRGBVal)
    for i=1:length(barDirUnique)
        selResponseIdx = find(stimFrameInfo.angle == barDirUnique(i)&...
            stimFrameInfo.rgb == barRGBVal(jRGB)&...
            stimFrameInfo.offset == barOffset);
        [firingRate edges_mb] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
            neur.mb.spikeTrains(selResponseIdx ),startStopTime,'bin_width',...
            integWinTime_sec*2e4);
        firingRateAll(i,:) = firingRate;
        peakFR_mb(jRGB,i) = max(firingRate);
    end
end
peakFRNorm = peakFR_mb/max(max(peakFR_mb));
angleOut = beamer.beamer2chip_angle_transfer_function(barDirUnique);
peakFRSel = peakFR_mb( onOff,:);
paramOut.ds = response_params_calc.ds(angleOut, peakFRSel);
%Save
neur.paramOut = paramOut;
% save(fullfile('../analysed_data/', neurFileName), 'neur');


if doMakePlot
    stimFrameInfo = spotsSettings;
    % plot response to different spot sizes
    h1=figure, hold on, plot(spotDiams, spikeCountsMean','s-'), legend({'on','off'});
    xlabel('spot diameter (um)')
    ylabel('Firing Rate (Hz)')
    if doSavePlot
        dirNameFig = sprintf('../Figs/Visual_Stim/%s/',neur.info.ums_clus_name);
        fileNameFig = sprintf('%s_spots_mean_firing_rate_per_spot_diam', neur.info.ums_clus_name);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end
    
    % plot firing rates
    h2=figure, imagesc(peakFR(:, :, onOff))
    set(gca, 'YTickLabel', spotDiams);
    ylabel('spot diameter (um)')
    colorbar
    if doSavePlot
       
        fileNameFig = sprintf('%s_spots_fr_response_per_spot_diam', neur.info.ums_clus_name);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end
    
    preferredIdx = [stimIdx onOff];
    selResponseIdx = find(stimFrameInfo.dotDiam == ...
        spotDiams(stimIdx)&stimFrameInfo.rgb == dotRGBVal(onOff) );
    spikeTrainsPref = neur.spt.spikeTrains(selResponseIdx );
    
    % plot latency, transience, spikes, spiking rate
    firingRateMeanPref = peakFR(preferredIdx(1),:, preferredIdx(2));
    h3=figure, hold on, plot(edges/2e4, firingRateMeanPref,'b'), legend({'on','off'});
    xlabel('Time (sec)')
    ylabel('Firing Rate (Hz)')
    paramOut.latency = response_params_calc.latency_simple(firingRateMeanPref, ...
        edges);
    plot.raster([0 paramOut.latency],'color','g','height', 100,'offset',50);
    for i=1:length(neur.spt.spikeTrains(selResponseIdx ))
        plot.raster(neur.spt.spikeTrains{selResponseIdx(i) }/2e4,'offset', i*5,'line_width',4)
    end
    for i=1:length(neur.spt.spikeTrains(selResponseIdx ))
        plot.raster(neur.spt.spikeTrains{selResponseIdx(i) }/2e4,'line_width',5)
    end
    
    plot.raster([paramOut.latency-paramOut.transience/2 paramOut.latency+paramOut.transience/2],...
        'color','r','height', 100,'offset',50);
    if doSavePlot
        
        fileNameFig = sprintf('%s_spots_fr_preferred', neur.info.ums_clus_name);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end
    
    % plot DS characteristics
    h4=figure
    angleVectorsOnChip = beamer.beamer2chip_angle_transfer_function( barDirUnique);
    plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(1,:),'line_style','k');hold on
    plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(2,:),'line_style','r');
    maxSpikecountON = max(peakFR_mb(1,:));
    maxSpikecountOFF = max(peakFR_mb(2,:));
    titleName = sprintf('RGC Response Moving Bars (max spk ON = %3.0f, max spk OFF = %3.0f) ', maxSpikecountON, maxSpikecountOFF)
    title(titleName)
%     legend({'OFF';'ON'});
    figureHandle = gcf;
    % set font sizes
    set(findall(figureHandle,'type','text'),'fontSize',14)
    set(gca,'FontSize',14)
   
    fileNameFig = sprintf('moving_bars_polar');
    if doSavePlot
        
        fileNameFig = sprintf('%s_moving_bars_polar', neur.info.ums_clus_name);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end
end


end