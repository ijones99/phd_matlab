function dataOut = get_rf_size(dataOut)
% function dataOut = GET_RF_SIZE(dataOut)

% Get receptive field size & center

doDebug = 0;

dataOut.RF_size = nan(1, length(dataOut.sta));
dataOut.RF_ctr_xy = nan(length(dataOut.sta),2);
stimRegEdgeLength = 900;
dataOut.ON = [];
dataOut.OFF = [];
errorIdx = [];
for i=1:length(dataOut.keep)
    
    currIdx = i;
    
    try
        % For ON
        [xFitPercent yFitPercent zInterp fitData zInterpMask] = ...
            fit.find_rf_center_by_fitting_gaussian(...
            dataOut.sta(currIdx).imON   ,'mask_size_um',100); % STA as seen on computer screen (not on chip!)
        
        dataOut.ON.RF_interp{currIdx} = zInterp;
        
        % get RF size
        meanRmsVal = mean(rms(zInterp));
        idxAboveRMS = find(zInterp>meanRmsVal*3);
        rfAreaFract = length(idxAboveRMS)/(size(zInterp,1)*size(zInterp,2));
        dataOut.ON.RF_area_um_sqr(currIdx) = round(rfAreaFract*stimRegEdgeLength*stimRegEdgeLength);
        
        % get center location
        interpEdgeLength = size(zInterp,2);
        dataOut.ON.RF_ctr_xy(currIdx,1) = round(fitData.x_coord*stimRegEdgeLength/interpEdgeLength);
        dataOut.ON.RF_ctr_xy(currIdx,2) = round(fitData.y_coord*stimRegEdgeLength/interpEdgeLength);
        dataOut.ON.RF_ctr_xy
        
        if doDebug
            h2 = figure
            imagesc(zInterp), hold on
            junk = input('enter >>');
            zInterpNew = zInterp;
            zInterpNew(idxAboveRMS) = max(max(zInterp));
            imagesc(zInterpNew)
            junk = input('enter >>');
        end
        
        % For OFF
        [xFitPercent yFitPercent zInterp fitData zInterpMask] = ...
            fit.find_rf_center_by_fitting_gaussian(...
            dataOut.sta(currIdx).imOFF   ,'mask_size_um',100);
        
        dataOut.OFF.RF_interp{currIdx} = zInterp;
        
        % get RF size
        meanRmsVal = mean(rms(zInterp));
        idxAboveRMS = find(zInterp>meanRmsVal*3);
        rfAreaFract = length(idxAboveRMS)/(size(zInterp,1)*size(zInterp,2));
        dataOut.OFF.RF_area_um_sqr(currIdx) = round(rfAreaFract*stimRegEdgeLength*stimRegEdgeLength);
        
        % get center location
        interpEdgeLength = size(zInterp,2);
        dataOut.OFF.RF_ctr_xy(currIdx,1) = round(fitData.x_coord*stimRegEdgeLength/interpEdgeLength);
        dataOut.OFF.RF_ctr_xy(currIdx,2) = round(fitData.y_coord*stimRegEdgeLength/interpEdgeLength);
        if doDebug
            h2 = figure
            imagesc(zInterp), hold on
            junk = input('enter >>');
            zInterpNew = zInterp;
            zInterpNew(idxAboveRMS) = max(max(zInterp));
            imagesc(zInterpNew)
            junk = input('enter >>');
        end
        
        if doDebug
            close(h2)
        end
    catch
        errorIdx(end+1) = currIdx;
    end
    
end

% save marchingSqrOverGrid_dataOut dataOut


end