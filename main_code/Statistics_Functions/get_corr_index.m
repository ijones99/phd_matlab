function corrIndex = get_corr_index(binnedDataA,binnedDataB,binSizeSec, corrLimSec, doPlot)
% function corrIndex = get_corr_index(binnedDataA,binnedDataB,binSizeSec, corrLimSec)

% Meister, 1996 in Proc. Natl. Acad. Sci

if nargin < 5
    doPlot = 0;
end

% cross correlation of binned data
[xcf,lags,bounds] = crosscorr(binnedDataA, binnedDataB,length(min(binnedDataA,binnedDataB))-1);
xcf(find(xcf<0))=0;
% find area under curve at center
numBinsLim = corrLimSec/binSizeSec; % compute number of bins under which to ...
...compute area. 
ccEdgesMiddle = [-numBinsLim numBinsLim]; % limits around center (lag == 0)
ccEdgeMiddleInds = find(ismember(lags,ccEdgesMiddle)); % get indices of edges
areaUnderCurveMiddle = trapz(xcf(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2))); % AUC of the 
...middle section
    
% find area under curve one stimulus period removed
% ccEdgesShiftInds = [length(lags)-10*numBinsLim length(lags)]; % limits one period away from center
% areaUnderCurveShift = trapz(xcf(ccEdgesShiftInds(1):ccEdgesShiftInds(2))) ;% AUC of

meanFiringRate = mean(xcf);

meanFiringRateCurve = meanFiringRate*ones(1,length(xcf));
areaUnderCurveMean = trapz(meanFiringRateCurve(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)));

% divide areas to get correlation Index
corrIndex = areaUnderCurveMiddle/areaUnderCurveMean; 

if doPlot
    figure, plot(lags,xcf), hold on
    area(lags(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)), xcf(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)));
    area(lags(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)), ...
        meanFiringRateCurve(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)),'FaceColor','r');
    plot(lags,meanFiringRateCurve,'c--');
    ylim([-0.3 1]);
end

end