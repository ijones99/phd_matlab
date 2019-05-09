function corrIndex = get_corr_index_2(binnedData,binSizeSec, corrLimSec, doPlot)
% function corrIndex = get_corr_index(binnedDataA,binnedDataB,binSizeSec, corrLimSec)

% Meister, 1996 in Proc. Natl. Acad. Sci

if nargin < 4
    doPlot = 0;
end

% cross correlation of binned data
xcf = xcorr2(binnedData);
xcf = mean(xcf,1);
% find area under curve at center
numBinsLim = corrLimSec/binSizeSec; % compute number of bins under which to ...
...compute area. 
ccEdgesMiddle = [-numBinsLim numBinsLim]; % limits around center (lag == 0)

lags = [-length(binnedData)+1:length(binnedData)-1];
ccEdgeMiddleInds = find(ismember(lags,ccEdgesMiddle)); % get indices of edges
areaUnderCurveMiddle = trapz(xcf(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2))); % AUC of the 
...middle section
    
% find area under curve one stimulus period removed
% ccEdgesShiftInds = [length(lags)-10*numBinsLim length(lags)]; % limits one period away from center
% areaUnderCurveShift = trapz(xcf(ccEdgesShiftInds(1):ccEdgesShiftInds(2))) ;% AUC of

meanFiringRate = mean(xcf)

meanFiringRateCurve = meanFiringRate*ones(1,length(xcf));
areaUnderCurveMean = trapz(meanFiringRateCurve(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)));

% divide areas to get correlation Index
corrIndex = areaUnderCurveMiddle/areaUnderCurveMean; 

if doPlot
    figure, plot(lags,xcf), hold on
    area(lags(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)), xcf(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)));
%     area(lags(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)), ...
%         meanFiringRateCurve(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)),'FaceColor','r');
    plot(lags,meanFiringRateCurve,'c--');
end

end