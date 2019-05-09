
%% create synthesized dataset
% create dataset
repeatNum = 100;
mu = 0; % distribution settings
spikeTrainBase = ([1:1200:150*1200]);
numSpikes = length(spikeTrainBase); % number spikes
sigmaVals = 0.001*[1e-10 0.5 1 2 5 10 50 100 500 1e3 2e3 5e3 10e3 100e3 500e3];
synthData = create_synth_spiketrains(spikeTrainBase, repeatNum, sigmaVals);


%% Remove spikes
clear precisionInfo
spikeTrainsMod = {};
percentSpikesToRemove = [0 5 10 25 50 75 90];

sigma = iSigma; % sigma value
originalSpikeTrains = spikeTrains; % original spiketrains
repeatNum = length(originalSpikeTrains);
for i = 1:length(percentSpikesToRemove) % go through different percents removal
    clear spikeTrainsMod
    spikeTrainsMod = originalSpikeTrains; % set all groups of spikeTrains equal to original
    % keep reusing original spike trains
    numSpikesInTrain = length(originalSpikeTrains{1}); %num spikes in spike train
    numSpikesToRemove = round((percentSpikesToRemove(i)/100)*numSpikesInTrain); % num spikes to remove
    
    %     R = randperm(numSpikesInTrain);%generate random numbers
    %     spikeIndsToRem = R(1:numSpikesToRemove);%pick the first 1-n numbers
    for iRepeatNum = 1:repeatNum % go through all of the repeats in each group
        
        if percentSpikesToRemove(i) ~= 0 % if some spikes are to be removed, then remove them
            
            R = randperm(numSpikesInTrain);%generate random numbers
            spikeIndsToRem = R(1:numSpikesToRemove);%pick the first 1-n numbers
            %             spikeIndsToRem
            %             spikeIndsToRem = randi(numSpikesInTrain ,1,numSpikesToRemove);%random distribution of spike inds
            spikeTrainsMod{iRepeatNum}(spikeIndsToRem) = [];
        end
    end
    precisionInfo{i}.sigma = iSigma;
    precisionInfo{i}.percentSpikesRemoved = percentSpikesToRemove(i);
    precisionInfo{i}.spikeTrains = spikeTrainsMod;
    
    
end

%% settings to remove spikes from dataset
clear synthData
percentSpikesToRemove = [0 5 10 25 50 75 90];
numSpikesInTrain = length(spikeTrainBase); %num spikes in spike train
repeatNum = 100;

%% create dataset with same ts in every repeat
for i = 1:length(percentSpikesToRemove)
    for iRepeatNum = 1:repeatNum
        synthData{i}.ts{iRepeatNum} = spikeTrainBase;
    end
end

%% create dataset with one sigma variation value
sigmaVals = 0.020%0.001*[1e-10 0.5 1 2 5 10 50 100 500 1e3 2e3 5e3 10e3 100e3 500e3];
for i = 1:length(percentSpikesToRemove)
    synthData(i) = create_synth_spiketrains(spikeTrainBase, repeatNum, sigmaVals);
    
end

%% apply spike removal

for i = 1:length(percentSpikesToRemove) % go through all percents removal

   % num spikes to remove
    numSpikesToRemove = round((percentSpikesToRemove(i)/100)*numSpikesInTrain); 
    
    for iRepeatNum = 1:repeatNum % go through all of the repeats in each group
        if percentSpikesToRemove(i) ~= 0 % if some spikes are to be removed, then remove them
            R = randperm(numSpikesInTrain);%generate random numbers
            spikeIndsToRem = R(1:numSpikesToRemove);%pick the first 1-n numbers          
            synthData{i}.ts{iRepeatNum}(spikeIndsToRem) = [];
        end
    end
    synthData{i}.percentSpikesRemoved = percentSpikesToRemove(i);  
    
end

%% calc cost-based analysis and plot
figure, hold on
cmap = hsv(length(synthData)); % colormap
i=1;
progress_bar(0,[],'computing')
for iPercentDel = 1:length(synthData)
    [qValues meanCost stdCost] = do_cost_based_analysis(synthData{iPercentDel} );
    errorbar(log10(qValues),meanCost,stdCost,'-','LineWidth', 1,'Color',cmap(iPercentDel,:))
    synthData{iPercentDel}.qValues = qValues;
    synthData{iPercentDel}.meanCost = meanCost;
    synthData{iPercentDel}.stdCost = stdCost;
    progress_bar(i/length(synthData));
    progress_bar(i/length(synthData),[],'computing')
    i=i+1;
end
    
    
% set legend & title, etc.
% title(['Cost Based Analysis of Spiketrains - ', X.sites.label, ' Sigma=', num2str(sigmaValues(iSigma))]);
title(['Cost Based Analysis of Spiketrains for Synthesized Data, sigma=',num2str(sigmaVals)  ,', 100 repeats'])
ylim([-0.1 2.2]);
% make legend
legendNames = num2str(percentSpikesToRemove');
legend(legendNames)
ylabel('Total Cost/Spike (log q)')
xlabel('Log of Cost of Shifting Rel to Adding or Deleting Spike');
