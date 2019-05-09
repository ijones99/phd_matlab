


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

