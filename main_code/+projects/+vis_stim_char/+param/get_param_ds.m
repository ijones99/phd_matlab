function paramDS = get_param_ds

paramDS = [];

dirNameProf = '../analysed_data/profiles/';

% load idx info
load idxFinalSel
load dataOut

% plotting
edgeSize = subplots.find_edge_numbers_for_square_subplot(length(clusNum));
edgeSize = [9 9];
% load stim params
stimFrameInfo = file.load_single_var('settings/',...
    'stimFrameInfo_Moving_Bars_ON_OFF.mat');

offsetsUnique = unique(stimFrameInfo.offset );
rgbsUnique = unique(stimFrameInfo.rgb);
lengthsUnique = unique(stimFrameInfo.length);
speedsUnique = unique(stimFrameInfo.speed);
anglesUnique = unique(stimFrameInfo.angle);

% get stim onset timestamps
allStimChsIdx = 1:2:length(stimChangeTs{barsRIdx});

meanSpikeCnt = {};
stdSpikeCnt = {};
meanFR = {};
stdFR = {};
meanBLFR = [];

selClus = idxFinalSel.keep;

onOffBias = [];

for i=1:length(selClus)
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf))
    
    % select location of either on or off cells.
    if dataOut.total_spikes_ON(i) > dataOut.total_spikes_OFF(i)
        onOffBias(i) = 2;
        rfCtrLocRel = dataOut.ON.RF_ctr_xy(i,:);
    else
        onOffBias(i) = 1;
        rfCtrLocRel = dataOut.OFF.RF_ctr_xy(i,:);
    end
    
    closestOffset  = projects.vis_stim_char.ds.find_offset_positions_closest_to_point(...
        anglesUnique, offsetsUnique, rfCtrLocRel);
    
    for iRgb = 1:length(rgbsUnique)
        for iOffset = 1%:length(offsetsUnique)
            for iLength = 1:length(lengthsUnique)
                for iSpeed = 1:length(speedsUnique)
                    for iAngle = 1:length(anglesUnique)
                        % get spiketimes
                        stCurr = spiketrains.extract_st_from_R(Rall{barsRIdx, configIdx}, clusNum(i));
                        iOffset = closestOffset(iAngle,3);
                        [idxSel varIdx ] = params.vis_stim.get_param_indices(stimFrameInfo,'rgb',rgbsUnique(iRgb),...
                            'offset',offsetsUnique(iOffset), 'length',lengthsUnique(iLength), 'speed',speedsUnique(iSpeed),...
                            'angle',anglesUnique(iAngle));
                        
                        % create idx raster for data access
                        idxRaster = [allStimChsIdx(varIdx(idxSel))' allStimChsIdx(varIdx(idxSel))'+2];
                        
                        % create idx raster for baseline
                        baselineTime = 0.9;
                        [spikeTrain spikeTrainSeg spikeTrainBL spikeTrainBLSeg] = spiketrains.get_raster_series(stCurr/2e4, ...
                            stimChangeTs{barsRIdx}/2e4, idxRaster,'baseline_sec',baselineTime );
                        
                        
                        spikeCnt = [];
                        for j =1 :length(spikeTrain)
                            
                            sweepDur_samp = diff(stimChangeTs{barsRIdx}(idxRaster(1,:)));
                            
                            % spike count
                            spikeCntNorm(j) = length(spikeTrain{j})/(sweepDur_samp/2e4);
                            spikeCntBLNorm(j) = length(spikeTrainBL{j})/baselineTime ;
                            
                            % peak firing rate
                            integWinTime_sec = 0.05;
                            startStopTime = [0 sweepDur_samp];
                            [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
                                spikeTrainSeg{j}*2e4,startStopTime,'bin_width', integWinTime_sec*2e4);
                            %                         plot(edges, firingRate,'c' )
                            startStopTime = [0 baselineTime ]*2e4;
                            [firingRateBL edgesBL] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
                                spikeTrainBLSeg{j}*2e4,startStopTime,'bin_width', integWinTime_sec*2e4);
                            
                            peakFR(j) = max(firingRate);
                            meanBLFR(j) = mean(firingRateBL);
                            
                        end
                        
                        
                        %
                        meanSpikeCnt{i}(1, iRgb, iLength, iWidth, iSpeed, iAngle) = mean(spikeCntNorm-spikeCntBLNorm);
                        stdSpikeCnt{i}(1, iRgb, iLength, iWidth, iSpeed, iAngle) = std(spikeCntNorm-spikeCntBLNorm);
                        
                        meanFR{i}(1, iRgb, iLength, iWidth, iSpeed, iAngle) = mean(peakFR-meanBLFR);
                        stdFR{i}(1, iRgb, iLength, iWidth, iSpeed, iAngle) = std(peakFR-meanBLFR);
                        
                        
                        %                 maxSpikeFR(end+1) = max(spikeFR);
                    end
                    
                end
            end
        end
        
    end
    
    for iRes = 1:length(closestOffset)
        selRGB = 2;
        selSpeed = 1;
        responseSel(iRes) = squeeze(meanFR{i}(1,...
            selRGB, :, :, selSpeed, iRes));
    end
    paramDS(i) = response_params_calc.ds(anglesUnique, responseSel)
    progress_info(i,length(clusNum));
end

end