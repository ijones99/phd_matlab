

for iGroup = 1:length(precisionInfo)% for all groups of repeats
    
    
    numStimRepeats = length(precisionInfo{iGroup}.spikeTrains); % # of stimulus repeats
    ... num times stim shown
        lengthStimSec = round(precisionInfo{iGroup}.spikeTrains{1}(end)); % duration of
    ... one stimulus.
        binSizeSec = 0.002; % size of bin
    bins = [0:binSizeSec:lengthStimSec]; % set bins
    numBins = length(bins);  % number of bins
    
    % bin data for Exp spiketrains
    for i=1:numStimRepeats % for number of spiketrain groups
        precisionInfo{iGroup}.binnedData{i} = ...
            histc(precisionInfo{iGroup}.spikeTrains{i},[bins]);
    end
    
end

% add binned data together
binSizeSec = 0.020;
corrLimSec = 0.020;
corrIndMean = [];
corrIndStd = [];
for iGroup = 1:length(precisionInfo)% for all groups of repeats
    corrIndex = [];
    for i=1:numStimRepeats/2 % for number of spiketrain groups
        corrIndex(end+1) = get_corr_index(precisionInfo{iGroup}.binnedData{i},precisionInfo{iGroup}.binnedData{i+1},binSizeSec, corrLimSec) ;
    end
    
    precisionInfo{iGroup}.corrIndex = corrIndex;
    corrIndMean(iGroup) =  mean(corrIndex);
    corrIndStd(iGroup) =  std(corrIndex);
    % get correlation index
end

%% Correlation Index for Sythesized Data
figure
errorbar(log(sigmaValues), corrIndMean,corrIndStd)
xlabel('Log Jitter Sigma Value');
ylabel('Correlation Index');
title('Correlation Index for Sythesized Data');

%% Correlation Index for One Neuron
figure
errorbar( [1 2] , corrIndMean,corrIndStd,'x')
xlabel('Log Jitter Sigma Value');
ylabel('Correlation Index');
title('Correlation Index for One Neuron');
xLimCoords = xlim; yLimCoords = ylim; 
[h p]= ttest(precisionInfo{1}.corrIndex,precisionInfo{2}.corrIndex)
text(xLimCoords(1)+diff(xLimCoords)*0.75,yLimCoords(1)+diff(yLimCoords)*0.75,['p=',num2str(p)]);
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'original movie','static median surround'})
%% Correlation Index vs Percent Removed Spikes for Sythesized Data
% figure
errorbar(percentSpikesToRemove, corrIndMean,corrIndStd)
xlabel('Percent Removed Spikes');
ylabel('Correlation Index');
title('Correlation Index vs Percent Removed Spikes for Sythesized Data');
