function plot_marching_sqr_over_grid_RF_individual_clusters(R, clusNoInput, stimChangeTs, Settings)

%% compute receptive fields

if iscell(R)
    Rnew = R{1};
    clear R;
    R = Rnew;
    clear Rnew;
end


doMakePlot = 1;

% make figs
hBr = figure;figs.maximize(hBr);
hDk = figure;figs.maximize(hDk);

% mkdirs
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
clusterNums = unique(R(:,1));

plotIdx = find(ismember(clusterNums, clusNoInput));

spikeTrains = spiketrains.extract_st_from_R_to_cell(R,1);

keepIdx = 0;
subplotEdgeCnt = subplots.find_edge_numbers_for_square_subplot(length(spikeTrains));

profData = {};
for iClus = 1:length(plotIdx)
    
    segments =    spiketrains.segment_spiketrains_v2(spikeTrains{plotIdx(iClus)}.ts,stimChangeTs,...
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
    profData{plotIdx(iClus)}.staImBrightAdj = beamer.beamer2array_xy_adjustment(meanImBright);
    meanImDark = mean(weightedIm(:,:,2:2:end),3);
    profData{plotIdx(iClus)}.staImDarkAdj= beamer.beamer2array_xy_adjustment(meanImDark);
    profData{plotIdx(iClus)}.info.clus_no = clusterNums(plotIdx(iClus));
    
    if doMakePlot
        figure(hBr)
        subplot(subplotEdgeCnt(1),subplotEdgeCnt(2),plotIdx(iClus));
        imagesc( profData{plotIdx(iClus)}.staImBrightAdj), colormap gray, axis equal
        title(sprintf('cl=%d, ON, maxRF %1.3f', clusterNums(plotIdx(iClus)), max(max(profData{plotIdx(iClus)}.staImBrightAdj)) ));
        
        figure(hDk)
        subplot(subplotEdgeCnt(1),subplotEdgeCnt(2),plotIdx(iClus));
        imagesc(profData{plotIdx(iClus)}.staImDarkAdj), colormap gray, axis equal
        title(sprintf('cl=%d, OFF, maxRF %1.3f', clusterNums(plotIdx(iClus)), max(max(profData{plotIdx(iClus)}.staImDarkAdj)) ));
    end
end
% save figs

if doMakePlot
    figure(hBr)
    fileName = 'RF-for-marching-sqr-over-grid-ON';
    suptitle(fileName);
    save.save_plot_to_file(currDir, fileName,{'eps', 'fig'});
    
    
    figure(hDk)
    fileName = 'RF-for-marching-sqr-over-grid-OFF';
    suptitle(fileName);
    save.save_plot_to_file(currDir, fileName,{'eps', 'fig'});
    
end

end