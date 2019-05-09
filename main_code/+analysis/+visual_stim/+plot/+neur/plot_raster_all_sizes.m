function plot_raster_all_sizes(neur,  varargin)
% PLOT_SPOTS_FOR_REVIEW(R, refClusInfo,stimFrameInfo, stimChangeTs)
%
% varargin
%   'idx'
%   'run_no'


runNo = 1;
doSavePlotToFile = 0;
doWaitAfterEachPlot = 0;
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

rasterColor = {'r','k'};

% stim changes
currStimChangeTs = neur.spt.stim_change_ts;
currStimChangeTsStim = currStimChangeTs(1:2:end);

allDiams = unique(neur.spt.settings.dotDiam);
subPCnt = 1;

rasterSpacing=1;
for iCurrDiam=1:length(allDiams)
    
    
    for currRgb=[255 0]
        if currRgb==0
            diamIdx = find(neur.spt.settings.dotDiam==allDiams(iCurrDiam) & neur.spt.settings.rgb == 0);
            plotColor=2;
        else
            diamIdx = find(neur.spt.settings.dotDiam==allDiams(iCurrDiam) & neur.spt.settings.rgb> 0);
            plotColor=1;
        end
        
        idxRaster = [diamIdx' diamIdx'+2];
        subplot(length(allDiams),2,subPCnt);
        xlim([0 4])
      
        
        offSet = rasterSpacing;
          ylim([0 offSet*length(allDiams)])
        plot.raster_series(neur.spt.st/2e4, neur.spt.stim_change_ts/2e4, ...
            idxRaster,'offset',offSet,'color',rasterColor{plotColor},'height', 0.5);
        %             ylim([-offSet/2 offSet*size(idxRaster,1)/2+offSet/2])
        titleName = {'ON', 'OFF'};
        
        title(sprintf('Stim %s: Clus # %d, Diameter %d', titleName{plotColor}, neur.info.clus_no, allDiams(iCurrDiam)));
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



end