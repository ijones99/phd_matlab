%% Spots: get FR per dot size
% spots
spikeTrains = {};
i=4
framenoSeparationTimeSec = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno{configIdx(i)},framenoSeparationTimeSec);
% get location data
allTs = tsMatrix.st{i};
spikeTrainsConcatenated = round(allTs);
adjustToZero = 1;
spikeTrains= extract_spiketrain_repeats_to_cell(spikeTrainsConcatenated, ...
    stimChangeTs,adjustToZero);
neur.spt.spiketrains = spikeTrains;
% %%
% figure, hold on
% plot(stimChangeTs,ones(1,length(stimChangeTs)),'*')
% plot(spikeTrainsConcatenated, ones(1,length(spikeTrainsConcatenated)),'ro')
%
% load stim params
load ~/Matlab/settings/stimFrameInfo_spots.mat
dotDiams = unique(stimFrameInfo.dotDiam);
dotRGBVal = unique(stimFrameInfo.rgb);
startStopTime = [-0.5 1]*2e4;
clear peakFR
for jRGB = 1:length(dotRGBVal)
    for i=1:length(dotDiams)
        selResponseIdx = find(stimFrameInfo.dotDiam == dotDiams(i)&stimFrameInfo.rgb...
            == dotRGBVal(jRGB) );
        %         [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_from_psth(...
        %             neur.spt.spikeTrains(selResponseIdx ),startStopTime);
        [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
            neur.spt.spiketrains(selResponseIdx ),startStopTime);
        warning('Please check this algorithm for firing rate. Divide by bin width?.\n');
        
        peakFR(jRGB,i) = max(firingRate);
        
    end
end
figure, hold on,
lineWidth = 2;
plot(dotDiams, peakFR(1,:),'ko-','LineWidth',lineWidth);
plot(dotDiams, peakFR(2,:),'ro-','LineWidth',lineWidth);
xlabelName='Dot Diameters (um)'; ylabelName='Firing Rate (Hz)';
xlabel(xlabelName); ylabel(ylabelName);
dotBrightness = {'OFF', 'ON'};
titleName = sprintf('RGC Response to Flashing Spots (%s)', cellMatchReg{matchRegIdx,1})
title(titleName)
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
legend({'OFF';'ON'});

dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('run_%02d_%s_fr_per_spot_size', runNo, cellMatchReg{matchRegIdx,1});
save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
save.save_plot_to_file(dirNameFig, fileNameFig,'eps');
expName = get_dir_date;
eval(sprintf('open ../Figs/%s_sta_wn_checkerboard_n_%02d_clus_%s.fig',expName, runNo,cellMatchReg{matchRegIdx,1}))