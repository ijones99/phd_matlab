%%
flist={};
flistName = 'flist_orig_stat_surr'; eval([flistName]);
suffixName = strrep(flistName,'flist','');
textLabel = {'Orig'; 'Stat-Surr'};
numStim = length(textLabel);
acqRate = 2e4;
% selNeuronInds = [1:50];

elNumbers = {'6374n65' ;'6275n203';   '5455n66'; '4945n125'};
selNeuronInds = get_file_inds_from_el_numbers(dirName.St, '*.mat', elNumbers);

[dirName frameno stimFramesTsStartStop stimFrameTimes tsMatrix fileNames ] = ...
    load_ts_data(flist, selNeuronInds, suffixName, []);

Plot_Settings = get_plot_settings; % get plot settings


%%
clear spikeCounts
spikeCounts{1} = struct;
spikeCounts{1}.fileName = 'name';
spikeCounts{1}.numSpikes = zeros(numStim,Plot_Settings.numRepsUsed);

% textprogressbar('Plotting rasters...')

for iIndSelNeurs =  1:length(selNeuronInds) % cycle through all neurons
    
    % fileName
    spikeCounts{iIndSelNeurs}.fileName = fileNames(selNeuronInds(iIndSelNeurs)).name;
    
    % go through stim groups
    for iStimGroup = [1:numStim]
        
        % get spikes 
        spikeTrains = extract_spiketrain_repeats_to_cell(tsMatrix{selNeuronInds(iIndSelNeurs)}.spikeTimes, ...
            stimFramesTsStartStop( (2*Plot_Settings.numRepsToDrop+2*Plot_Settings.numRepsPerStim*(iStimGroup-1))+1:...
                2*Plot_Settings.numRepsPerStim+2*Plot_Settings.numRepsPerStim*(iStimGroup-1))/2e4,0);
        
        % go through each repeat, skipping repeats that should not be
        % counted
        for iRepeat = 1:length(spikeTrains)
            
            if ~isempty(spikeTrains{iRepeat})
                spikeCounts{iIndSelNeurs}.numSpikes(iStimGroup,iRepeat) = length(spikeTrains{iRepeat});
            else
                spikeCounts{iIndSelNeurs}.numSpikes(iStimGroup,iRepeat) = 0;
            end
        end
                
         
    end
end

% plot data
meanVals = {};
stdVals = {};

% get stimulus duration
stimDurationTimeSec=(diff(stimFramesTsStartStop(1:2))/acqRate);
fprintf('Note!!! stim duration time is based on first stimulus appearance'); pause(.2)

%go through stimulus types
for iStimGroup = [1:numStim]
    for iIndSelNeurs =  1:length(spikeCounts) % go through neurons
        
        meanVals{iStimGroup}(iIndSelNeurs) = mean(spikeCounts{iIndSelNeurs}.numSpikes(iStimGroup,:))/stimDurationTimeSec;
        stdVals{iStimGroup}(iIndSelNeurs) = std(spikeCounts{iIndSelNeurs}.numSpikes(iStimGroup,:))/stimDurationTimeSec;
    end
    
     
end


%%
figure, hold on
% subplot(1,4,1:3), hold on
    
XTick = {}
XTick{end+1} = ''
for i=1:length(  spikeCounts)
    XTick{end+1} = spikeCounts{i}.fileName;
    
end
XTick{end+1} = ''
set(gca,'XTick',[0:length(spikeCounts)+1])
set(gca,'XTickLabel',XTick)


errorbar(1:length(meanVals{1}), meanVals{1},stdVals{1},'b.')
errorbar(1:length(meanVals{1}), meanVals{2},stdVals{2},'r.')
legend(textLabel)
title('SpikeCount')
xlabel('Neuron Name'), ylabel('Mean Firing Rate (Spikes/Sec)')


%%

fileName = strcat(['Raster Plot - Neuron ', strrep(fileNames(selNeurs).name,'_','-'), ...
    ' Ind ', num2str(selNeurs),' ', textLabel{1},'_',textLabel{2} ]);
fileName = strrep(fileName,'_','-');
titleName = strcat(['Raster Plot - Neuron ', strrep(fileNames(selNeurs).name,'_','-'), ' Ind ', num2str(selNeurs),' ', stimTypeName]);
titleName = strrep(titleName,'_','-');

title(titleName,'Fontsize', 14)
%             title('Raster Plot - Natural Movie (neurInd 14)','Fontsize', 14)
xlabel('Time (sec)', 'Fontsize', 14)
%     print(gcf,'-depsc', '-r150',strcat('Figs/T16_07_02_2_plus_others/RasterPlots/',titleName,'Rep',num2str(iStimRepeatNumber)) );


if doPrint
    savefigtofile(h, dirOutputFig, fileName);
end


textprogressbar(100*find(selNeurs==selNeuronInds)/length(selNeuronInds));
textprogressbar('end')


