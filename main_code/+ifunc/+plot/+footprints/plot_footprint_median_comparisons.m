function [loopInds indSel] = plot_footprint_median_comparisons(neurNames, stimNames, medianFootprints, ...
    listMatches, electrodePositions, varargin)

P.interactive_feedback = 1;
P.numComparisons = 3;
P.totalNumEls = [];
P.plotMedianPlotArgs =   {'-', 'color', [.0 .0 .0], 'linewidth', 2};
P.selNeurNameInds = [];
P.selNeurNames = [];
P.savePlot = [];
P.keepPlotsOpen = 0;
P.excludeEls = [];
P = mysort.util.parseInputs(P, varargin, 'error');

scrSize = get(0,'ScreenSize');

if ~isempty(P.selNeurNameInds)
    loopInds =  P.selNeurNameInds;
elseif ~isempty(P.selNeurNames)
    loopInds = find(ismember(neurNames{1}(:),P.selNeurNames));
else
    loopInds = 1:size(listMatches,1);
end

if ~isrow(loopInds)
    loopInds = loopInds';
end

for i=loopInds
    
    h = figure; hold on
    set(h,'Position', scrSize)
    for j=1:P.numComparisons
        
        axesHandle = subplot(1,P.numComparisons,j);
        % plot fp from second group
        fpIdx = listMatches(i, j+1);
        selFootprint = medianFootprints{2}{fpIdx};
        P.plotMedianPlotArgs =   {'-', 'color', 'b', 'linewidth', 2};
        ifunc.plot.footprints.plot_footprint_median(selFootprint,...
            electrodePositions,P.totalNumEls,'plotMedianPlotArgs', P.plotMedianPlotArgs, ...
            'axesHandle', axesHandle,'excludeEls',P.excludeEls);
        
        fpIdx1 = listMatches(i, 1);
        selFootprint = medianFootprints{1}{fpIdx1};
        P.plotMedianPlotArgs =   {'-', 'color', 'k', 'linewidth', 2};
        ifunc.plot.footprints.plot_footprint_median(selFootprint,...
            electrodePositions,P.totalNumEls,'plotMedianPlotArgs', P.plotMedianPlotArgs, ...
            'axesHandle', axesHandle, 'excludeEls',P.excludeEls);
        
        titleString = sprintf('%s - %s (%d) vs %s - %s (%d)', ...
            stimNames{1}, neurNames{1}{fpIdx1}, fpIdx1, ... 
            stimNames{2}, neurNames{2}{fpIdx}, fpIdx);
        
        title(titleString,'Interpreter', 'none', ...
            'FontSize', 12)
        

        
    end
    if ~isempty(P.savePlot )
        mkdir(P.savePlot);
        titleString = sprintf('%s - %s (%d) vs %s - %s (%d)', ...
            stimNames{1}, neurNames{1}{fpIdx1}, fpIdx1, ...
            stimNames{2}, neurNames{2}{listMatches(i, 2)}, listMatches(i, 2));
        saveas(h, fullfile(P.savePlot, titleString), 'fig');
    end

    
    if P.interactive_feedback
        mergeInput = input('merge? [i1..i2] or 0 $');
        if sum(mergeInput) > 0
            ifunc.spiketrains.merge_spiketrains_and_save(neurNames{2}(mergeInput), ...
                stimNames{2});
        end
        localIndSel = input('select match [1..3] $')
        indSel(i) = listMatches(i, localIndSel+1);
    end
    
        if ~P.keepPlotsOpen
        close all
    end
end





end