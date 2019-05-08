function dataOut = plot_marching_sqr_over_grid_RF_input_spiketrains(...
    spikeTrains, Settings, stimChangeTs, varargin)
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
%         dataOut

doMakePlot = 1;
postSwitchTime_sec = 1;
titleTxt = '';
currDir = '../Figs/marching_sqr';
fontSize = 5;
plotNonAdj = 0;
stimDur = 1;
dataOut = [];
minSpikes = 5;
minRepResponse = 3;



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
            minSpikes= varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_non_adj')
            plotNonAdj = 1;
        elseif strcmp( varargin{i}, 'dataOut')
            dataOut = varargin{i+1};
            
            
        end
    end
end



% make figs
if doMakePlot
    hBr = figure;figs.maximize(hBr);
 
    
    % mkdir
    mkdir(currDir);
end
load settings/stimParams_Marching_Sqr.mat
movementLoc = unique(Settings.XY_LOC_um)';

% num flashing square screens
numStimOn = length(Settings.XY_LOC_um)*Settings.stimulusRepeats;

% empty image mat [9x9x810]
imageMatInit = zeros(size(movementLoc,2),size(movementLoc,2),numStimOn);

% locations for each screen
sqrLocs = repmat(Settings.XY_LOC_um(Settings.RAND_XY_LOC,:),Settings.stimulusRepeats,1);
% imageMatInit represents a frame for all of the stimuli on; image is then
% later weighted with spikecount.
for iFr = 1:numStimOn
    row = find(movementLoc==-sqrLocs(iFr,2));
    col = find(movementLoc==sqrLocs(iFr,1));
    imageMatInit(row,col,iFr) = 1;
end

% duplicate frames for ON and OFF
idx = sort(repmat(1:numStimOn,1,2));
imageMatInit = imageMatInit(:,:,idx);

%
for i=1:length(spikeTrains)
    clusterNums{i}= spikeTrains{i}.clus;
end

keepIdx = 0;
subplotEdgeCnt = subplots.find_edge_numbers_for_square_subplot(length(spikeTrains));

profData = {};
plotCnt = 1;
dataOut.sta = [];
idxKeep = [];
dataOut.clus_idx = 1:length(spikeTrains);
dataOut.clus_no(dataOut.clus_idx ) = clusterNums(dataOut.clus_idx );
    dataOut.on_or_off=[];

for iClus = 1:length(spikeTrains)
    % init
    
    imageMat = imageMatInit;
    % Segmented spike trains
    [segments segmentsAdj]=    spiketrains.segment_spiketrains_v2(spikeTrains{iClus}.ts,stimChangeTs,...
        postSwitchTime_sec,1);
    
    % init matrix [9x9x810]; Starts out as zeros [9x9x810]
    weightedIm = zeros(size(movementLoc,2),size(movementLoc,2),length(segments));
    
    % initialize with 0's
    segCnt = cellfun(@length, segments); % idx for segments with non-null values

    dataOut.total_spikes_ON(iClus) = sum(segCnt(1:2:end));
    dataOut.total_spikes_OFF(iClus) = sum(segCnt(2:2:end));
        
    % apply spikecount to frames (to create spike-weighted frames)
    for iSeg = find(segCnt>0)
        weightedIm(:,:,iSeg) = imageMat(:,:,iSeg)*segCnt(iSeg);
    end
    
%     meanImBright = mean(weightedIm(:,:,1:2:end),3);
    meanImBright = [];
    meanImBrightLogical = [];
    for i=1:5 % reps = 5
        meanImBrightReps(:,:,i) = mean(weightedIm(:,:,(i-1)*162+1:2:i*162),3);
        meanImBrightLogical(:,:,i) = double(logical(meanImBrightReps(:,:,i))); % to decide whether to keep clus
    end
    sumMeanBrightLog = sum(meanImBrightLogical,3);
    meanImBright = mean(meanImBrightReps,3);
    profData{iClus}.staImBrightAdj = beamer.beamer2array_xy_adjustment(meanImBright);
    profData{iClus}.staImBright = meanImBright;
%     meanImDark = mean(weightedIm(:,:,2:2:end),3);
    meanImDark = [];
    meanImDarkLogical = [];
    % sum of repetition counts
    for i=1:5
        meanImDarkReps(:,:,i) = mean(weightedIm(:,:,(i-1)*162+2:2:i*162),3);
        meanImDarkLogical(:,:,i) = double(logical(meanImDarkReps(:,:,i)));
    end
    sumMeanDarkLog = sum(meanImDarkLogical,3);
    
    meanImDark = mean(meanImDarkReps,3);
    profData{iClus}.staImDarkAdj= beamer.beamer2array_xy_adjustment(meanImDark);
    profData{iClus}.staImDark = meanImDark;
    profData{iClus}.info.clus_no = clusterNums{iClus};
    
    dataOut.sta(iClus).imONAdj = profData{iClus}.staImBrightAdj;
    dataOut.sta(iClus).imOFFAdj = profData{iClus}.staImDarkAdj;
    
    dataOut.sta(iClus).imON = profData{iClus}.staImBright;
    dataOut.sta(iClus).imOFF = profData{iClus}.staImDark;
    

    % compute ON and OFF ratio
    if mean(cellfun(@length,segmentsAdj(1:2:end))) > mean(cellfun(@length,segmentsAdj(2:2:end)))
        [rowCtr colCtr frCtrIdx ] = mats.max2d(dataOut.sta(iClus).imON);  % find center
        dataOut.on_or_off(iClus) = 1;
    else
        [rowCtr colCtr frCtrIdx ] = mats.max2d(dataOut.sta(iClus).imOFF);  % find center
        dataOut.on_or_off(iClus) = 0;
    end
    %     imagesc(dataOut.sta(iClus).imON+dataOut.sta(iClus).imOFF)
    %     xx = input('enter >> ')
    
    idxSegForCtr = find(imageMat(rowCtr, colCtr,:)==1);
    dataOut.spikecount_at_ctr_ON{iClus} = segmentsAdj(idxSegForCtr(1:2:end))
    dataOut.spikecount_at_ctr_OFF{iClus} = segmentsAdj(idxSegForCtr(2:2:end))
    
    % peak firing rate
    integWinTime_sec = 0.05;
    stimDur  = 1*2e4;
    startStopTime = [0 stimDur];
   
    [dataOut.firing_rate_ON{iClus} edges ] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
        segmentsAdj(idxSegForCtr(1:2:end)),startStopTime,'bin_width', integWinTime_sec*2e4);
    [dataOut.firing_rate_OFF{iClus} edges ] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
        segmentsAdj(idxSegForCtr(2:2:end)),startStopTime,'bin_width', integWinTime_sec*2e4);

    dataOut.firing_rate_edges = edges;
    
    
        
    passedThresh = 0;
    minNumResponses = 3; % out of 5
        
    if or(max(max(sumMeanBrightLog))>= minNumResponses ,max(max(sumMeanDarkLog))>= minNumResponses )
        idxKeep(end+1) = iClus;
        passedThresh = 1;
    end
    
    dataOut.keep(iClus) = passedThresh;
  
    % LATENCY
    if sum(sum(dataOut.firing_rate_ON{iClus}))>0
        repSpikeCnt = cellfun(@length,segmentsAdj(idxSegForCtr(1:2:end)));
        meanSpikeCount = mean(repSpikeCnt);
        
        if meanSpikeCount < minSpikes | length(find(repSpikeCnt==0)) > minRepResponse
             dataOut.latency_ON(iClus) = NaN;
        else
            dataOut.latency_ON(iClus) = response_params_calc.latency_simple(dataOut.firing_rate_ON{iClus}, ...
                edges,'fit_spline', 'first_peak','min_fr', 30, 'show_plot','raster', segmentsAdj(idxSegForCtr(1:2:end))); 
            title(num2str(meanSpikeCount));
%             junk = input('Press enter >> ');
        end
    else
        dataOut.latency_ON(iClus) = NaN;
    end
    if sum(sum(dataOut.firing_rate_OFF{iClus}))>0
        repSpikeCnt = cellfun(@length,segmentsAdj(idxSegForCtr(2:2:end)));
        meanSpikeCount = mean(repSpikeCnt);
       if meanSpikeCount < minSpikes | length(find(repSpikeCnt==0)) > minRepResponse
        dataOut.latency_OFF(iClus) = NaN;
        else
            dataOut.latency_OFF(iClus) = response_params_calc.latency_simple(dataOut.firing_rate_OFF{iClus}, ...
            edges,'fit_spline','first_peak','min_fr', 30, 'show_plot','raster', segmentsAdj(idxSegForCtr(2:2:end)));%, segmentsAdj(idxSegForCtr(2:2:end)) 
            title(num2str(meanSpikeCount));
%             junk = input('Press enter >> ');
        end
    else
        dataOut.latency_OFF(iClus) = NaN;
    end
    
    % TRANSIENCE (uses AUC)
    timeDurSec = 1;
    if sum(sum(dataOut.firing_rate_ON{iClus})) > 0
        dataOut.transience_ON(iClus)  = ...
            response_params_calc.transience_simple(dataOut.firing_rate_ON{iClus}, ...
            edges,timeDurSec);
      
    else
        dataOut.transience_ON(iClus) = NaN;
    end
    if sum(sum(dataOut.firing_rate_OFF{iClus})) > 0
        dataOut.transience_OFF(iClus)  = ...
            response_params_calc.transience_simple(dataOut.firing_rate_OFF{iClus}, ...
            edges,timeDurSec);
    else
        dataOut.transience_OFF(iClus) = NaN;
    end
    
    
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
        
        %         titleText = sprintf('cl idx %d, %d, %d', iClus, dataOut.total_spikes_ON(iClus), dataOut.total_spikes_OFF(iClus) );
        
        dataOut.mean_spike_at_ctr_ON(iClus) = mean( cellfun(@length,dataOut.spikecount_at_ctr_ON{iClus}));
        dataOut.mean_spike_at_ctr_OFF(iClus) = mean( cellfun(@length,dataOut.spikecount_at_ctr_OFF{iClus}));
        titleText = sprintf('%d)%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/',...
            dataOut.clus_no{iClus},[cellfun(@length,dataOut.spikecount_at_ctr_ON{iClus}) ...
            cellfun(@length,dataOut.spikecount_at_ctr_OFF{iClus})]);
        
        text(1,2,titleText, 'Color',[1 1 1],'FontSize', fontSize);
        axis off
        plotCnt = plotCnt+1;
        %         title(sprintf('cl=%d, OFF, maxRF %1.3f', clusterNums(iClus), max(max(profData{iClus}.staImDarkAdj)) ));
        
    end
    
end
% save figs

if doMakePlot
    figure(hBr)
    if plotNonAdj
        fileName = sprintf('RF-for-marching-sqr-ON-and-OFF-nonAdjusted');
    else
        fileName = sprintf('RF-for-marching-sqr-ON-and-OFF-Adjusted');
    end
    fileName = [titleTxt,'-',fileName];
    suptitle(fileName);
    save.save_plot_to_file(currDir, fileName,{'eps', 'fig','pdf'});
    
end
end