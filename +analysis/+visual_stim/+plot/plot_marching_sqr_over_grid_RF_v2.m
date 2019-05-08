function dataOut = plot_marching_sqr_over_grid_RF_v2(R, Settings, stimChangeTs, varargin)
% dataOut = PLOT_MARCHING_SQR_OVER_GRID_RF_V2(R, Settings, stimChangeTs, varargin)
%
% compute receptive fields
%
% note: v2 combines on and off responses
%
% varargin:
%         'no_plot'
%         'post_switch_time_sec'
%         'title'
%         'dir'
%         'font_size'
%         'min_spike_count'
%         'plot_non_adj'


doMakePlot = 1;
postSwitchTime_sec = 1;
titleTxt = '';
currDir = '../Figs/marching_sqr_over_grid';
fontSize = 5;
minNumSpikes = 15;
plotNonAdj = 0;


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'no_plot')
            doMakePlot = 0;
        elseif strcmp( varargin{i}, 'post_switch_time_sec')
            postSwitchTime_sec = varargin{i+1};
        elseif strcmp( varargin{i}, 'title')
            titleTxt  = varargin{i+1};
        elseif strcmp( varargin{i}, 'dir')
            currDir = varargin{i+1};
        elseif strcmp( varargin{i}, 'font_size')
            fontSize= varargin{i+1};
        elseif strcmp( varargin{i}, 'min_spike_count')
            minNumSpikes= varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_non_adj')
            plotNonAdj = 1;
            
            
        end
    end
end



% make figs
if doMakePlot
    hBr = figure;figs.maximize(hBr);
 
    
    % mkdir
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
plotCnt = 1;
dataOut.sta = [];
idxKeep = [];
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
    
%     meanImBright = mean(weightedIm(:,:,1:2:end),3);
    meanImBright = [];
    meanImBrightLogical = [];
    for i=1:5
        meanImBright(:,:,i) = mean(weightedIm(:,:,(i-1)*162+1:2:i*162),3);
        meanImBrightLogical(:,:,i) = double(logical(meanImBright(:,:,i)));
    end
    sumMeanBrightLog = sum(meanImBrightLogical,3);
    meanImBright = mean(meanImBright,3);
    profData{iClus}.staImBrightAdj = beamer.beamer2array_xy_adjustment(meanImBright);
    profData{iClus}.staImBright = meanImBright;
%     meanImDark = mean(weightedIm(:,:,2:2:end),3);
    meanImDark = [];
    meanImDarkLogical = [];
    for i=1:5
        meanImDark(:,:,i) = mean(weightedIm(:,:,(i-1)*162+1:1:i*162),3);
        meanImDarkLogical(:,:,i) = double(logical(meanImDark(:,:,i)));
    end
    sumMeanDarkLog = sum(meanImDarkLogical,3);
    
    meanImDark = mean(meanImDark,3);
    profData{iClus}.staImDarkAdj= beamer.beamer2array_xy_adjustment(meanImDark);
    profData{iClus}.staImDark = meanImDark;
    profData{iClus}.info.clus_no = clusterNums(iClus);
    
    dataOut.sta(iClus).imONAdj = profData{iClus}.staImBrightAdj;
    dataOut.sta(iClus).imOFFAdj = profData{iClus}.staImDarkAdj;
    
    dataOut.sta(iClus).imON = profData{iClus}.staImBright;
    dataOut.sta(iClus).imOFF = profData{iClus}.staImDark;
    
    %     if doMakePlot && dataOut.total_spikes_ON(iClus)+dataOut.total_spikes_OFF(iClus) > minNumSpikes
    
    passedThresh = 0;
    minNumResponses = 3;
    
    if or(max(max(sumMeanBrightLog))>= minNumResponses ,max(max(sumMeanDarkLog))>= minNumResponses )
        idxKeep(end+1) = iClus;
        passedThresh = 1;
    end
    
    dataOut.keep(iClus) = passedThresh;
    
    if doMakePlot && passedThresh 
        figure(hBr)
        subplots.subplot_tight(subplotEdgeCnt(1)+1,subplotEdgeCnt(2),plotCnt+subplotEdgeCnt(2));
        if plotNonAdj
            onOffIm = [profData{iClus}.staImBright profData{iClus}.staImDark];
        else
            onOffIm = [profData{iClus}.staImBrightAdj profData{iClus}.staImDarkAdj];
        end
        imSize = size(onOffIm ,1);
        imagesc( onOffIm ), colormap gray, axis equal, hold on
        plot([imSize+0.5 imSize+.5],[0.5 imSize+.5],'Color',[1 1 1 ]);
        text(1,2,sprintf('cl%d, %d, %d', clusterNums(iClus), dataOut.total_spikes_ON(iClus), dataOut.total_spikes_OFF(iClus) ),...
            'Color',[1 1 1],'FontSize', fontSize);
        axis off
       plotCnt = plotCnt+1;
%         title(sprintf('cl=%d, OFF, maxRF %1.3f', clusterNums(iClus), max(max(profData{iClus}.staImDarkAdj)) ));
    end
    
end
% save figs

if doMakePlot
    figure(hBr)
    if plotNonAdj
        fileName = sprintf('RF-for-marching-sqr-over-grid-ON-and-OFF-nonAdjusted');
    else
        fileName = sprintf('RF-for-marching-sqr-over-grid-ON-and-OFF-Adjusted');
    end
    fileName = [titleTxt,'-',fileName];
    suptitle(fileName);
    save.save_plot_to_file(currDir, fileName,{'eps', 'fig'});
    
    
  
    
end
end