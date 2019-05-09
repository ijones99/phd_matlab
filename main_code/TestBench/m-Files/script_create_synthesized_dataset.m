%% create synthesized dataset
% create dataset
repeatNum = 100;
mu = 0; % distribution settings
% load Data/spikeTrainBase; % load data
clear synthData
% when creating, range is the range of spike intervals. When introducing
% jitter, jitter values must not be greater than half of the smallest
% interval.
spikeTrainBase = generate_synthesized_spiketrain([0.031 0.300], 150);
numSpikes = length(spikeTrainBase); % number spikes
% sigmaVals = 0.001*[1e-10 0.5 1 2 5 10 50 100 500 1e3 2e3 5e3 10e3 100e3 500e3]; %in seconds
sigmaValsJitter = [1:10]*1e-3;
synthData = create_synth_spiketrains(spikeTrainBase, repeatNum, sigmaValsJitter);

%%