m = NaN(600)   ;
for i=1:length(    activeElsYPlotCoord)
    m(round(activeElsYPlotCoord-10:round(activeElsYPlotCoord+10),round(activeElsXPlotCoord-10:roundactiveElsXPlotCoord+10)))=1;
    
end

%% Plot circles where neurons are
 
neuronCenterTracker = zeros(length(selectedNeurons),2);
    duplicateCounter = [];
figure, hold on
for i=1:length(selectedNeurons)
    % find location of max amp signal (template)
    [I,refLoc] = max(max(selectedNeurons{i}.template.data,[],1)- min(selectedNeurons{i}.template.data,[],1))
    
%     plot(selectedNeurons{i}.x, selectedNeurons{i}.y, '.k' );
    
    % draw circles
    cX=selectedNeurons{i}.x(refLoc); cY=selectedNeurons{i}.y(refLoc); r=16; N=256;
    % add slight offset
    cX = (rand(1)/300+1)*cX;cY = (rand(1)/300+1)*cY;
    
    t=(0:N)*2*pi/N;
    rndclr=[rand, rand, rand];
    switch selectedNeurons{i}.rgc_type
%         case 'on'
%             circlePlot = plot( r*cos(t)+cX, r*sin(t)+cY,'r');
%         case 'off'
%             circlePlot = plot( r*cos(t)+cX, r*sin(t)+cY,'g');
        case 'on-off'
            circlePlot = plot( r*cos(t)+cX, r*sin(t)+cY,'b');
        case 'unclassified'
            circlePlot = plot( r*cos(t)+cX, r*sin(t)+cY,'k');
%         case 'unidentified'
%             circlePlot = plot( r*cos(t)+cX, r*sin(t)+cY,'c');
    end   
    set(circlePlot, 'LineWidth', 2);
% 	text( cX, cY,num2str(i));
    plot(selectedNeurons{i}.x, selectedNeurons{i}.y, '.k' );
    % [reference location, neuron id number]
    neuronCenterTracker(i,:) = [refLoc, i ];
end
[Y,I] = sort(neuronCenterTracker,1,'ascend');
neuronCenterTracker = neuronCenterTracker([I(:,1)],:);
% find duplicates for electrodes
duplicateCounter={};
for n=1:length(selectedNeurons)
    if length(neuronCenterTracker(find(neuronCenterTracker(:,1)==n),2))>1
        duplicateCounter{end+1} = neuronCenterTracker(find(neuronCenterTracker(:,1)==n),2);
    end
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
%% get electrodes of interest
for i=1:length(selectedNeurons)
   electrodeList(i)=selectedNeurons{i}.ELECTRODE;
    
    
    
end

electrodeList = unique(electrodeList);

%% Plot histogram of RF to FP center distances
figure, hist(ListRFFPDistances)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','k')
title('Receptive Field Displacement');
xlabel('Distance from Center of Receptive Field to Center of Footprint (um)')
ylabel('Occurrences')
