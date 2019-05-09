
guassianSigma = 0.025;%0.010;
convBinWidth = 0.020; %0.001;
binSizeForTs = 0.020; %0.001; % size of bin seconds
lengthStimSec = round(synthData{1}.ts{1}(end));
bins = [0:binSizeForTs:lengthStimSec]; % set bins
numBins = length(bins);  % number of bins
for iGroup = 1:length(synthData)% for all groups of repeats
    
    numStimRepeats = length(synthData{iGroup}.ts); % # of stimulus repeats
    ... num times stim shown
        lengthStimSec = round(synthData{iGroup}.ts{1}(end)); % duration of
    ... one stimulus.
        
% bin data for Exp spiketrains
for i=1:numStimRepeats % for number of spiketrain groups
    synthData{iGroup}.binnedData{i} = ...
        uint8(histc(synthData{iGroup}.ts{i},[bins]));
    % convolve data with Gaussian
    synthData{iGroup}.convBinnedData{i} = ...
        conv_gaussian_with_spike_train(double(synthData{iGroup}.binnedData{i}), ...
        guassianSigma, convBinWidth);
end

end
%%
% add binned data together
corrLimSec = 0.040;
corrIndMean = [];
corrIndStd = [];
for iGroup = 1:length(synthData)% for all groups of repeats
    corrIndex = [];
    for i=1:2:numStimRepeats % for number of spiketrain groups
        if i==1
        corrIndex(end+1) = get_corr_index(synthData{iGroup}.convBinnedData{i}, ...
            synthData{iGroup}.convBinnedData{i+1},binSizeForTs, corrLimSec,1) ;
        else
        corrIndex(end+1) = get_corr_index(synthData{iGroup}.convBinnedData{i}, ...
            synthData{iGroup}.convBinnedData{i+1},binSizeForTs, corrLimSec) ;
        end
    end
    if isfield(synthData{iGroup},'sigma')
        sigmaValsJitter(iGroup) = synthData{iGroup}.sigma;
    end
    synthData{iGroup}.corrIndex = corrIndex;
    corrIndMean(iGroup) =  mean(corrIndex);
    corrIndStd(iGroup) =  std(corrIndex);
    if isfield(synthData{iGroup},'percentSpikesRemoved')
        percentSpikesToRemove(iGroup) = synthData{iGroup}.percentSpikesRemoved;
    end
end

%% Correlation Index for Sythesized Data for Sigma Var
figure
sigmaValsJitter = [1 2]
errorbar((sigmaValsJitter), corrIndMean,corrIndStd,'LineWidth',2)
xlabel(' Jitter Sigma Value');
ylabel('Correlation Index');
title('Correlation Index for Sythesized Data');
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',15) ;

%% Correlation Index for Sythesized Data for NumSpikes Var
figure
errorbar(percentSpikesToRemove, corrIndMean,corrIndStd,'LineWidth',2)
xlabel('Log Jitter Sigma Value');
ylabel('Correlation Index');
title('Correlation Index for Sythesized Data');
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',15) ;


%% Correlation Index for One Neuron
figure
errorbar( [1 2] , corrIndMean,corrIndStd,'x')
xlabel('Log Jitter Sigma Value');
ylabel('Correlation Index');
title('Correlation Index for One Neuron');
xLimCoords = xlim; yLimCoords = ylim; 
[h p]= ttest(synthData{1}.corrIndex,synthData{2}.corrIndex)
text(xLimCoords(1)+diff(xLimCoords)*0.75,yLimCoords(1)+diff(yLimCoords)*0.75,['p=',num2str(p)]);
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'original movie','static median surround'})

%% Correlation Index vs Percent Removed Spikes for Sythesized Data
figure
errorbar(percentSpikesToRemove, corrIndMean,corrIndStd, 'r','LineWidth',2)
xlabel('Percent Removed Spikes');
ylabel('Correlation Index');
title(['Correlation Index vs Percent Removed Spikes for Sythesized Data, Sigma =',num2str(sigmaValsJitter(1))]);
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',15) ;
ylim([0 60]);xlim([-5 max(percentSpikesToRemove)]);