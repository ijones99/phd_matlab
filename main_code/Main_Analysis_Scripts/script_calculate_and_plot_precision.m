%% plot numspikes info
sortingGpNo = [2 2 3 3 4 4 4]; % sorting group number
selectSegment = [1 2 1 2 1 2 3]; % segment from each sorting group
prefix = 'st_*';
  dirNameSt = strcat('../analysed_data/', dirNamesSortGp(2).name, ...
            '/03_Neuron_Selection/');
[elNumbersInDir] = get_el_numbers_from_dir(dirNameSt, prefix)
figure, hold on
%%
for iEl = 1:length(elNumbersInDir)
    for iStim =  1:length(selectSegment)
        dirNameSt = strcat('../analysed_data/', dirNamesSortGp(sortingGpNo(iStim)).name, ...
            '/03_Neuron_Selection/');
        neurNames = get_neur_names_from_el_nos( elNumbersInDir(iEl), dirNameSt, prefix);
        
        % Load data
        suffixName = convert_t_dir_to_suffix_name(dirNamesSortGp(sortingGpNo(iStim)).name);
        [timeStamps] = load_timestamps_no_split( dirNamesSortGp(sortingGpNo(iStim)).name, ...
            neurNames );
        [segmentTs ] = ...
            extract_repeat_ts_from_data(timeStamps, framenoInfo{sortingGpNo(iStim)}, ...
            selectSegment(iStim));
        
        % Plot avg spikes
        analysisData{iEl}.name = elNumbersInDir(iEl);
        [analysisData{iEl}.avgNumSpikes(iStim) analysisData{iEl}.stdSpikes(iStim)] = ...
            count_num_spikes(segmentTs);
        
    end
    avgNoSpikes(iEl,1:7) = analysisData{iEl}.avgNumSpikes;
    avgNoSpikesStd(iEl,1:7) = analysisData{iEl}.stdSpikes;
    errorbar(analysisData{iEl}.avgNumSpikes, analysisData{iEl}.stdSpikes)
end

%% init cell variable
neurInfo = {};

%% compute spike rate
% use neuronsList
sortingGpNo = [2 2 3 3 4 4 4]; % sorting group number
selectSegment = [1 2 1 2 1 2 3]; % segment from each sorting group
stimulusNumber = 2:length(selectSegment)+1;

outputData = [];

for iNeur = 1:length(neuronsList{2}.neuron_names) % go through neurons
    outputData.neuron_name = neuronsList{2}.neuron_names{iNeur};
    outputData.stimulus_name = {};
    outputData.segment_num = [];
    for iStim =  1:length(sortingGpNo) % gothrough all directories and neurons
        outputData.stimulus_name = dirNamesSortGp(sortingGpNo(iStim)).name;
        outputData.segment_num = selectSegment(iStim);
        if ~isempty(neuronsList{sortingGpNo(iStim)}.neuron_names{iNeur})
            timeStamps = load_timestamps_no_split( dirNamesSortGp(sortingGpNo(iStim)).name, ...
                neuronsList{sortingGpNo(iStim)}.neuron_names{iNeur} );
            repeats = ...
                extract_repeat_ts_from_data(timeStamps, framenoInfo{sortingGpNo(iStim)}, ...
                selectSegment(iStim));
            outputData.repeats = repeats;
            
            for iRep = 1:length(repeats) % count number spikes
                numSpikes(iRep) =  length(repeats{iRep});
                
            end
            
            outputData.mean_spike_count = mean(numSpikes);
            outputData.std_spike_count = std(numSpikes);
            
            [psthDataSmoothed psthDataMeanSmoothed ] =    ...
                get_psth_for_repeats(repeats, 30, 1);
            outputData.corr_index_meister96 = ...
                get_corr_index_meister96(psthDataSmoothed,0.025, 0.1, 0);
            
        else
            outputData.mean_spike_count = NaN;
            outputData.std_spike_count = NaN;
            outputData.corr_index_meister96 = NaN;
        end
        
        save_to_results_file(neuronsList{2}.neuron_names{iNeur}, stimulusNumber(iStim),outputData);
        
    end
    iNeur
end
%% plot spike rate
figure, hold on
for iNeuron = 1:length(outputData)
    plot(outputData{iNeuron}.corr_index_meister96,'.--');
end
%% plot the precision data

for iPlotData = 1:length(neuronsList{2}.neuron_names) %
    %     load file and frameno
    load(fullfile(dirName.St{sortingGroup(iPlotData)},neuronNames{1})); % load spiketimes
    eval(['timeStamps = ', neuronNames{1},'.ts;']); %rename spiketimes
    load(fullfile(dirName.SortingGroup{sortingGroup(iPlotData)}, ...
        fileNameFrameNo{sortingGroup(iPlotData)}));
    frameno = single(frameno);
end
spikeCounts = sum(psthData,2)'; %number of spikes in each repeat
meanSpikeCount = mean(spikeCounts);
stdSpikeCount = std(spikeCounts);

%% load precision data
dirPrecision = '/home/ijones/DataAnalysis/ProcessedNeurons';
prefix = '*2012*';
stimuliInds = [2:8];
%get neuron names
neuronNames = get_neur_names_from_dir(dirPrecision, prefix, 'remove_date');

% create empty matrices for all data
spikeCountMean = zeros(length(neuronNames), length(stimuliInds));
spikeCountStd = zeros(length(neuronNames), length(stimuliInds));
corrIndexVal = zeros(length(neuronNames), length(stimuliInds));

for iNeur = 1:length(neuronNames) % go through all neurons
        
    for iStim = 1:length(stimuliInds) % go through all stimuli
        resultsData = load_results_files(neuronNames{iNeur},'dir_name', ...
            dirPrecision);
        
        spikeCountMean(iNeur,iStim) = resultsData{stimuliInds(iStim)}.mean_spike_count;
        spikeCountStd(iNeur,iStim) = resultsData{stimuliInds(iStim)}.std_spike_count;
        corrIndexVal(iNeur,iStim) = resultsData{stimuliInds(iStim)}.corr_index_meister96;
    end
    iNeur
end

%% analyse by groups: plot spikecount

cellType = {'DS', 'non-DS', 'RF Large', 'RF Small', ...
            'ON', 'OFF', 'ON-OFF', 'Transient', 'Sustained'}
neuronIndsForRGCType = {};        
neuronIndsForRGCType{end+1} = [2 4 5 6 7 8 10 11 12 13];   %DS    
neuronIndsForRGCType{end+1} = [1 3 9 ] % non-DS
neuronIndsForRGCType{end+1} = [1 3 5 7 8 9 11 12 ] % RF Large      
neuronIndsForRGCType{end+1} = [2 4 10 13] % RF Small
neuronIndsForRGCType{end+1} = [4 5 6 9 11 12 ] % ON
neuronIndsForRGCType{end+1} = [1 2 7 8 13] % OFF
neuronIndsForRGCType{end+1} = [4 10] % ON-OFF
neuronIndsForRGCType{end+1} = [1 2 3 6 9 10 11 12] % Transient      
neuronIndsForRGCType{end+1} = [4 5 7 8 13] %Sustained
   
figure, hold on
plotColors = get_plot_colors(length(neuronIndsForRGCType));
for i=1:length(neuronIndsForRGCType)
    spikeCountMeanForType = mean(spikeCountMean(neuronIndsForRGCType{i},:),1 );
    plot(spikeCountMeanForType, 'Color', plotColors(i,:));
    
end
legend(cellType)
title('Spike Count')

figure, hold on
plotColors = get_plot_colors(length(neuronIndsForRGCType));
for i=1:length(neuronIndsForRGCType)
    corrIndexValMeanForType = mean(corrIndexVal(neuronIndsForRGCType{i},:),1 );
    plot(corrIndexValMeanForType, 'Color', plotColors(i,:));
    
end
legend(cellType)
title('Correlation Index')

%% ttest heat map: spike count
stimNames = {'Orig Movie', 'Stat Med Surr', 'Dyn Med Surr', ...
    'Dyn Med Surr Shuff', 'Pix Surr 10%', ...
    'Pix Surr 50%', 'Pix Surr 90%'}; 

outputDir = 'Figs/SpikeCount';
h=figure('Position', [1 1 1600 1200] ); % [left bottom width height]....get(0,'ScreenSize')  [1 1 1920 1200]                                                                                    
set(gcf,'color',[1 1 1])

setSpacing = 0.015;
setPadding = 0.015;
setMargin = 0.017;
subplotsVert = 3;
% length(neuronsList{2}.neuron_names) ;
subplotsHor = 3;


heatMapSpikeCount = zeros(length(size(spikeCountMean,2)));
for iRGCType = 1:length(neuronIndsForRGCType)
    
    subaxis(subplotsVert,subplotsHor,iRGCType, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    for iStimType1 = 1:size(spikeCountMean,2)
        
        for iStimType2 = 1:size(spikeCountMean,2)
            x = spikeCountMean(neuronIndsForRGCType{iRGCType},iStimType1);
            y = spikeCountMean(neuronIndsForRGCType{iRGCType},iStimType2);
            [h,p,ci] = ttest2(x,y );
            heatMapSpikeCount(iStimType1, iStimType2) = p;
        end
        
    end
    
    hold
% set(h,'color',[1 1 1])
stimNumber = {'Stim_1','Stim_2','Stim_3','Stim_4','Stim_5','Stim_6','Stim_7','Stim_8','Stim_9' };

imagesc(kron(flipud(heatMapSpikeCount),ones(20))), colorbar, caxis([0 1]) ;
set(gca,'XTickLabel', stimNumber)
set(gca,'YTickLabel', stimNumber)
set(gca,'FontSize', 14)
title(strrep(strcat('',cellType{iRGCType} ),'_', ' '),...
    'FontSize', 14, 'FontWeight', 'bold')
axis off
% print(h,fullfile(outputDir,strcat('SpikeCount_P_Value_Heatmap_',cellType{iRGCType} ) ))
end
% plot title at top of subplots


%% ttest heat map: corr coeff
stimNames = {'Orig Movie', 'Stat Med Surr', 'Dyn Med Surr', ...
    'Dyn Med Surr Shuff', 'Pix Surr 10%', ...
    'Pix Surr 50%', 'Pix Surr 90%'}; 

outputDir = 'Figs/CorrIndexMeister1996';

heatMapCorrIndex = zeros(length(size(corrIndexVal,2)));
for iRGCType = 1:length(neuronIndsForRGCType)
for iStimType1 = 1:size(corrIndexVal,2)
    
    for iStimType2 = 1:size(corrIndexVal,2)
        x = corrIndexVal(neuronIndsForRGCType{iRGCType},iStimType1);
        y = corrIndexVal(neuronIndsForRGCType{iRGCType},iStimType2);
        [h,p,ci] = ttest2(x,y );
        heatMapCorrIndex(iStimType1, iStimType2) = p;
    end
    
end
h=figure('Position', [1 1 1600 1200] ); % [left bottom width height]....get(0,'ScreenSize')  [1 1 1920 1200]                                                                                    
hold 
set(h,'color',[1 1 1])
imagesc(kron(heatMapCorrIndex,ones(20))), colorbar, caxis([0 1]) ; % use kron to blow up image to higher resolution
set(gca,'XTickLabel', stimNames)
set(gca,'YTickLabel', stimNames)
set(gca,'FontSize', 14)
title(strrep(strcat('Corr_Coeff_P_Value_Heatmap_',cellType{iRGCType} ),'_', ' '),...
    'FontSize', 14, 'FontWeight', 'bold')
print(h,fullfile(outputDir,strcat('Corr_Coeff_P_Value_Heatmap_',cellType{iRGCType} ) ))

end

