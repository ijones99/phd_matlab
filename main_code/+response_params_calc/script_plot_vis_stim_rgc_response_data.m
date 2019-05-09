% script_plot_vis_stim_rgc_response_data
%% init
pathDef = dirdefs();%expName = '17Jun2014';
expName = get_dir_date
fileNames = filenames.get_filenames('*.mat', fullfile(pathDef.neuronsSaved,expName))

% % init
paraOutputMat = [];
paraOutputMat.headings = {};
paraOutputMat.neur_names = {};
paraOutputMat.params = zeros(1,5);
doSetHeadings = 0;
doDebug = 0;

fileNo = 1;

for i=fileNo
    load(fullfile(pathDef.neuronsSaved,expName,fileNames(i).name));
    if ~doDebug
        spotsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_spots.mat');
        barsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_movingBar_2reps.mat');
%         neur = response_params_calc.compute_vis_stim_parameters(neur, spotsSettings, barsSettings);
    end
end


%

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
% plot bias
figure, hold on, plot(spotDiams, spikeCountsMean','s-'), legend({'on','off'});
xlabel('spot diameter (um)')
ylabel('Firing Rate (Hz)')

dotRGBVal = sort(unique(stimFrameInfo.rgb),'descend');
startStopTime = [-0.2 2]*2e4;
integWinTime_sec = 0.010;

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

% plot firing rates
figure, imagesc(peakFR(:, :, onOff))
set(gca, 'YTickLabel', spotDiams);
ylabel('spot diameter (um)')
colorbar

preferredIdx = [stimIdx onOff];
% plot spikes
selResponseIdx = find(stimFrameInfo.dotDiam == ...
    spotDiams(stimIdx)&stimFrameInfo.rgb == dotRGBVal(onOff) );
spikeTrainsPref = neur.spt.spikeTrains(selResponseIdx );

% LATENCY
firingRateMeanPref = peakFR(preferredIdx(1),:, preferredIdx(2));
figure, hold on, plot(edges/2e4, firingRateMeanPref,'b'), legend({'on','off'});
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

% TRANSIENCE
timeDur_sec = 1.5;
paramOut.transience = ...
    response_params_calc.transience_simple(firingRateMeanPref, ...
    edges,timeDur_sec);
plot.raster([paramOut.latency-paramOut.transience/2 paramOut.latency+paramOut.transience/2],...
    'color','r','height', 100,'offset',50);

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
            stimFrameInfo.offset == 0);
        [firingRate edges_mb] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
            neur.mb.spikeTrains(selResponseIdx ),startStopTime,'bin_width', integWinTime_sec*2e4);
         firingRateAll(i,:) = firingRate;
        
        peakFR_mb(jRGB,i) = max(firingRate);
        
    end
end
peakFRNorm = peakFR_mb/max(max(peakFR_mb));

% plot DS characteristics
h4=figure
angleVectorsOnChip = beamer.beamer2chip_angle_transfer_function( barDirUnique);
plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(1,:),'line_style','k');hold on
plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(2,:),'line_style','r');
titleName = sprintf('RGC Response Moving Bars')
title(titleName)
legend({'OFF';'ON'});
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('%s_moving_bars_polar', neurFileName);

angleOut = beamer.beamer2chip_angle_transfer_function(barDirUnique);
peakFRSel = peakFR_mb( onOff,:);
paramOut.ds = response_params_calc.ds(angleOut, peakFRSel);
%Save
neur.paramOut = paramOut;
paramOut
% save(fullfile('../analysed_data/', neurFileName), 'neur');