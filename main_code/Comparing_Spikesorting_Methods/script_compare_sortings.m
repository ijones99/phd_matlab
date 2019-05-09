%% "Good Matches" between Ian and Felix Sortings
clear neurNameI neurNameF
neurNameI={'6257n225' '6562n107' '6259n233' '6259n212' '6052n131' '6054n182' '5647n225' '5847n128' '5440n92' '5237n4'};
neurNameF={'0004n10' '0031n3' '0018n8' '0003n7' '0017n6' '0024n2' '0023n5' '0029n2' '0012n3' '0006n8'};

%% Matches with spike count discrepancies
clear neurNameI neurNameF
neurNameI={'6462n128' '5138n73' '4831n22' '4931n66' '4627n74' '4828n37'}
neurNameF={'0018n9' '0011n6' '0037n9' '0037n7' '0014n2' '0032n8'}

%% Matches only found by Felix
clear neurNameI neurNameF
neurNameF={'0004n9' '0021n9' '0004n3' '0022n2' '0021n10' '0017n9' '0003n4' '0017n3' ...
    '0029n5' '0012n5' '0016n6' '0036n6' '0012n10' '0006n4' '0012n4' '0024n5' '0016n2' '0028n7' ...
    '0027n8' '0036n4' '0011n5' '0028n9' '0028n5'     '0037n10' '0014n6' '0027n9' '0037n2' ...
    '0032n6'};

%% All Neurons found by Felix's sorter
neurNameF={'0004n10' '0031n3' '0018n8' '0003n7' '0017n6' '0024n2' '0023n5' '0029n2' '0012n3' '0006n8' ...
    '0018n9' '0011n6' '0037n9' '0037n7' '0014n2' '0032n8'...
    '0004n9' '0021n9' '0004n3' '0022n2' '0021n10' '0017n9' '0003n4' '0017n3' ...
    '0029n5' '0012n5' '0016n6' '0036n6' '0012n10' '0006n4' '0012n4' '0024n5' '0016n2' '0028n7' ...
    '0027n8' '0036n4' '0011n5' '0028n9' '0028n5'     '0037n10' '0014n6' '0027n9' '0037n2' ...
    '0032n6'}

%% calculate matching spikes with varying amounts of jitter
shiftSampleValues = 0;%[-40 30 -20 0 20 30 40];
roundSampleValues = [5];

savePercentMatchMean = [];
for k = 1:length(roundSampleValues)
    for j = 1:length(shiftSampleValues)
        
        roundAmtSamples = roundSampleValues(k);
        shiftAmtSamples = shiftSampleValues(j);
        if roundAmtSamples ~= 0
            fprintf('\nSpike times compared with overlap distance of %3.1f msec:\n', roundAmtSamples/20);
        end
        if shiftAmtSamples ~= 0;
            fprintf('\nSpike times shifted by %3.1f msec:\n', shiftAmtSamples/20);
        end
        
        for i=1:length(neurNameF)
            % Ian
            dataI = load_profiles_file(neurNameI{i}, 'use_sep_dir', 'run_manual_sorting');
            
            % Felix
            dataF = load_profiles_file(neurNameF{i});
            
            %
            
            spikeTimes{1} = dataI.White_Noise.spiketimes;
            spikeTimes{2} = dataF.White_Noise.spiketimes;
            if roundAmtSamples ~= 0
                [stMatches numMatches] = mysort.spiketrain.checkForOverlaps(spikeTimes,roundAmtSamples);
          
            end
            if shiftAmtSamples ~= 0
                spikeTimesF{1} = spikeTimesF{1} + shiftAmtSamples;
            end
            
            percentMatch(i) = numMatches(2)/length(stMatches{1});
            
            fprintf('Comparing %s (I) to %s (F): %3.0f percent match for %7.0f spikes (Ian) and %7.0f spikes (Felix).\n', ...
                neurNameI{i}, neurNameF{i}, round(percentMatch(i)*100), length(spikeTimes{1}), length(spikeTimes{2}));
            
        end
        savePercentMatchMean(end+1) = mean(percentMatch*100);
    end
  
end

%% plot matches
figure, bar( savePercentMatchMean)
set(gca, 'XTick', 1:length(roundSampleValues), 'XTickLabel', roundSampleValues/20);
xlabel('Shift values (msec)')
ylabel('Mean Percent Match between Spike Trains')
title('rounded spiketime matches of well-matched neurons')
%% plot spiketimes:
spikeIndsToPlot = 4000:5000; figure, hold on, 
plot([spikeTimesI(spikeIndsToPlot); spikeTimesI(spikeIndsToPlot)],...
    [zeros(1,length(spikeIndsToPlot)); ones(1,length(spikeIndsToPlot))],'b')
plot([spikeTimesF(spikeIndsToPlot); spikeTimesF(spikeIndsToPlot)],...
    [zeros(1,length(spikeIndsToPlot)); ones(1,length(spikeIndsToPlot))],'r--')
ylim([-5 5])                                                                      


% exportfig(gcf, fullfile(dirSave,strcat(titleName,'.ps')) ,'Resolution', 120,'Color', 'cmyk')
%% Prepare H5 File Access
h5_file = '/links/groups/hima/recordings/HiDens/SpikeSorting/Roska/13Dec2012_2/Trace_id1035_2012-12-13T21_04_40_21.stream.h5';
% dont change these settings, otherwise you will have to prefilter the data
% again and that takes a while
hpf = 350;
lpf = 8000;
filterOrder = 6;
hdmea = mysort.mea.CMOSMEA(h5_file, 'hpf', hpf, 'lpf', lpf, 'filterOrder', filterOrder);
%% Compare Inclusive and Exclusive Spikes Between Ian's So   rting and Felix's Sorting
doSave = 1;
dirName.waveform_figs = '../Figs/T21_04_40_21_white_noise_050/Footprints';
for i=1:length(neurNameI)
    fprintf('Comparing %s to %s.\n', neurNameI{i}, neurNameF{i});
    %load data
    dataI = load_profiles_file(neurNameI{i}, 'use_sep_dir', 'run_manual_sorting');
    dataF = load_profiles_file(neurNameF{i});
    
    % assign spiketimes
    spikeTimes{1} = double(dataI.White_Noise.spiketimes);
    spikeTimes{2} = dataF.White_Noise.spiketimes;
    
    % compare timestamps
    roundAmtSamples = 5; %samples
    [stMatches numMatches] = mysort.spiketrain.checkForOverlaps(spikeTimes,roundAmtSamples);
    
    % separate into spike time groups based on inclusion/exclusion
    groupedSpikeTimes.ian_only = spikeTimes{1}(find(stMatches{1}==0));
    groupedSpikeTimes.felix_only = spikeTimes{2}(find(stMatches{2}==0));
    groupedSpikeTimes.mutual = spikeTimes{2}(find(stMatches{2}==1));
    groupColors = {'r', 'g', 'b'};
    
    % plot footprints
    % for cutting
    cutLeft = 15;
    cutLength = 30;
    % get fields
    fieldsForSTGroups = fields(groupedSpikeTimes);
    
    % figure
    h =  mysort.plot.figure;
    axesHandle = axes();
    title(['Comparing ', neurNameI{i}, ' to ', neurNameF{i}]);
    for j=1:length(fieldsForSTGroups)
        
        % get spike times & spikes structure
        currspiketimes = round(getfield(groupedSpikeTimes, fieldsForSTGroups{j}));
        spikes = hdmea.getWaveform(currspiketimes, cutLeft, cutLength);
        % convert spikes to tensor
        spikes = mysort.wf.v2t(spikes, size(hdmea,2));
        
        % center spikes
        outputAdjustments = center_spikes_and_return_spiketime_adjustments(spikes);
        currspiketimes = currspiketimes+outputAdjustments;
        % recut spikes with correct times from centered waveforms
        clear spikes
        spikes = hdmea.getWaveform(currspiketimes, cutLeft, cutLength);
        spikes = mysort.wf.v2t(spikes, size(hdmea,2));
        % plot waveforms
        allEls = 1:size(hdmea,2);
        
        notIncludedEls = [14 116 80 82 11 10 85 8 7 64];
        allElsToPlot = 1:size(hdmea,2);
        allElsToPlot(notIncludedEls) = [];
        spikes2 = spikes;
%         spikes2 = center_spikes(spikes);
        mysort.plot.waveforms2D_2(spikes2, hdmea.MultiElectrode.electrodePositions,...
            'plotMedian', 1,...
            'maxWaveforms', 5000, ...
            'plotElNumbers', allEls, ...%         'plotHorizontal', idxMaxAmp, ...
            'plotSelIdx', allElsToPlot, ...
            'plotMedianOnly', 1, ...
            'plotMedianPlotArgs', {'-', 'color', groupColors{j}, 'linewidth', 2}, ...
            'AxesHandle', axesHandle  )
        
        h2 = mysort.plot.figure
        mysort.plot.waveforms2D_2(spikes2, hdmea.MultiElectrode.electrodePositions,...
            'plotMedian', 1,...
            'maxWaveforms', 5000, ...
            'plotElNumbers', allEls, ...%         'plotHorizontal', idxMaxAmp, ...
            'plotSelIdx', allElsToPlot);
        
        titleName = strcat(['Comparing ', neurNameI{i}, ' to ', neurNameF{i},'->',...
            strrep(fieldsForSTGroups{j},'_','-'),' (', num2str(size(spikes2,3)),' spikes)' ]);
        title(titleName);
        if doSave
            saveas(h2,fullfile(dirName.waveform_figs ,strcat(titleName,'.fig')),'fig'); %name is a string
        end
    end
    legend(axesHandle, strrep(fieldsForSTGroups,'_','-'))
    
    titleName = strcat(['Comparing ', neurNameI{i}, ' to ', neurNameF{i}, '->Median Plots'  ]);
    title(titleName);
    if doSave
        saveas(h,fullfile(dirName.waveform_figs ,strcat(titleName,'.fig')),'fig'); %name is a string
    end
%     close all
end