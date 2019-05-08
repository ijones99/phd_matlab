function neur = compute_vis_stim_parameters3(neur, spotsSettings, barsSettings,varargin)
% neur = COMPUTE_VIS_STIM_PARAMETERS3(neur, spotsSettings, barsSettings)
%
%
% spotsSettings -> load ~/Matlab/settings/stimFrameInfo_spots.mat
% barsSettings -> load(fullfile('~/Matlab/settings', 'stimFrameInfo_movingBar_2reps'))

doMakePlot = 0;
doSavePlot = 0;
plotFileTypes{1} = 'fig';
sptBrightnessInterval = [-1/3 1/3];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot')
            doMakePlot  = 1;
        elseif strcmp( varargin{i}, 'save_plot')
            doSavePlot  = 1;
            
        end
    end
end

clear paramOut

stimFrameInfo = spotsSettings;
% get switch times
interStimTime = 0.5;


% logic check
if length(neur.spt.stim_change_ts)/2 ~= length(stimFrameInfo.rep)
    error('timestamps do not match.')
end
framenoSeparationTimeSec = 0.5;
adjustToZero = 1;
neur.spt.spikeTrains = extract_spiketrain_repeats_to_cell(neur.spt.st, ...
    neur.spt.stim_change_ts,adjustToZero);

% find preferred stim
[onOff,stimIdx, spikeCountsMean] = response_params_calc.spt.find_preferred_stim(...
    neur.spt.spikeTrains, stimFrameInfo);
onOff =onOff(1); stimIdx = stimIdx(1);

dotBrightness = {'on', 'off'}; dotDiams = unique(spotsSettings.dotDiam);

try
    neur.spt.pref_brightness = dotBrightness{onOff};
catch
    neur.spt.pref_brightness = NaN;
end

if isint(stimIdx) && onOff>0
    neur.spt.pref_diam = dotDiams(stimIdx);
end

% rare occurence: if more than one preferred stim found (arbitrary choice)
if length(stimIdx) > 1
    onOff(2:end)=[];
    stimIdx(2:end)=[];
    warning(sprintf('More than one preferred spot size for cluster %d! First val selected.',...
        neur.info.auto_clus_no));
    neur.info.warning = 'More than one preferred spot size for cluster %d!';
end

if iscolumn(neur.spt.spikeTrains)
    testST = neur.spt.spikeTrains';
else
    testST = neur.spt.spikeTrains;
end
if sum(sum(cell2mat(testST))) > 0 && not(isnan(stimIdx)) % if there are spiketrains found!
    ONcntStAvg = spikeCountsMean(1,stimIdx);
    OFFcntStAvg = spikeCountsMean(2,stimIdx);
else
    ONcntStAvg = NaN;
    OFFcntStAvg = NaN;
end

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
if sum(isnan(preferredIdx)) == 0
    firingRateMeanPref = peakFR(preferredIdx(1),:, preferredIdx(2));
else
    firingRateMeanPref = 0;
end
if sum(sum(firingRateMeanPref))>0
    paramOut.latency = response_params_calc.latency_simple(firingRateMeanPref, ...
        edges);
else
    paramOut.latency = NaN;
end

% TRANSIENCE
timeDurSec = 1.5;
if sum(sum(firingRateMeanPref)) > 0
paramOut.transience = ...
    response_params_calc.transience_simple(firingRateMeanPref, ...
    edges,timeDurSec);
else
    paramOut.transience = NaN;
end
% RF
if ~isnan(onOff)
    paramOut.rf = response_params_calc.rf(spotDiams, spikeCountsMean(onOff,:));
else
    paramOut.rf  = NaN;
end
% DS index
neur.mb.presentationTimeRangeSec = [0 2];
% load(fullfile('~/Matlab/settings', 'stimFrameInfo_movingBar_2reps'))
stimFrameInfo = barsSettings;
barDirUnique = unique(stimFrameInfo.angle);
barRGBVal = sort(unique(stimFrameInfo.rgb),'descend');
startStopTime = neur.mb.presentationTimeRangeSec*2e4;

firingRateAll = [];

% get switch times
interStimTime = 0.5;
framenoSeparationTimeSec = 0.5;

if length(neur.mb.stim_change_ts)/2 ~= length(stimFrameInfo.rep)
    error('timestamps do not match.')
end

adjustToZero = 1;
neur.mb.spikeTrains = extract_spiketrain_repeats_to_cell(neur.mb.st, ...
    neur.mb.stim_change_ts,adjustToZero, 'repeat_time_duration',2);
% get offsets for moving bars

outputData = stimulus.bars.find_closest_bar_offset_match_for_given_point(...
    stimFrameInfo, neur.info.clus_ctr_xy);

neur.mb.info = outputData;
neur.mb.headings = {'on_screen_angles', 'transposed_angles', 'offset', 'distance_to_bar_ctr'};

peakFR_mb = [];
barsIdxPlot = [];
barsDirecPlot = [];

for jRGB = 1:length(barRGBVal) % ON , OFF
    for i=1:length(barDirUnique)
        % find the index for the offset data, outputData. SCREEN DIRECTIONS
        outputDataIdx = find(outputData(:,1)==barDirUnique(i));
        % get idx for response based on SCREEN DIRECTION
        selResponseIdx = find(stimFrameInfo.angle == barDirUnique(i)&...
            stimFrameInfo.rgb == barRGBVal(jRGB)&...
            stimFrameInfo.offset == outputData(outputDataIdx,3));
        % idx for plot
        barsIdxPlot = [barsIdxPlot  selResponseIdx];
        % CHIP DIRECTIONS
        currDirections = outputData(outputDataIdx,2)*ones(1,length(selResponseIdx));
        barsDirecPlot = [barsDirecPlot currDirections ];
        [firingRate edges_mb] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
            neur.mb.spikeTrains(selResponseIdx ),startStopTime,'bin_width',...
            integWinTime_sec*2e4);
        firingRateAll(i,:) = firingRate;
        peakFR_mb(jRGB,i) = max(firingRate);
    end
    
end
peakFRNorm = peakFR_mb/max(max(peakFR_mb));
angleOut = beamer.beamer2chip_angle_transfer_function(barDirUnique);
if ~isnan(onOff)
    peakFRSel = peakFR_mb( onOff,:);
    paramOut.ds = response_params_calc.ds(angleOut, peakFRSel);
else
    paramOut.ds = NaN;
end
if isfield(neur.spt, 'pref_diam')
    paramOut.spt_pref_diam = neur.spt.pref_diam;
end
% if isint(onOff) && onOff>0
%     neur.spt.pref_brightness = dotBrightness{onOff};
% end
% if isfield(neur.spt, 'pref_brightness')
if paramOut.bias <= sptBrightnessInterval(1)
    paramOut.spt_pref_brightness = 'off';
elseif paramOut.bias > sptBrightnessInterval(1) & paramOut.bias < sptBrightnessInterval(2)
    paramOut.spt_pref_brightness = 'on-off';
elseif paramOut.bias  >= sptBrightnessInterval(2)
    paramOut.spt_pref_brightness = 'on';
end

% end

% find footprint peak-to-peak
if isfield(neur,'footprint')
    paramOut.p2p = max(max(neur.footprint.average')-min(neur.footprint.average'));
end

%Save paramout
neur.paramOut = paramOut;
% save(fullfile('../analysed_data/', neurFileName), 'neur');

% calc ds characteristics
angleVectorsOnChip = beamer.beamer2chip_angle_transfer_function( barDirUnique);
[J I] = sort(max(peakFRNorm,[],2),'descend');
neur.mb.ds = [];
neur.mb.ds.angles = angleVectorsOnChip ;
neur.mb.ds.peak_fr = peakFR_mb;
neur.mb.ds.peak_fr_norm = peakFRNorm;
neur.mb.ds.info = 'column 1 is ON, column 2 is OFF';


if doMakePlot
    stimFrameInfo = spotsSettings;
    % plot response to different spot sizes
    h1=figure, hold on, plot(spotDiams, spikeCountsMean','s-'), legend({'on','off'});
    xlabel('spot diameter (um)')
    ylabel('Firing Rate (Hz)')
    if doSavePlot
        dirNameFig = sprintf('../Figs/Visual_Stim/%d/',neur.info.clus_no);
        fileNameFig = sprintf('%d_spots_mean_firing_rate_per_spot_diam', neur.info.clus_no);
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
        
        fileNameFig = sprintf('%d_spots_fr_response_per_spot_diam', neur.info.clus_no);
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
        
        fileNameFig = sprintf('%d_spots_fr_preferred', neur.info.clus_no);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end
    
    % plot DS characteristics
    h4=figure
    
    
    [J I] = sort(max(peakFRNorm,[],2),'descend');
    polarPlotColors = {'r','k'};
    polarStimType = {'ON', 'OFF'};
  
    plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(I(1),:),'line_style',polarPlotColors{I(1)},...
        'no_normalization');hold on
    plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(I(2),:),'line_style',polarPlotColors{I(2)},...
        'no_normalization');
    maxSpikecountON = max(peakFR_mb(1,:)); % ON is 1
    maxSpikecountOFF = max(peakFR_mb(2,:));% OFF is 2
    titleName = sprintf('RGC Response Moving Bars (max spk ON = %3.0f, max spk OFF = %3.0f) ', maxSpikecountON, maxSpikecountOFF)
    title(titleName)
    legend({polarStimType{I(1)}; polarStimType{I(2)}});
    figureHandle = gcf;
    % set font sizes
    set(findall(figureHandle,'type','text'),'fontSize',14)
    set(gca,'FontSize',14)
    
    fileNameFig = sprintf('moving_bars_polar');
    if doSavePlot
        
        fileNameFig = sprintf('%d_moving_bars_polar', neur.info.clus_no);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end
    
    % plot rasters of bars
    
    figure, hold on
    stimulus.bars.plot_bars_raster( neur.mb.spikeTrains(barsIdxPlot(1:16)), barsDirecPlot)
    title(sprintf('%d - ON Bars',neur.info.clus_no))
    if doSavePlot
        fileNameFig = sprintf('%d_moving_bars_raster_ON', neur.info.clus_no);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end
    
    figure, hold on
    stimulus.bars.plot_bars_raster( neur.mb.spikeTrains(barsIdxPlot(17:end)), barsDirecPlot)
    title(sprintf('%d - OFF Bars',neur.info.clus_no))
    if doSavePlot
        fileNameFig = sprintf('%d_moving_bars_raster_OFF', neur.info.clus_no);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end
       % plot rasters of spots
    
    figure, hold on
    stimulus.spots.plot_spots_raster( spotsSettings,neur.spt.spikeTrains,248)
    title(sprintf('%d - ON Spots',neur.info.clus_no))
    if doSavePlot
        fileNameFig = sprintf('%d_spots_raster_ON', neur.info.clus_no);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end
    
    figure, hold on
    stimulus.spots.plot_spots_raster( spotsSettings,neur.spt.spikeTrains,0)
    title(sprintf('%d - OFF Spots',neur.info.clus_no))
    if doSavePlot
        fileNameFig = sprintf('%d_spots_raster_OFF', neur.info.clus_no);
        for iSave = 1:length(plotFileTypes)
            save.save_plot_to_file(dirNameFig, fileNameFig,plotFileTypes{iSave});
        end
    end 
    
    
end


end