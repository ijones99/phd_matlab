% binWidthMs = [0.02 0.05 0.1 0.2 0.5 ...
%     0.75 1 2 ...
%     3 ]

flistFileNameID = flistName(end-21:end-11);

binWidthMs = 0.5;
subplotMainHandle = figure;

for iBinWidth = 1: length(binWidthMs)
iBinWidth

% [heatMap, neuronTs] = compare_ts(binWidthMs(iBinWidth)  );
[heatMap, neuronTs] = find_redundant_ts(binWidthMs(iBinWidth)  );

% direct to subplot figure
figure(subplotMainHandle)

% plot subplot
subplot(3,3,iBinWidth);
imagesc(heatMap);
title(strcat('Bin Width-', num2str(binWidthMs(iBinWidth)),' ms'));

% plot to separate figure
figure
imagesc(heatMap);
title(strcat('Bin Width-', num2str(binWidthMs(iBinWidth)),' ms'));
colorbar

% save file
saveToDir = '';
print('-depsc', '-tiff', '-r300', fullfile(saveToDir, ...
    strcat('HeatmapComparison_BinWidth',...
    strrep(num2str(binWidthMs(iBinWidth)),'.','-') )));


end

%% plot matches for certain neurons
selNeuronInds = [43]

for iSelNeuronInds = 1:length( selNeuronInds )
    
    figure, plot(heatMap(selNeuronInds(iSelNeuronInds),:))

end