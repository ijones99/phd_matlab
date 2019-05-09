function dataOut = plot_rasters(selClus, varargin)

script_load_data

dirNameProf = '../analysed_data/profiles/';

% load idx info
load idxFinalSel

% load stim params
stimFrameInfo = file.load_single_var('settings/',...
    'stimFrameInfo_Moving_Bars_ON_OFF.mat');
plotColor = 'k';
h = [];


offsetsUnique = unique(stimFrameInfo.offset );
rgbsUnique = unique(stimFrameInfo.rgb);
lengthsUnique = unique(stimFrameInfo.length);
widthsUnique = unique(stimFrameInfo.width);
speedsUnique = unique(stimFrameInfo.speed);
anglesUnique = unique(stimFrameInfo.angle);

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'offset')
            offsetsUnique = offsetsUnique(varargin{i+1});
        elseif strcmp( varargin{i}, 'rgb')
            rgbsUnique = rgbsUnique(varargin{i+1});
        elseif strcmp( varargin{i}, 'length')
            lengthsUnique = lengthsUnique(varargin{i+1});
        elseif strcmp( varargin{i}, 'width')
            widthsUnique = widthsUnique(varargin{i+1});
        elseif strcmp( varargin{i}, 'speed')
            speedsUnique = speedsUnique(varargin{i+1});
        elseif strcmp( varargin{i}, 'angle')
            anglesUnique = anglesUnique(varargin{i+1});
        elseif strcmp( varargin{i}, 'color')
            plotColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'fig')
            h = varargin{i+1};
        end
    end
end

if ~isempty(h)
    
    figs.maximize(h);
end


subplotEdges = subplots.find_edge_numbers_for_square_subplot(...
    length(selClus));

% get stim onset timestamps
allStimChsIdx = 1:2:length(stimChangeTs{barsRIdx});

dataOut.meanSpikeCnt = {};
dataOut.stdSpikeCnt = {};
dataOut.meanFR = {};
dataOut.stdFR = {};
meanBLFR = [];

onOffBias = [];

% selClus=selClus(10:20);warning('truncated data')
for i=1:length(selClus)
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf))
    
    for iRgb = 1:length(rgbsUnique)
        for iOffset = 1:length(offsetsUnique)
            for iLength = 1:length(lengthsUnique)
                for iWidth = 1:length(widthsUnique)
                    for iSpeed = 1:length(speedsUnique)
                        for iAngle = 1:length(anglesUnique)
                            % get spiketimes
                            stCurr = neurM(barsRIdx).ts;
                            
                            [idxSel varIdx ] = params.vis_stim.get_param_indices(stimFrameInfo,'rgb',rgbsUnique(iRgb),...
                                'offset',offsetsUnique(iOffset), 'length',lengthsUnique(iLength), 'speed',speedsUnique(iSpeed),...
                                'angle',anglesUnique(iAngle));
                            
                            % create idx raster for data access
                            idxRaster = [allStimChsIdx(varIdx(idxSel))' allStimChsIdx(varIdx(idxSel))'+2];
                            
                            % create idx raster for baseline
                            baselineTime = 0.9;
                            [spikeTrain spikeTrainSeg spikeTrainBL spikeTrainBLSeg] = spiketrains.get_raster_series(stCurr/2e4, ...
                                stimChangeTs{barsRIdx}/2e4, idxRaster,'baseline_sec',baselineTime );
                            title(num2str(selClus(i)));
                             subplot(subplotEdges(1),subplotEdges(2),i), hold on
                             
                            spikeCnt = [];
                            for j =1 :length(spikeTrainSeg)
                                
                                plot.raster2(spikeTrainSeg{j},'offset',j,'height',0.8,'ylim',[0 6],'color',plotColor);
                                
                            end
                            
                           
%                             plot.raster(
                           
                            
                            %                 maxSpikeFR(end+1) = max(spikeFR);
                        end
                        
                    end
                end
            end
            
        end
    end
    
    progress_info(i,length(selClus));
    
end
shg

% add cluster and date info
% dataOut.clus_num = idxFinalSel.keep;
% dataOut.date = get_dir_date;
% dirName =  '../analysed_data/moving_bar_ds';
% mkdir(dirName)
% save(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'), 'dataOut');
% fprintf('dataOut saved.\n')
