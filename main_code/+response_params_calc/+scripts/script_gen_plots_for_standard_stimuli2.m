
%% preprocess marching square, moving bars and spots in batch mode (cluster)
spikesorting.batch_preprocess_files('batch_list_cell', wnCheckBrdPosData)

%% spikesort data: marching square, moving bars manually)

spikesorting.spt.spikesort_data_flist_select
%% extract timestamps for spots
spikesorting.extract_spiketimes_from_cl_files('input_file_info_cell',...
    fileInfoCell)


%% LOAD & SAVE FRAMENO INFO
frameno = ntk_file.load_and_save_frameno;

%% list files
!ls ../Figs/*_sta_wn_checkerboard_n_*fig

%% review clusters (wn, marching sqr, moving bar)
flistNames = {};
flistNames{end+1} = 'flist_wn_checkerboard_n_01';
flistNames{end+1} = 'flist_marching_sqr_and_moving_bars_n_01';
spiketrains.review_clusters_for_waveform_comparison(flistNames);

%% set all names

elAndClusNo = [1 6594	92	150	5
    ];
idx=1;
runNo = elAndClusNo(idx);idx=idx+1;
elidxCtr =elAndClusNo(idx) ;idx=idx+1;
clusNum.wn_checkerbrd = elAndClusNo(idx);idx=idx+1;
clusNum.msmb = elAndClusNo(idx);idx=idx+1;
clusNum.spt = elAndClusNo(idx);

clear neur

neur.wn_checkerbrd.clusterName =    ...
    sprintf('%04dn%02d', elidxCtr, clusNum.wn_checkerbrd );
neurFileName = sprintf('run_%02d_cell_%s', runNo, neur.wn_checkerbrd.clusterName);
neur.msmb.clusterName = sprintf('%04dn%02d', elidxCtr, clusNum.msmb);
[neur.msmb.elidxCtr  neur.msmb.clusNo] = filenames.parse_cluster_name(...
    neur.msmb.clusterName);
neur.ms.clusterName = sprintf('%04dn%02d', elidxCtr, clusNum.msmb);
[neur.ms.elidxCtr  neur.ms.clusNo] = filenames.parse_cluster_name(...
    neur.ms.clusterName);
neur.mb.clusterName = sprintf('%04dn%02d', elidxCtr, clusNum.msmb);
[neur.mb.elidxCtr  neur.mb.clusNo] = filenames.parse_cluster_name(...
    neur.mb.clusterName);
neur.spt.clusterName = sprintf('%04dn%02d', elidxCtr, clusNum.spt);
[neur.spt.elidxCtr  neur.spt.clusNo] = filenames.parse_cluster_name(...
    neur.spt.clusterName);

%% get framenos & timestamps for: marching square, moving bars & spots
% marching square & moving bars
fileNames = filenames.list_file_names('flist*marching_sqr*.m');
selFileIdx = input('Select flist number for marching sqr and moving bar >> ');
neur.msmb.flistName = fileNames(selFileIdx).name
flist = {}; [fileIdx ntkFileNames]= filenames.select_flist_name(...
    'prompt_string','marching sqr and moving bar' );
for i=1:length(fileIdx)
    flist{end+1} = sprintf('../proc/%s', ntkFileNames(fileIdx(i)).name);
end
[neur.msmb.spikeTrains neur.msmb.stimChangeTs neur.msmb.allTs ] = ...
    spiketrain_analysis.basic.load_spiketimes_and_stim_frameno(...
    neur.msmb.flistName, neur.msmb.elidxCtr, neur.msmb.clusNo, 'flist', flist, ...
    'flist_name', neur.msmb.flistName);
neur.msmb.allTs =  neur.msmb.allTs*2e4;

% spots
fprintf('Create flist for spots:\n\n');
promptStr = 'spots';
[selFileIdx fileNames]= filenames.select_flist_name('prompt_string', promptStr);
neur.spt.flist = fileNames(selFileIdx).name;

flist = {}; flist{end+1} = neur.spt.flist;
[neur.spt.elidxCtr neur.spt.clusNo ] = filenames.parse_cluster_name( ...
    neur.spt.clusterName)
neur.spt.flistName = sprintf('flist_spots_n_%02d',runNo )

neur.spt.spikeTrains =[];neur.spt.stimChangeTs =[];neur.spt.allTs =[];
[neur.spt.spikeTrains neur.spt.stimChangeTs neur.spt.allTs ] = ...
    spiketrain_analysis.basic.load_spiketimes_and_stim_frameno(...
    neur.spt.flistName, neur.spt.elidxCtr, neur.spt.clusNo,'flist', flist, ...
    'flist_name', neur.spt.flistName);

% marching square: 16 positions, 10 repeats, 2 directions (320 segments)
% moving bars:  get framenos (144 segments)
% spots:  get framenos (60 segments)

%% separate out into stim
% marching sqr
neur.ms.numSegs = 320;
neur.ms.flistName = sprintf('flist_marching_sqr_n_%02d',runNo);
neur.ms.elidxCtr = neur.msmb.elidxCtr;
[flist stimName ] = make_flist_select( neur.ms.flistName, 'prompt_string', ...
    'marching square')

fileSize = h5.get_size_ntk_recording(flist);
stSegs = spiketrains.segment_spiketrains(neur.msmb.allTs,fileSize{1}(1));
neur.ms.allTs = stSegs{1};
% neur.ms.stimChangeTs = neur.msmb.stimChangeTs;
neur.ms.spikeTrains = neur.msmb.spikeTrains(1:neur.ms.numSegs);

% mov bars
neur.mb.numSegs = 144;
neur.mb.allTs = stSegs{2};
neur.mb.spikeTrains = neur.msmb.spikeTrains(neur.ms.numSegs+1:neur.ms.numSegs+...
    neur.mb.numSegs);

% neur.spt.spikeTrains neur.spt.stimChangeTs neur.spt.allTs

%% Spots: get FR per dot size
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
            neur.spt.spikeTrains(selResponseIdx ),startStopTime);
        
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
titleName = sprintf('RGC Response to Flashing Spots (%s)', neur.spt.clusterName)
title(titleName)
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
legend({'OFF';'ON'});

dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('%s_fr_per_spot_size', neurFileName);
save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
save.save_plot_to_file(dirNameFig, fileNameFig,'eps');
%% Spots: PSTH for best dot response
% WORK IN PROGRESS
acqRate = 2e4;
load ~/Matlab/settings/stimFrameInfo_spots.mat
dotDiams = unique(stimFrameInfo.dotDiam);
dotRGBVal = unique(stimFrameInfo.rgb);
startStopTime = [-0.5 1]*2e4;
% get max FR and location for fr for ON and OFF
[responseMaxVal ] = max(reshape(peakFR,1,size(peakFR,1)*size(peakFR,2)));
[rows,cols,vals] = find(peakFR==responseMaxVal)
OFForON = rows;
diamIdx = cols;

selResponseIdx = find(stimFrameInfo.dotDiam == dotDiams(diamIdx)&stimFrameInfo.rgb...
    == dotRGBVal(OFForON) );
psth = ifunc.analysis.calc_psth(neur.spt.spikeTrains(selResponseIdx ), edges);
startStopTime = [-0.5 1]*2e4;
[firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
    neur.spt.spikeTrains(selResponseIdx),startStopTime,'bin_width',0.0001*2e4);
% plot figure
lineWidth = 2;
figure, plot(edges/acqRate,firingRate,'LineWidth', lineWidth), hold on
xlabelName='Time (ms)'; ylabelName='Firing Rate (Hz)';
xlabel(xlabelName); ylabel(ylabelName);
dotBrightness = {'OFF', 'ON'};
titleName = sprintf('RGC Response to Preferred %s Spot (%s)', ...
    dotBrightness{OFForON},neur.spt.clusterName)
title(titleName)
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('%s_fr_best_spot', neurFileName);
save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
save.save_plot_to_file(dirNameFig, fileNameFig,'eps');
%% MOVING BARS (adjusted for microscope optical transfer function)
neur.mb.presentationTimeRangeSec = [0 2];
load ~/Matlab/settings/stimFrameInfo_movingBar.mat
barDirUnique = unique(stimFrameInfo.angle);
barRGBVal = unique(stimFrameInfo.rgb);
startStopTime = neur.mb.presentationTimeRangeSec*2e4;
clear peakFR
firingRateAll = [];
for jRGB = 1:length(barRGBVal)
    for i=1:length(barDirUnique)
        selResponseIdx = find(stimFrameInfo.angle == barDirUnique(i)&...
            stimFrameInfo.rgb == barRGBVal(jRGB)&...
            stimFrameInfo.offset == 0);
        [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
            neur.mb.spikeTrains(selResponseIdx ),startStopTime)
        firingRateAll(i,:) = firingRate;
        
        peakFR(jRGB,i) = max(firingRate);
        
    end
end
peakFRNorm = peakFR/max(max(peakFR));


% plot DS characteristics
h=figure
angleVectorsOnChip = beamer.beamer2chip_angle_transfer_function( barDirUnique);
plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(1,:),'line_style','k');hold on
plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(2,:),'line_style','r');
titleName = sprintf('RGC Response Moving Bars (%s)',neur.msmb.clusterName)
title(titleName)
legend({'OFF';'ON'});
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('%s_moving_bars_polar', neurFileName);
save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
save.save_plot_to_file(dirNameFig, fileNameFig,'eps');

%% analyze marching square vertical (adjusted for microscope optical transfer ...
% function)

load ~/Matlab/settings/stimFrameInfo_marchingSqr.mat
plotTimeRangeSec = [-0.5 2.5];

siz = size(stimFrameInfo.pos);
sqrPosAcross = stimFrameInfo.pos(1:siz(1)/2,2);
sqrPos = unique(sqrPosAcross);
plotPositionUm = sqrPos([1 end]);
startStopTime = plotTimeRangeSec*2e4;
clear peakFR
outputFR = [];
for iPos = 1:length(sqrPos)
    
    selResponseIdx = find(sqrPosAcross == sqrPos(iPos));
    [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
        neur.ms.spikeTrains(selResponseIdx ),startStopTime);
    outputFR(iPos,:) = firingRate;
end
figure, imagesc( plotTimeRangeSec,plotPositionUm,outputFR)
titleName = sprintf('RGC Response Marching Square Vertical (-y direction) (%s)',...
    neur.msmb.clusterName)
title(titleName)
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('%s_marching_sqr_vertical', neurFileName);
save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
save.save_plot_to_file(dirNameFig, fileNameFig,'eps');
%% analyze marching square horizontal (adjusted for microscope optical
% transfer function)

load ~/Matlab/settings/stimFrameInfo_marchingSqr.mat
plotTimeRangeSec = [-0.5 2.5];
siz = size(stimFrameInfo.pos);
sqrPosAcross = stimFrameInfo.pos(siz(1)/2+1:end,1);
sqrPos = unique(sqrPosAcross);
plotPositionUm = sqrPos([1 end]);
startStopTime = plotTimeRangeSec*2e4;
clear peakFR
outputFR = [];
for iPos = 1:length(sqrPos)
    
    selResponseIdx = find(sqrPosAcross == sqrPos(iPos));
    [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
        neur.ms.spikeTrains(selResponseIdx+siz(1)/2 ),startStopTime);
    outputFR(iPos,:) = firingRate;
end
figure, imagesc(plotTimeRangeSec, plotPositionUm,outputFR)
titleName = sprintf('RGC Response Marching Square Horizontal (+y direction) (%s)',...
    neur.msmb.clusterName)
title(titleName)
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
set(gca,'FontSize',14)
dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('%s_marching_sqr_horizontal', neurFileName);
save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
save.save_plot_to_file(dirNameFig, fileNameFig,'eps');


%% save
save(fullfile('../analysed_data/', neurFileName), 'neur');

