function corrIndex = get_corr_index_4(binnedData,binSizeSec, lagTimeSec, doPlot)
% function corrIndex = get_corr_index(binnedDataA,binnedDataB,binSizeSec, corrLimSec)

% Meister, 1996 in Proc. Natl. Acad. Sci

if nargin < 5
    doPlot = 0;
end

% number lags
numLags = lagTimeSec/binSizeSec;

% cross correlation of binned data
xcf = zeros(length(1:2:size(binnedData,1))-1,numLags*2+1);
j = 1;
for i=1:2:size(binnedData,1)-1

    [xcf(j,:),lags,bounds] = crosscorr(binnedData(i,:), binnedData(i+1,:),numLags);
    j=j+1;
end

xcfMean = mean(xcf,1);


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