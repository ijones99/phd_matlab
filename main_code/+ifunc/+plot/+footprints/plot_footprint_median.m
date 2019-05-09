function plot_footprint_median(footprintMedian, electrodePositions,totalNumEls, varargin)
% function plot_footprint_median(footprintMedian,electrodePositions, totalNumEls,varargin)
% P.fontSize = 10;
% P.axesHandle = [];
% P.excludeEls = [14 116 80 82 11 10 85 8 7 64];
% P.includeEls = [];
% footprintMedian = ex. data.White_Noise.footprint_median
% footprintMedian is usually hdmea.MultiElectrode.electrodePositions

P.fontSize = 10;
P.axesHandle = [];
P.excludeEls = [];
P.includeEls = [];
P.plotMedianPlotArgs =   {'-', 'color', [.0 .0 .0], 'linewidth', 2};
P = mysort.util.parseInputs(P, varargin, 'error');

allEls = 1:totalNumEls;
allElsToPlot = 1:totalNumEls;

if ~isempty(P.excludeEls)
    allElsToPlot(P.excludeEls) = [];
elseif ~isempty(P.includeEls)
    allElsToPlot = P.includeEls;
else
    fprintf('Error.\n');
end


if ~isempty(P.axesHandle)
ifunc.plot.footprints.waveforms2D(footprintMedian, electrodePositions,...
    'plotMedian', 1,...
    'maxWaveforms', 5000, ...
    'plotElNumbers', allEls, ...%         'plotHorizontal', idxMaxAmp, ...
    'plotSelIdx', allElsToPlot,'AxesHandle',P.axesHandle, ...
    'fontSize', P.fontSize, 'plotMedianPlotArgs', P.plotMedianPlotArgs);
else
    ifunc.plot.footprints.waveforms2D(footprintMedian, electrodePositions,...
    'plotMedian', 1,...
    'maxWaveforms', 5000, ...
    'plotElNumbers', allEls, ...%         'plotHorizontal', idxMaxAmp, ...
    'plotSelIdx', allElsToPlot,...
    'fontSize', P.fontSize,'plotMedianPlotArgs',P.plotMedianPlotArgs);
    
end

end