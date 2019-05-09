function dataOut = process_data(selClus)

script_load_data
idxStim = driftingLinearPatternRIdx;

dirNameProf = '../analysed_data/profiles/';

% load idx info
load idxFinalSel

% load stim params
load settings/stimParams_Drifting_Linear_Pattern.mat

% get stim onset timestamps
allStimChsIdx = 1:2:length(stimChangeTs{barsRIdx});

dataOut.meanSpikeCnt = {};
dataOut.stdSpikeCnt = {};
dataOut.meanFR = {};
dataOut.stdFR = {};
meanBLFR = [];

onOffBias = [];

for i=1:length(selClus)
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf))
    for iOffset = 1:length(offsetsUnique)
        for iRgb = 1:length(rgbsUnique)
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
                            dataOut.meanSpikeCnt{i}(iOffset, iRgb, iLength, iWidth, iSpeed, iAngle) = mean(spikeCntNorm-spikeCntBLNorm);
                            dataOut.stdSpikeCnt{i}(iOffset, iRgb, iLength, iWidth, iSpeed, iAngle) = std(spikeCntNorm-spikeCntBLNorm);
                            
                            dataOut.meanFR{i}(iOffset, iRgb, iLength, iWidth, iSpeed, iAngle) = mean(peakFR-meanBLFR);
                            dataOut.stdFR{i}(iOffset, iRgb, iLength, iWidth, iSpeed, iAngle) = std(peakFR-meanBLFR);
                            
                            
                            %                 maxSpikeFR(end+1) = max(spikeFR);
                        end
                        
                    end
                end
            end
            
        end
    end
    
    progress_info(i,length(selClus));
end

% add cluster and date info
dataOut.clus_num = idxFinalSel.keep;
dataOut.date = get_dir_date;
dirName =  '../analysed_data/moving_bar_ds';
mkdir(dirName)
save(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'), 'dataOut');
fprintf('dataOut saved.\n')
