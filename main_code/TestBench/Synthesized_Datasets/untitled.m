%% put spikes in cell
load /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/analysed_data/21Aug2012/T13_40_28_0_orig_stat_surr/03_Neuron_Selection/st_6271n60.mat
interStimIntervalSec=.2;
stimFramesTsStartStop = get_stim_start_stop_ts2(frameno, interStimIntervalSec);
adjustToZero = 1;
spikeTrains = extract_spiketrain_repeats_to_cell(st_6172n29.ts, ...
    stimFramesTsStartStop/2e4,adjustToZero)


%%

lengthOfRec = length(frameno);
figure, plot([round(lengthOfRec*.95):lengthOfRec], ...
    frameno(round(lengthOfRec*.95):end)), hold on
plot(stimFramesTsStartStop, frameno(stimFramesTsStartStop),'r.')

%% put spikes into neurData
neurData = {};
neurData{1}.ts = {};
neurData{2}.ts = {};
for i=5:35
    neurData{1}.ts{end+1} = sort(spikeTrains{i});  
    
end

for i=41:70
    neurData{2}.ts{end+1} = sort(spikeTrains{i});        
end
%% put results into a structure
cellNum = 8;
realData{cellNum}.name = 'st_6271n60';
realData{cellNum}.corrIndMean = corrIndMean;
realData{cellNum}.corrIndStd = corrIndStd;
realData{cellNum}.neurData = neurData;
%% plot all cells
cmap = hsv(cellNum); % colormap
figure, hold on
xLabel{1} = 'Original';
xLabel{2} = 'Aperture';

for iCellNum=1:cellNum
   subplot(3,3,iCellNum)
   
   errorbar((sigmaValsJitter), realData{iCellNum}.corrIndMean,...
       realData{iCellNum}.corrIndStd,'*','LineWidth',2,'Color',cmap(iCellNum,:) )
   title(strrep(realData{iCellNum}.name,'_','-'));
   set(gca,'XTick',[1 2])
   set(gca, 'XTickLabel', xLabel)
   fig=gcf;
   set(findall(fig,'-property','FontSize'),'FontSize',15) ;
     ylabel('Corr. Index')

end

%% count num spikes

for iCellNum=1:cellNum
    for iStim = 1:2
 
        numSpikes = [];
        for iRep = 1:length(realData{iCellNum}.neurData{iStim}.ts)
            numSpikes(end+1) = length(realData{iCellNum}.neurData{iStim}.ts{iRep})
            
        end
        realData{iCellNum}.meanNumSpikes1{iStim} = mean(numSpikes);
        realData{iCellNum}.stdNumSpikes1{iStim} = std(numSpikes);
    end
    
    
    
end