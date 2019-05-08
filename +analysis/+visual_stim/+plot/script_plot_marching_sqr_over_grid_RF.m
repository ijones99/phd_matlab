%% load data
flist={}; flist_marching_sqr_over_grid_n_01
load('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/marching_sqr_over_grid_during_exp/25Nov2014_resultsForIan.mat');
frameno = get_framenos(flist)
save('frameno_marching_sqr_over_grid','frameno')
load settings/stimParams_Marching_Sqr_over_Grid.mat
%% compute receptive fields
doMakePlot = 1;
doSavePlotToFile = 0;

% make figs
hBr = figure;figs.maximize(hBr);
hDk = figure;figs.maximize(hDk);

% mkdir
currDir = '../Figs/marching_sqr_over_grid';
mkdir(currDir);

movementLoc = unique(Settings.XY_LOC_um)';

% num flashing square screens
numStimOn = length(Settings.XY_LOC_um)*Settings.stimulusRepeats;

% empty image mat
imageMat = zeros(size(movementLoc,2),size(movementLoc,2),numStimOn);

% locations for each screen
sqrLocs = repmat(Settings.XY_LOC_um(Settings.RAND_XY_LOC,:),Settings.stimulusRepeats,1);
% figure
for iFr = 1:numStimOn
    currIm = zeros(size(movementLoc,2),size(movementLoc,2));
    row = find(movementLoc==sqrLocs(iFr,2));
    col = find(movementLoc==sqrLocs(iFr,1));
    imageMat(row,col,iFr) = 1;
    
end

% duplicate frames for ON and OFF
idx = sort(repmat(1:numStimOn,1,2));
imageMat = imageMat(:,:,idx);

%
clusterNums = unique(R{1}(:,1));
spikeTrains = spiketrains.extract_st_from_R_to_cell(R,1);

interStimTime=0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno{1},interStimTime);
keepIdx = 0;
subplotEdgeCnt = subplots.find_edge_numbers_for_square_subplot(length(spikeTrains));

profData = {};
for iClus = 1:length(spikeTrains)
    
    segments =    spiketrains.segment_spiketrains_v2(spikeTrains{iClus}.ts,stimChangeTs,...
        'post_switch_time_sec',1);
     
    weightedIm = zeros(size(movementLoc,2),size(movementLoc,2),length(segments));
    
    segCnt = [];
    for i=1:length(segments)
        segCnt(i) = length(segments{i});
    end
    
    for iSeg = 1:length(segCnt)
        weightedIm(:,:,iSeg) = imageMat(:,:,iSeg)*segCnt(iSeg);
    end
    
    meanImBright = mean(weightedIm(:,:,1:2:end),3);
    profData{iClus}.staImBrightAdj = beamer.beamer2array_xy_adjustment(meanImBright);
    meanImDark = mean(weightedIm(:,:,2:2:end),3);
    profData{iClus}.staImDarkAdj= beamer.beamer2array_xy_adjustment(meanImDark);
    profData{iClus}.info.clus_no = clusterNums(iClus);
    
    if doMakePlot
        figure(hBr)
        subplot(subplotEdgeCnt(1),subplotEdgeCnt(2),iClus);
        imagesc( profData{iClus}.staImBrightAdj), colormap gray, axis equal
        title(sprintf('cl=%d, ON, maxRF %1.3f', clusterNums(iClus), max(max(profData{iClus}.staImBrightAdj)) ));
        
        figure(hDk)
        subplot(subplotEdgeCnt(1),subplotEdgeCnt(2),iClus);
        imagesc(profData{iClus}.staImDarkAdj), colormap gray, axis equal
        title(sprintf('cl=%d, OFF, maxRF %1.3f', clusterNums(iClus), max(max(profData{iClus}.staImDarkAdj)) ));
    end
end
% save figs

if doMakePlot
    figure(hBr)
    fileName = 'RF-for-marching-sqr-over-grid-ON';
    suptitle(fileName);
    if doSavePlotToFile
        save.save_plot_to_file(currDir, fileName,{'eps', 'fig'});
    end
    
    figure(hDk)
    fileName = 'RF-for-marching-sqr-over-grid-OFF';
    suptitle(fileName);
    if doSavePlotToFile 
        save.save_plot_to_file(currDir, fileName,{'eps', 'fig'});
    end
    
end
