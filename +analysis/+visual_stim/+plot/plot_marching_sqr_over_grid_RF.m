function dataOut = plot_marching_sqr_over_grid_RF(R, Settings, stimChangeTs, varargin)

% compute receptive fields

doMakePlot = 1;
postSwitchTime_sec = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'no_plot')
            doMakePlot = 0;
        elseif strcmp( varargin{i}, 'post_switch_time_sec')
            postSwitchTime_sec = varargin{i+1};
        end
    end
end



% make figs
if doMakePlot
    hBr = figure;figs.maximize(hBr);
    hDk = figure;figs.maximize(hDk);
    
    % mkdir
    currDir = '../Figs/marching_sqr_over_grid';
    mkdir(currDir);
end
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
spikeTrains = spiketrains.extract_st_from_R_to_cell(R,1);

keepIdx = 0;
subplotEdgeCnt = subplots.find_edge_numbers_for_square_subplot(length(spikeTrains));

profData = {};
for iClus = 1:length(spikeTrains)
    
    segments =    spiketrains.segment_spiketrains_v2(spikeTrains{iClus}.ts,stimChangeTs,...
        postSwitchTime_sec,1);
    
    weightedIm = zeros(size(movementLoc,2),size(movementLoc,2),length(segments));
    
    segCnt = [];
    for i=1:length(segments)
        segCnt(i) = length(segments{i});
    end
    
    dataOut.clus_no(iClus) = clusterNums(iClus);
    dataOut.clus_idx(iClus) = iClus;
    dataOut.total_spikes_ON(iClus) = sum(segCnt(1:2:end));
    dataOut.total_spikes_OFF(iClus) = sum(segCnt(2:2:end));
    
    
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
    save.save_plot_to_file(currDir, fileName,{'eps', 'fig'});
    
    
    figure(hDk)
    fileName = 'RF-for-marching-sqr-over-grid-OFF';
    suptitle(fileName);
    save.save_plot_to_file(currDir, fileName,{'eps', 'fig'});
    
end
end