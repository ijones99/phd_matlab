% plotting
edgeSize = subplots.find_edge_numbers_for_square_subplot(length(clusNum));
edgeSize = [9 19];
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

meanSpikeCnt = [];
stdSpikeCnt = [];
meanFR = [];
stdFR = [];
meanBLFR = [];

% h1 = figure;
% h2 = figure;
% figs.scale(h1, 100,100);
% figs.scale(h2, 100,100);

h = figure;
figs.scale(h,50,50);

for i=1%:length(clusNum)
    meanSpikeCnt = [];
    meanResponseVec = [];
    stdResponseVec = [];
    
    for iRgb = 1:length(rgbsUnique)
        for iOffset = 1:length(offsetsUnique)
            for iLength = 1:length(lengthsUnique)
                for iSpeed = 1:length(speedsUnique)
                    for iAngle = 1:length(anglesUnique)
                        % get spiketimes
                        stCurr = spiketrains.extract_st_from_R(Rall{barsRIdx, configIdx}, clusNum(i));
                        
                        [idxSel varIdx ] = params.vis_stim.get_param_indices(stimFrameInfo,'rgb',rgbsUnique(iRgb),...
                            'offset',offsetsUnique(iOffset), 'length',lengthsUnique(iLength), 'speed',speedsUnique(iSpeed),...
                            'angle',anglesUnique(iAngle));
                        
                        % create idx raster for data access
                        idxRaster = [allStimChsIdx(varIdx(idxSel))' allStimChsIdx(varIdx(idxSel))'+2];
                        
                        % create idx raster for baseline
                        baselineTime = 0.9;
                        [spikeTrain spikeTrainSeg spikeTrainBL spikeTrainBLSeg] = spiketrains.get_raster_series(stCurr/2e4, ...
                            stimChangeTs{barsRIdx}/2e4, idxRaster,'baseline_sec',baselineTime );
                        
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
                        meanSpikeCnt(iRgb, iOffset, iLength,iSpeed,iAngle ) = mean(spikeCntNorm-spikeCntBLNorm);
                        stdSpikeCnt(iRgb, iOffset, iLength,iSpeed,iAngle) = std(spikeCntNorm-spikeCntBLNorm);
                        
                        meanFR(iRgb, iOffset, iLength,iSpeed,iAngle) = mean(peakFR-meanBLFR);
                        stdFR(iRgb, iOffset, iLength,iSpeed,iAngle) = std(peakFR-meanBLFR);
                        
                        %                 maxSpikeFR(end+1) = max(spikeFR);
                    end
                    
                end
            end
        end
        
        
    end
    plotCnt = 1;
    for iRgb = 1:length(rgbsUnique)
        for iSpeed = 1:length(speedsUnique)
            subplot(2,2,plotCnt), hold on
            for iOffset = 1:length(offsetsUnique)
                errorbar(meanFR(iRgb, iOffset, :, iSpeed, :), stdFR(iRgb, iOffset, :, iSpeed, :),'bo-'),
            end
            plotCnt = plotCnt+1;
            
        end
    end
end




%% plot spatiotemporal size-tuning bars: get tuning plots

% plotting
edgeSize = subplots.find_edge_numbers_for_square_subplot(length(clusNum));
edgeSize = [9 19];
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

meanSpikeCnt = [];
stdSpikeCnt = [];
meanFR = [];
stdFR = [];
meanBLFR = [];

h1 = figure;
h2 = figure;
figs.scale(h1, 100,100);
figs.scale(h2, 100,100);
for i=1:10%length(clusNum)
    meanSpikeCnt = [];
    
    for iRgb = 1:length(rgbsUnique)
        for iOffset = 2%1:length(offsetsUnique)
            for iLength = 1%1:length(lengthsUnique)
                for iSpeed = 1:length(speedsUnique)
                    for iAngle = 1:length(anglesUnique)
                        % get spiketimes
                        stCurr = spiketrains.extract_st_from_R(Rall{barsRIdx, configIdx}, clusNum(i));
                        
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
                        meanSpikeCnt(iAngle, iSpeed) = mean(spikeCntNorm-spikeCntBLNorm);
                        stdSpikeCnt(iAngle, iSpeed) = std(spikeCntNorm-spikeCntBLNorm);
                        
                        meanFR(iAngle, iSpeed) = mean(peakFR-meanBLFR);
                        stdFR(iAngle, iSpeed) = std(peakFR-meanBLFR);
                        
                        
                        %                 maxSpikeFR(end+1) = max(spikeFR);
                    end
                    
                end
            end
        end
        
        
        line(minmax(anglesUnique),[0 0],'Color', [0.5 0.5 .5])
        figure(h1), subplots.subplot_tight(edgeSize(1)+1,edgeSize(2),i+edgeSize(2)), hold on
        
        if iRgb == 1 %off
            
            % errorbar(anglesUnique, meanSpikeCnt(:,1),stdSpikeCnt(:,1), '-o','Color', [0 0 0]);
            errorbar(anglesUnique, meanFR(:,1),stdFR(:,1), '-o','Color', [0 0 0]);
            xlim(minmax(anglesUnique))
        else
            % errorbar(anglesUnique, meanSpikeCnt(:,1),stdSpikeCnt(:,1), '-o','Color', 'r');
            errorbar(anglesUnique, meanFR(:,1),stdFR(:,1), '-o','Color','r');
            xlim(minmax(anglesUnique))
            
        end
        title(sprintf('# %d', clusNum(i)));axis square
        figure(h2), subplots.subplot_tight(edgeSize(1)+1,edgeSize(2),i+edgeSize(2)), hold on
        if iRgb == 1 %off
            
            errorbar(anglesUnique, meanSpikeCnt(:,1),stdSpikeCnt(:,1), '-o','Color', [0 0 0]);
            %             errorbar(anglesUnique, meanFR(:,1),stdFR(:,1), '-o','Color', [0 0 0]);
            xlim(minmax(anglesUnique))
        else
            errorbar(anglesUnique, meanSpikeCnt(:,1),stdSpikeCnt(:,1), '-o','Color', 'r');
            %             errorbar(anglesUnique, meanFR(:,1),stdFR(:,1), '-o','Color','r');
            xlim(minmax(anglesUnique))
            
        end
        title(sprintf('# %d', clusNum(i))); axis square
        %         title(sprintf('Clus %d', clusNum(i)));
        %
        set(gca, 'XTick', []);
        %         set(gca, 'YTick', []);
        
        
    end
end

% tH = suptitle('Spikecount per Direction')
% set(tH, 'FontSize', 20);