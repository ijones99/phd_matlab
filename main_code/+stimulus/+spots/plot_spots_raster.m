function plot_spots_raster(spotsSettings, spikeTrains, RGB)
% PLOT_SPOTS_RASTER(spotsSettings, spikeTrains, RGB)
%
%%
% constants 
plotInterval = 5;
numReps = (length(spotsSettings.dotDiam)/length(unique(spotsSettings.dotDiam)))/length(unique(spotsSettings.rgb));
dotDiamUnique = unique(spotsSettings.dotDiam);
%
selIdx = find(spotsSettings.rgb == RGB);

[diamsSorted ISpots] = sort(spotsSettings.dotDiam(selIdx));
ISpots = selIdx(ISpots);

iDiam = 1;
for i=1:length(diamsSorted)
    plot.raster(spikeTrains{ISpots(i)}/2e4,'height', 2,'offset', plotInterval*i);
    if i==1
        line([0 plotInterval/2], (plotInterval*i-plotInterval/2)*[1 1]);
    elseif diamsSorted(i-1)~=diamsSorted(i); % change in diameter
        line([0 plotInterval/2], (plotInterval*(i)-plotInterval/2)*[1 1]);
        
        text(-0.2,   plotInterval*(i)-plotInterval/2-numReps*plotInterval/2,  num2str(dotDiamUnique(iDiam)));
        iDiam = iDiam+1;
    elseif i==length(diamsSorted)
        line([0 plotInterval/2], (plotInterval*i+plotInterval/2)*[1 1]);
        text(-0.2,   plotInterval*(i)-plotInterval/2-numReps*plotInterval/2,  num2str(dotDiamUnique(iDiam)));
        iDiam = iDiam+1;
    end
    
end
axis off
xlabel('time (sec)');
ylabel('spot diameter (um)');




end