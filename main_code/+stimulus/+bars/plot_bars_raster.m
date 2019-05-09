function plot_bars_raster(spikeTrainCells, directions)


ylim([ 0 length(spikeTrainCells)*5]),xlim([ 0 4])
for i=1:length(spikeTrainCells)
    if iseven(directions(i))
        plotColor = 'b';
    else
        plotColor = 'k';
    end
    plot.raster(spikeTrainCells{i}/2e4,'height', 2,'offset', 5*i,'color', plotColor);
    if ~iseven(i) %is odd
        text(-0.1,5*i+2.5,num2str(directions(i)),'Color', plotColor)
    end
    
end
axis off
xlabel('time (sec)');
ylabel('spot diameter (um)');



end