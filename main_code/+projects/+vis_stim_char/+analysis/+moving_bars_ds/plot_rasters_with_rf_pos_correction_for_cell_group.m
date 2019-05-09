function dataOut = plot_rasters_with_rf_pos_correction_for_cell_group(currData, varargin)
% dataOut = PLOT_RASTERS_WITH_RF_POS_CORRECTION(selClus, varargin)

stimInfoName = 'stimFrameInfo_Moving_Bars_ON_OFF';

% load stim params
stimFrameInfo = file.load_single_var('settings/',stimInfoName);

offsetsUnique = 1;
rgbsIdx = 1:2;
lengthsIdx = 1;
widthsIdx = 1;
speedsIdx = 1;
anglesIdx = 1:length(unique(stimFrameInfo.angle));

hold on

plotColor = {'k','r'};

xLim = [];
yLim = [];
doSepReps = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'rgb')
            rgbsIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'length')
            lengthsIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'width')
            widthsIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'speed')
            speedsIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'angle')
            anglesIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'color')
            plotColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'fig')
            h = varargin{i+1};
        elseif strcmp( varargin{i}, 'xlim')
            xLim = varargin{i+1};
        elseif strcmp( varargin{i}, 'ylim')
            yLim = varargin{i+1};
        elseif strcmp( varargin{i}, 'separate_reps')
            doSepReps = 1;
        end
    end
end

% selClus=selClus(10:20);warning('truncated data')

if ~isempty(xLim)
    xlim(xLim);
end
if ~isempty(yLim)
    ylim(yLim);
end
iPlotCtr = 1;
for iSpeed = speedsIdx
    for iRgb = rgbsIdx
        for iLength = lengthsIdx
            for iWidth = widthsIdx
                for iAngle = anglesIdx
                    
                    
                    spikeCnt = [];
                    for j =1 :size(currData,7)
                        currRaster = currData{1, iRgb, iLength, iWidth, iSpeed, iAngle,j};
                        plot.raster2(currRaster,'offset',iPlotCtr ,'height',0.8,'ylim',[0 6],'color',plotColor{iRgb});
                        iPlotCtr  = 1+iPlotCtr ;
                    end
                    if doSepReps
                        plot([-4 4], [iPlotCtr iPlotCtr],'k')
                        iPlotCtr  = 1+iPlotCtr ;
                    end
                    
                end
            end
        end
        
    end
    plot([-4 4], [iPlotCtr+0.5 iPlotCtr+0.5],'c')
    
end


