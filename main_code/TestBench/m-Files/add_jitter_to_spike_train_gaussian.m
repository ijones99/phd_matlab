function outputSpikeTrain = add_jitter_to_spike_train_gaussian(inputSpikeTrainSec,sigmaSec)
% OUTPUTSPIKETRAIN = ADD_JITTER_TO_SPIKE_TRAIN_GAUSSIAN(INPUTSPIKETRAINSEC,SIGMASEC)
% INPUTSPIKETRAINSEC: input spiketrain in seconds
% SIGMA: value for gaussian to create jitter

mu = 0;
numSpikes = length(inputSpikeTrainSec); % number spikes

jitter = normrnd(mu,sigmaSec,[1,numSpikes]); % create normal distributed jitter
outputSpikeTrain = unique(sort(inputSpikeTrainSec+jitter,'ascend')); % add jitter to spiketrain



end