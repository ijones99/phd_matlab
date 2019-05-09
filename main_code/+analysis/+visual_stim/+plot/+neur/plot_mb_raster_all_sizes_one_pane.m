function plot_mb_raster_all_sizes_one_pane(neur1,  varargin)
% 
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

% stim param vars
valRGB = unique(neur1.mb.settings.rgb);
valAngle = unique(neur1.mb.settings.angle); 
angleOnMEA = beamer.beamer2chip_angle_transfer_function(valAngle);
valOffset = neur1.mb.info(:,3)'; % selected offset

% stim changes
currStimChangeTs = neur1.mb.stim_change_ts;
currStimChangeTsStim = currStimChangeTs(1:2:end);

rasterSpacing=1;
for iAngle=1:length(valAngle)
    
    for currRgb=valRGB
        if currRgb==valAngle(1)
            % OFF
            diamIdx = find(neur1.mb.settings.angle==valAngle(iAngle) & neur1.mb.settings.offset == valOffset(iAngle)  & neur1.mb.settings.rgb == 0);
            plotColor=2;
            xAxisOffset = 5;
            rasterSpacingIncr = 0;
            text(-2, rasterSpacing+0.5,num2str(angleOnMEA(iAngle)));
        else % ON
            diamIdx = find(neur1.mb.settings.angle==valAngle(iAngle) & neur1.mb.settings.offset == valOffset(iAngle)  & neur1.mb.settings.rgb > 0);
            plotColor=1;
            xAxisOffset = 0;
             rasterSpacingIncr = length(diamIdx);
        end
        
        idxRaster = [diamIdx' diamIdx'+1];
        xlim([0 10])
        
        plot.raster_series(neur1.mb.st/2e4, currStimChangeTsStim/2e4, ...
            idxRaster,'offset',rasterSpacing,'color',rasterColor{plotColor},'height', 0.5,'x_offset', xAxisOffset);
        titleName = {'ON', 'OFF'};
        
        title(sprintf('Clus # %d', neur1.info.clus_no));
        
        rasterSpacing = rasterSpacing+rasterSpacingIncr;
        line([0 10],(rasterSpacing-0.5)*ones(2,1));
        
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
set(gca,'YTickLabel','')
ylabel('Angle (degrees)')
xlabel('Time (secs)')
end