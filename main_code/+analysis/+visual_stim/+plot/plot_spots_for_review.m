function plot_spots_for_review(R, refClusInfo,stimFrameInfo, stimChangeTs,  varargin)
% PLOT_SPOTS_FOR_REVIEW(R, refClusInfo,stimFrameInfo, stimChangeTs)
%
% varargin
%   'idx'
%   'run_no'

idxToPlot=[];
runNo = 1;
doSavePlotToFile = 0;
doWaitAfterEachPlot = 1;
dirName= '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'idx')
            idxToPlot = varargin{i+1};
        elseif strcmp( varargin{i}, 'run_no')
            runNo = varargin{i+1};
        elseif strcmp( varargin{i}, 'save')
            doSavePlotToFile = 1;
        elseif strcmp( varargin{i}, 'dir_name')
            dirName = varargin{i+1};
            
        elseif strcmp( varargin{i}, 'no_wait')
            doWaitAfterEachPlot = 0;
        end
    end
end

if isempty(idxToPlot)
    idxToPlot = 1:length(refClusInfo.clus_no);
end

rasterColor = {'r','k'};

for iClusNo = idxToPlot %$wn.selClusterNums(1:end) % go through all clusters
    
    % plot all cluster responses to one spot
    currRIdx = refClusInfo.R_idx(iClusNo);
    
    % stim changes
    currStimChangeTs = stimChangeTs{currRIdx};
    currStimChangeTsStim = currStimChangeTs(1:2:end);
    
    allDiams = unique(stimFrameInfo.dotDiam);
    subPCnt = 1;
    
    % figure
    h=figure, hold on
    figs.set_size_fig(h,[  641          27        1230         987]);
    rasterSpacing=5;
    for iCurrDiam=1:length(allDiams)
        
        
        for currRgb=[255 0]
            if currRgb==0
                diamIdx = find(stimFrameInfo.dotDiam==allDiams(iCurrDiam) & stimFrameInfo.rgb == 0);
                plotColor=2;
            else
                diamIdx = find(stimFrameInfo.dotDiam==allDiams(iCurrDiam) & stimFrameInfo.rgb> 0);
                plotColor=1;
            end
            
            idxRaster = [diamIdx' diamIdx'+1];
            subplot(length(allDiams),2,subPCnt);
            xlim([0 4])
            
            currClusNo = refClusInfo.clus_no(iClusNo);
            stCurr = spiketrains.extract_st_from_R(R{currRIdx, runNo}, currClusNo);
            offSet = rasterSpacing;
            plot.raster_series(stCurr/2e4, currStimChangeTsStim/2e4, idxRaster,'offset',offSet,'color',rasterColor{plotColor});
%             ylim([-offSet/2 offSet*size(idxRaster,1)/2+offSet/2])
            titleName = {'ON', 'OFF'};
            
            title(sprintf('Stim %s: Clus # %d, Diameter %d', titleName{plotColor}, refClusInfo.clus_no(iClusNo), allDiams(iCurrDiam)));
            subPCnt = subPCnt+1;
        end
    end
    
    if doWaitAfterEachPlot
        a=input('enter >> ');
    end
    
    if doSavePlotToFile
        saveToDir = fullfile('../Figs/',dirName), mkdir(saveToDir);
        fileName = sprintf('spots_%d', refClusInfo.clus_no(iClusNo));
        suptitle(strrep(sprintf('Spot Response for Cluster %s',fileName),'_',' '));
        save.save_plot_to_file(saveToDir, fileName, 'fig'  );
    end
    
    close all
end
end