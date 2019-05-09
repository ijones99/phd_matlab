function plot_raster_in_sel_time_window(frameNum, numFrames, ...
    spikeMat, acqRate, binSize, periFrameTime, frameTimeStamps, plotStyle,plotOffset)

if nargin < 8
    plotOffset = 0;
end

if nargin < 9
    plotStyle = 'k.';
end

spikeMatSelShift = spikeMat-frameTimeStamps(frameNum);

% number repetitions
numReps = size(spikeMatSelShift,1);

% set time range according to frame
seekTimeRange = [-periFrameTime:periFrameTime];

% find inds that are not in time range and set to nan

inds = find(~and(spikeMatSelShift>=seekTimeRange(1),spikeMatSelShift<=seekTimeRange(end)));
spikeMatSelShift(inds) = NaN;


% make x axis values
[rowValInd, colValInd] = find(abs(spikeMatSelShift)>0);
spikeMatSelShiftSel = spikeMatSelShift(:, min(min(colValInd)):max(max(colValInd)));
numCols = max(colValInd)-min(colValInd)+1;
yAxis = repmat([numReps+plotOffset:-1:1+plotOffset]',1,numCols);

%plot
if ~isempty(spikeMatSelShiftSel)
    plot(single(spikeMatSelShiftSel), single(yAxis),plotStyle);
    xlim([-periFrameTime periFrameTime]);
end
end