function corrIndex = get_corr_index_meister96(binnedData,binSizeSec, middleLength, doPlot)
% function corrIndex = get_corr_index(binnedDataA,binnedDataB,binSizeSec, corrLimSec)

% Meister, 1996 in Proc. Natl. Acad. Sci

if nargin < 4
    doPlot = 0;
end
lags = size(binnedData,2);
xAxisVals = -lags:lags;
% cross correlation of binned data
xcf= xcorr4stim_repeats(binnedData,0,lags);

xcf(find(xcf<0))=0;
% find area under curve at center
numBinsLim = middleLength/binSizeSec; % compute number of bins under which to ...
...compute area. 
ccEdgesMiddle = [-numBinsLim numBinsLim]; % limits around center (lag == 0)
ccMiddleInds = find(ismember(xAxisVals,ccEdgesMiddle)); % get indices of edges
areaUnderCurveMiddle = trapz(xcf(ccMiddleInds(1):ccMiddleInds(2))); % AUC of the 
...middle section

% indices of surrounding area
ccSurroundInds = 1:length(xAxisVals); ccSurroundInds(ccMiddleInds) = [];

% mean firing rate (not including middle)
meanFiringRate = mean(xcf(ccSurroundInds));

meanFiringRateCurve = meanFiringRate*ones(1,length(xcf));
areaUnderCurveMean = trapz(meanFiringRateCurve(ccMiddleInds(1):ccMiddleInds(2)));

% divide areas to get correlation Index
corrIndex = areaUnderCurveMiddle/areaUnderCurveMean; 

if doPlot
    figure, plot(xAxisVals,xcf), hold on
    area(xAxisVals(ccMiddleInds(1):ccMiddleInds(2)), xcf(ccMiddleInds(1):ccMiddleInds(2)));
    area(xAxisVals(ccMiddleInds(1):ccMiddleInds(2)), ...
        meanFiringRateCurve(ccMiddleInds(1):ccMiddleInds(2)),'FaceColor','r');
    plot(xAxisVals,meanFiringRateCurve,'k--');
end

end