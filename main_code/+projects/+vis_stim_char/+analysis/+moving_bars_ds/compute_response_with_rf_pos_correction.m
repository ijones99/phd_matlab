function dataOut = compute_response_with_rf_pos_correction(selClus, varargin)

dirNames = projects.vis_stim_char.analysis.load_dir_names;
script_load_data
stimInfoName = 'stimFrameInfo_Moving_Bars_ON_OFF';
dirNameProf = '../analysed_data/profiles/';
idxStim = barsRIdx;

% load idx info
load idxFinalSel
load ../analysed_data/moving_bar_ds/dataOut.mat

% load stim params
stimFrameInfo = file.load_single_var('settings/',stimInfoName);
plotColor = 'k';

offsetsUnique = unique(stimFrameInfo.offset );
rgbsUnique = unique(stimFrameInfo.rgb);
lengthsUnique = unique(stimFrameInfo.length);
widthsUnique = unique(stimFrameInfo.width);
speedsUnique = unique(stimFrameInfo.speed);
anglesUnique = unique(stimFrameInfo.angle);

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
        end
    end
end

% get stim onset timestamps
allStimChsIdx = 1:2:length(stimChangeTs{idxStim});

marchingSqrDataOut = file.load_single_var(dirNames.marching_sqr_over_grid,'dataOut');
dataOut.on_max_fr = nan(length(selClus),length(anglesUnique));
dataOut.off_max_fr = nan(length(selClus),length(anglesUnique));

% selClus=selClus(10:20);warning('truncated data')
for i=1:length(selClus)
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf));
    currParamData = []; 
    currParamData.on_fr = [];
    currParamData.off_fr = [];
    currParamData.on_cnt = [];
    currParamData.off_cnt = [];
    
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
                            
                            sweepDur_samp = mode(diff(stimChangeTs{idxStim}(idxRaster')/2e4));
                            startStopTime = [-sweepDur_samp/2 0];
                            integWinTime_sec = 0.05;
                            [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
                                spikeTrainSeg,startStopTime*2e4,'bin_width', integWinTime_sec*2e4,...
                                'scale_data',2e4,'shift_data',-timeOffset*2e4 );
                            if iRgb == 2
                                currParamData.on_fr(iAngle) = max(firingRate);

                            else
                                currParamData.off_fr(iAngle) = max(firingRate);
                            end
                    end
                end
            end
            
        end
        dataOut.on_max_fr(i,:) = currParamData.on_fr;
        dataOut.off_max_fr(i,:) = currParamData.off_fr;
        progress_info(i,length(selClus));
     end
     
     
end


% add cluster and date info
% dataOut.clus_num = idxFinalSel.keep;
% dataOut.date = get_dir_date;
% dirName =  '../analysed_data/moving_bar_ds';
% mkdir(dirName)
save(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'), 'dataOut');
fprintf('dataOut saved.\n')

% dirName =  '../analysed_data/moving_bar_ds';
% mkdir(dirName)
% save(fullfile('../analysed_data/moving_bar_ds/param_DSIndex.mat'), 'paramOut');
% fprintf('paramOut saved.\n')
