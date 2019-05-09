%% Presentation on 07 May, 2014
% open fig of sta from WN_CHECKERBOARD stim
neur.wn_checkerbrd.clusterName = '6387n19'
open ../Figs/30Apr2014_sta_wn_checkerboard_n_02_clus_6387n19.fig

% open spike struct of s.sort data
load ../analysed_data/T14_29_11_34_wn_checkerbrderboard_n_02/01_Pre_Spikesorting/el_6387.mat

% FOUND: 6387n54

%% preprocess data in batch mode (cluster)



%% s.sort MARCHING SQR, MOVING BARS, SPOTS
% [flistFileNameID flist flistName] = wrapper.proc_and_spikesort_save_data('sel_by_inds', [10 6] )
% 
[flistFileNameID flist flistName] = wrapper.proc_and_spikesort_save_data()
% FOUND: wn_chckrbrd = 6387n54; marching_sqr=n132; moving_bars=n60,
% spots=n22


%% spikesorting

runNo = input('Enter run no >> ');
flistName = sprintf('flist_marching_sqr_n_%02d',runNo);
flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')

sortChoice = input('spikesort? [y/n]','s')
if strcmp(sortChoice,'y')
    fileType = 'mat';
    elNumbers = compare_files_between_dirs(dirNameEl, dirNameCl, fileType, flist)
    selInds = input(sprintf('sel inds of el numbers to sort [1:%d]> ',length(elNumbers)));
    sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_els_in_dir', ...
        elNumbers(selInds))%elNumbers([1:10]+10*(segmentNo-1))); %'sel_els_in_dir',...
%     selEls(end));%'all_in_dir')%;% 'all_in_dir')%); %,
end

%% EXTRACT TIME STAMPS FROM SORTED FILES 
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )
%% LOAD & SAVE FRAMENO INFO
suffixName = input('suffixName = >> ','s');
flistNo = input('flist number '); 
flist = {}; eval(sprintf('flist%s',suffixName));
flistFileNameID = get_flist_file_id(flist{flistNo}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
framenoName = strcat('frameno_', flistFileNameID,'.mat');
if ~exist(fullfile(dirNameFFile,framenoName))
    frameno = get_framenos(flist);
    save(fullfile(dirNameFFile,framenoName),'frameno');
else
    load(fullfile(dirNameFFile,framenoName)); frameInd = single(frameno);
end

%% set all names
runNo = input('Enter run number >>'); 
neurFileName = sprintf('run_%02d_cell_%s', runNo, neur.wn_checkerbrd.clusterName);
neur.msmb.clusterName = '6387n1';
[neur.msmb.elidxCtr  neur.msmb.clusNo] = filenames.parse_cluster_name(neur.msmb.clusterName);
neur.ms.clusterName = '6387n1';
[neur.ms.elidxCtr  neur.ms.clusNo] = filenames.parse_cluster_name(neur.ms.clusterName);
neur.mb.clusterName = '6387n1';
[neur.mb.elidxCtr  neur.mb.clusNo] = filenames.parse_cluster_name(neur.mb.clusterName);
neur.spt.clusterName = '6387n1';
[neur.spt.elidxCtr  neur.spt.clusNo] = filenames.parse_cluster_name(neur.spt.clusterName);

%% get framenos & timestamps for: marching square, moving bars & spots

% marching square & moving bars
neur.msmb.flistName = sprintf('flist_marching_sqr_and_moving_bars_n_%02d',runNo);


[neur.msmb.spikeTrains neur.msmb.stimChangeTs neur.msmb.allTs ] = ...
    spiketrain_analysis.basic.load_spiketimes_and_stim_frameno(...
    neur.msmb.flistName, neur.msmb.elidxCtr, neur.msmb.clusNo);
 neur.msmb.allTs =  neur.msmb.allTs*2e4;

% spots 
neur.spt.flistName = sprintf('flist_spots_n_%02d',runNo);
flist = {}; eval(neur.spt.flistName)
neur.spt.clusNo = 1;
neur.spt.elidxCtr = 6387;
flist = {}; eval(neur.spt.flistName);
for i=1:length(flist)
   fprintf('(%d) %s\n', i, flist{i}); 
end
flistNo = input('flist number ');
junk = input(sprintf('flist = %s. Ok? [Press enter]',flist{flistNo} ));
neur.spt.spikeTrains =[];neur.spt.stimChangeTs =[];neur.spt.allTs =[];
[neur.spt.spikeTrains neur.spt.stimChangeTs neur.spt.allTs ] = ...
    spiketrain_analysis.basic.load_spiketimes_and_stim_frameno(...
    neur.spt.flistName, neur.spt.elidxCtr, neur.spt.clusNo,'flist_no', flistNo);

% marching square: 16 positions, 10 repeats, 2 directions (320 segments)
% moving bars:  get framenos (144 segments)
% spots:  get framenos (60 segments)

%% separate out into stim
% marching sqr
neur.ms.numSegs = 320;
neur.ms.flistName = sprintf('flist_marching_sqr_n_%02d',runNo);
neur.ms.elidxCtr = neur.msmb.elidxCtr;

eval(sprintf('flist = {}; %s;', neur.ms.flistName))
fileSize = h5.get_size_ntk_recording(flist);
stSegs = spiketrains.segment_spiketrains(neur.msmb.allTs,fileSize{1}(1));
neur.ms.allTs = stSegs{1};
% neur.ms.stimChangeTs = neur.msmb.stimChangeTs;
neur.ms.spikeTrains = neur.msmb.spikeTrains(1:neur.ms.numSegs);

% mov bars
neur.mb.numSegs = 144;
neur.mb.allTs = stSegs{2};
neur.mb.spikeTrains = neur.msmb.spikeTrains(neur.ms.numSegs+1:neur.ms.numSegs+neur.mb.numSegs);

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
        selResponseIdx = find(stimFrameInfo.dotDiam == dotDiams(i)&stimFrameInfo.rgb == ...
            dotRGBVal(jRGB) );
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

selResponseIdx = find(stimFrameInfo.dotDiam == dotDiams(diamIdx)&stimFrameInfo.rgb == ...
            dotRGBVal(OFForON) );
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
titleName = sprintf('RGC Response to Preferred %s Spot (%s)', dotBrightness{OFForON},neur.spt.clusterName)
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

%% analyze marching square vertical (adjusted for microscope optical transfer function)

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
titleName = sprintf('RGC Response Marching Square Vertical (-y direction) (%s)',neur.msmb.clusterName)
title(titleName)
figureHandle = gcf;
% set font sizes
set(findall(figureHandle,'type','text'),'fontSize',14)
set(gca,'FontSize',14)
dirNameFig = '../Figs/Visual_Stim/';
fileNameFig = sprintf('%s_marching_sqr_vertical', neurFileName);
save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
save.save_plot_to_file(dirNameFig, fileNameFig,'eps');
%% analyze marching square horizontal (adjusted for microscope optical transfer function)

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
titleName = sprintf('RGC Response Marching Square Horizontal (+y direction) (%s)',neur.msmb.clusterName)
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
