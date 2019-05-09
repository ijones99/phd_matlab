function paramOut = compute_params( dataOut)

minNumSpikes = 2;
doPlotSpline = 0;
doPlotFit = 0;

% stim-specific info
settingsInfoTxt = 'stimFrameInfo_Moving_Bars_Length_Test';

% load settings
stimFrameInfo = file.load_single_var('settings/',...
    sprintf('%s.mat', settingsInfoTxt));

% unique values
offsetsUnique = unique(stimFrameInfo.offset );
rgbsUnique = unique(stimFrameInfo.rgb);
lengthsUnique = unique(stimFrameInfo.length);
widthsUnique = unique(stimFrameInfo.width);
speedsUnique = unique(stimFrameInfo.speed);
anglesUnique = unique(stimFrameInfo.angle);

% anglePlotStyle = {'k','r',  'b','c'};
% rgbPlotStyle = {'-', '--'};
% lengthPlotStyle = {'-', '--'};
% legendText = {'OFF', 'ON'};
paramOut = [];
paramOut.info = {};
paramOut.vals =cell(1,4);
paramOut.spline_siz_peak_fr =cell(1,4);
paramOut.wt_avg =cell(1,4);
paramOut.stim_info= cell(1,4);
paramOut.spline_auc_ratio = cell(1,4);
iOffset=1; iWidth = 1; % fixed values


for iRgb = 1:length(rgbsUnique)
    for iLength = 1:length(speedsUnique)
        paramOut.info{end+1} = sprintf('rgb = %d \nspeed = %d',rgbsUnique(iRgb), ...
            speedsUnique(iLength));
        
    end
end



for i=1:length(dataOut.clus_num)
    cellCnt = 1;
    for iRgb = 1:length(rgbsUnique)
        for iSpeed = 1:length(speedsUnique)
            
            % plotStyle = strcat(anglePlotStyle{iRgb}, lengthPlotStyle{iLength});
            %     (iOffset, iRgb, iLength, iWidth, iSpeed, iAngle)
            [J, I] = max(max(dataOut.meanSpikeCnt{i}(iOffset, iRgb, :, iWidth, iSpeed, :),[],3));
            for iAngle = I%1:length(anglesUnique)
                max(squeeze(dataOut.rawMeanSpikeCnt{i}(iOffset, iRgb, iLength, iWidth, :, iAngle)))
                if max(squeeze(dataOut.rawMeanSpikeCnt{i}(iOffset, iRgb, iLength, iWidth, :, iAngle))) > minNumSpikes
                    responseValues = squeeze(dataOut.meanFR{i}(iOffset, iRgb, :, iWidth, iSpeed, iAngle));
                    [cubicFit xValsHiRes cubicCoef,stats,ctr] = ...
                        projects.vis_stim_char.analysis.length_test.fit_curve(...
                        lengthsUnique,responseValues','degree',3);
                    [Y,iMax] = max(cubicFit);
                    paramOut.vals{cellCnt}(end+1) = xValsHiRes(iMax);
                    
                    if doPlotFit
                        plot(lengthsUnique, responseValues,'o','MarkerFaceColor','g'); hold on
                        plot(xValsHiRes, cubicFit*max(responseValues),'r'); hold off
                        pause(viewFitTime);shg
                    end
                    
                    x = lengthsUnique;
                    y = responseValues';
                    
                    cs = spline(x,[y]);
                    xx = linspace(lengthsUnique(1),lengthsUnique(end),501);
                    fittedSpline = ppval(cs,xx);
                    [Y,idxMaxFR] = max(fittedSpline);
                    paramOut.spline_siz_peak_fr{cellCnt}(end+1) = xx(idxMaxFR(1));
                    
                    paramOut.spline_auc_ratio{cellCnt}(end+1) = ...
                        geometry.area.auc(xx, ppval(cs,xx))/ (diff(minmax(xx))*max(ppval(cs,xx)));
                    
                    % weighted mean
                    yOffset = y - min(y);
                    normVals =  yOffset./sum(yOffset);
                    paramOut.wt_avg{cellCnt}(end+1) = sum(x.*normVals);
                    
                    
                    if doPlotSpline
                        clf
                        plot(x,y,'o',xx,ppval(cs,xx),'-r');hold on
                        
                        plot(paramOut.wt_avg{cellCnt}(end)*[1;1],[0;max(y)],'b--')
                        
                        shg, hold off
                        pause(viewFitTime);
                    end
                    
                    % weighted average
                    minmaxVal = minmax(responseValues);
                    paramOut.stim_info{cellCnt}{end+1} = sprintf('rgb = %d; speed = %d', rgbsUnique(iRgb), ...
                        speedsUnique(iLength));
                else
                    warning('insufficient spike number')
                    paramOut.vals{cellCnt}(end+1) = nan;
                    paramOut.spline_siz_peak_fr{cellCnt}(end+1) = nan;
                    
                    paramOut.spline_auc_ratio{cellCnt}(end+1) = nan;
                    paramOut.wt_avg{cellCnt}(end+1)=nan;
                    paramOut.stim_info{cellCnt}{end+1} = sprintf('rgb = %d; speed = %d', rgbsUnique(iRgb), ...
                        speedsUnique(iLength));
                end
                cellCnt = cellCnt+1;
            end
            
        end
        
        progress_info(i, length(dataOut.clus_num));
        
    end
end
    paramOut.clus_num = dataOut.clus_num;
    
    if ~iscell(dataOut.date)
        dataOut.date = {dataOut.date};
    end
    
    paramOut.date = repmat(dataOut.date,1,length(dataOut.clus_num));
    
    dirName =  '../analysed_data/length_test';
    mkdir(dirName)
    save(fullfile('../analysed_data/length_test/param_Length_Test.mat'), 'paramOut');
    fprintf('paramOut saved.\n')
    
    
