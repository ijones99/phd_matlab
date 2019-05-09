function dataOut = plot_polars_with_rf_pos_correction(selClus, varargin)
% dataOut = PLOT_RASTERS_WITH_RF_POS_CORRECTION(selClus, varargin)

% data saving dims: (iOffset, iRgb, iLength, iWidth, iSpeed, iAngle)

doMakeSingleWin = 0;


dirNames = projects.vis_stim_char.analysis.load_dir_names;
script_load_data
stimInfoName = 'stimFrameInfo_Moving_Bars_ON_OFF';
dirNameProf = '../analysed_data/profiles/';
idxStim = barsRIdx;

% load idx info
load idxFinalSel

% load stim params
stimFrameInfo = file.load_single_var('settings/',stimInfoName);
plotColor = 'k';
h = [];


offsetsUnique = unique(stimFrameInfo.offset );
rgbsUnique = unique(stimFrameInfo.rgb);
lengthsUnique = unique(stimFrameInfo.length);
widthsUnique = unique(stimFrameInfo.width);
speedsUnique = unique(stimFrameInfo.speed);
anglesUnique = unique(stimFrameInfo.angle);
xLim = [];
yLim = [];
selIdx = [];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'rgb')
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
        elseif strcmp( varargin{i}, 'xlim')
            xLim = varargin{i+1};
        elseif strcmp( varargin{i}, 'ylim')
            yLim = varargin{i+1};
        elseif strcmp( varargin{i}, 'single_windows')
            doMakeSingleWin  = 1;
        elseif strcmp( varargin{i}, 'sel_idx')
            selIdx  =  varargin{i+1};
            
        end
    end
end

if ~isempty(h)
    figs.maximize(h);
end

subplotEdges = subplots.find_edge_numbers_for_square_subplot(...
    length(selClus));

% get stim onset timestamps
allStimChsIdx = 1:2:length(stimChangeTs{idxStim});
dataOut.meanSpikeCnt = {};
dataOut.stdSpikeCnt = {};
dataOut.meanFR = {};
dataOut.stdFR = {};
meanBLFR = [];
onOffBias = [];

marchingSqrDataOut = file.load_single_var(dirNames.marching_sqr_over_grid,'dataOut');

% selClus=selClus(10:20);warning('truncated data')
if isempty(selIdx)
    selIdx = 1:length(selClus);
end
for i=selIdx
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf))
    if doMakeSingleWin
        figure, hold on
    else
        subplot(subplotEdges(1),subplotEdges(2),i), hold on
    end
    if ~isempty(xLim)
        xlim(xLim);
    end
    if ~isempty(yLim)
        ylim(yLim);
    end
    iPlotCtr = 1;
    for iSpeed = 1:length(speedsUnique)
        for iRgb = 1:length(rgbsUnique)
            for iLength = 1:length(lengthsUnique)
                for iWidth = 1:length(widthsUnique)
                    % get all spiketimes for this neuron
                    stCurr = neurM(idxStim).ts;
                    
                    % get xy location
                    if marchingSqrDataOut.on_or_off(i)
                        xyLoc = marchingSqrDataOut.ON.RF_ctr_xy(i,:);
                    else
                        xyLoc = marchingSqrDataOut.OFF.RF_ctr_xy(i,:);
                    end
                    
                    % note that "true" angle is inputted, but is converted to the on-screen
                    % "angle," as seen.
                    closestOffset  = projects.vis_stim_char.ds.find_offset_positions_closest_to_point(...
                        anglesUnique, offsetsUnique, xyLoc);
                    
                    for iAngle = 1:length(anglesUnique)
                        
                        
                        % get indices for selected sweeps
                        [idxSel varIdx ] = params.vis_stim.get_param_indices(stimFrameInfo,'rgb',rgbsUnique(iRgb),...
                            'offset',closestOffset(iAngle,2), 'length',lengthsUnique(iLength), 'speed',speedsUnique(iSpeed),...
                            'angle',anglesUnique(iAngle));
                        
                        % create idx raster for data access
                        idxRaster = [allStimChsIdx(varIdx(idxSel))' allStimChsIdx(varIdx(idxSel))'+1];
                        
                        
                        % angle on screen
                        angleScr = psychtoolbox.angle_transfer_function(anglesUnique(iAngle));
                        
                        % get vector for rf ctr
                        meanSwpTime = mean(diff(stimChangeTs{idxStim}(idxRaster)')/2e4);
                        % half-bar offset dist
                        halfBarD = 0.5*lengthsUnique(iLength);
                        halfBarLoc = geometry.angle2xy(angleScr, halfBarD);
                        BarMovementLoc = geometry.angle2xy(angleScr, 0.5*meanSwpTime*speedsUnique(iSpeed));
                        
                        dEffectiveLoc = halfBarLoc + xyLoc+BarMovementLoc;
                        
                        fprintf('halfBarLoc %d + xyLoc %d +BarMovementLoc %d\n', halfBarLoc , xyLoc,BarMovementLoc);
                        
                        timeOffset = geometry.get_distance_between_2_points(dEffectiveLoc(1), dEffectiveLoc(2))/speedsUnique(iSpeed);
                        fprintf('angle input: %d\n', anglesUnique(iAngle));
                        fprintf('scr angle: %d\n', angleScr);
                        fprintf('t offset: %0.1f\n',timeOffset );
                        fprintf('xyloc: %d %d\n',xyLoc(1), xyLoc(2));
                        fprintf('~~~~~~~~~~~~~~~~~~~~~~~~\n',xyLoc(1), xyLoc(2));
                        
                        
                        
                        % create idx raster for baseline
                        baselineTime = 0.9;
                        [spikeTrain spikeTrainSeg spikeTrainBL spikeTrainBLSeg] = spiketrains.get_raster_series(...
                            stCurr/2e4, stimChangeTs{idxStim}/2e4, idxRaster,'baseline_sec',baselineTime );
                        
                        
                        %                         for iSeg = 1:length(spikeTrainSeg)
                        %                             if not(isempty(spikeTrainSeg{iSeg}))
                        %                                 spikeTrainSeg{iSeg} = spikeTrainSeg{iSeg}(find(spikeTrainSeg{iSeg}<=3));
                        %                             end
                        %                         end
                        responseMean(iAngle) = mean(cellfun(@length,spikeTrainSeg));
                        responseStd(iAngle) = std(cellfun(@length,spikeTrainSeg));
                        
                        
                        
                        
                    end
                    if iRgb==1
                        lineStyle = 'k';
                    else
                        lineStyle = 'r';
                    end
                    plot_polar_for_ds(anglesUnique, responseMean,'line_style',lineStyle,'vector_sum');
                    xlim([-1 1]);ylim([-1 1]);
                    plot(0,0,'ok','LineWidth', 2)
                    title(num2str(selClus(i)));
                    figs.xticklabel_off;figs.yticklabel_off
                end
            end
            
        end
        %plot([-4 4], [iPlotCtr+0.5 iPlotCtr+0.5],'c')
        progress_info(i,length(selClus));
    end
    
    axis square
end
shg

% add cluster and date info
% dataOut.clus_num = idxFinalSel.keep;
% dataOut.date = get_dir_date;
% dirName =  '../analysed_data/moving_bar_ds';
% mkdir(dirName)
% save(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'), 'dataOut');
% fprintf('dataOut saved.\n')
