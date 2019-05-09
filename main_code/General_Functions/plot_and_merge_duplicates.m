m = NaN(600)   ;
for i=1:length(    activeElsYPlotCoord)
    m(round(activeElsYPlotCoord-10:round(activeElsYPlotCoord+10),round(activeElsXPlotCoord-10:roundactiveElsXPlotCoord+10)))=1;
    
end


%% plot duplicates
close all
for i=1%:length(duplicateCounter)
 scrsz = get(0,'ScreenSize');
% figure('Position',[0.9 0.9 1500 1500],'Color','w')   
%     plot_neurons(selectedNeurons(duplicateCounter{i}),'chidx','allactive')
    plot_neurons(selectedNeurons([44, 45, 47]),'chidx','allactive','separate_subplots')
% plot_neuron_events(selectedNeurons(duplicateCounter{i}),20000,1:length(duplicateCounter{i}))

end
%% merge duplicates
mergedDuplicateNeurons = {};
for i=1:length(duplicateCounter)
    selectedNeurons{duplicateCounter{i}}
    tempNeur = merge_neurons(selectedNeurons{duplicateCounter{i}},'interactive',.1,'no_isi');
    mergedDuplicateNeurons{end+1:end+length(tempNeur)} = tempNeur;
end



