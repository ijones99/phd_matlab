function dataStructure = create_synth_spiketrains(spikeTrainBase, repeatNum, sigmaValuesSec)
% dataStructure = create_synth_spiketrains(spikeTrainBase, repeatNum, sigmaValuesSec)
% spikeTrainBase (vector): timestamps for spike train upon which data will be
%   synthesized
% repeatNum: number of repeats in the dataset
% sigmaValues: vector; sigma values to introduce 

% test for intervals
tsIntervals = diff(spikeTrainBase); % all intervals between spikes
largestSigmaValue = max(sigmaValuesSec); % the largest sigma value
% 2 times the maximum sigma of the jitter cannot be greater or equal to the
% smallest interval size. Otherwise, spikes will be lost due to overlaps.
if largestSigmaValue*2>=min(tsIntervals)
   fprintf('\nError:  2 times the maximum sigma of the jitter cannot be \ngreater or equal to the smallest interval size\n');
   dataStructure = [];
   return
end

dataStructure = {}; % init

for iGroup = 1:length(sigmaValuesSec) % go through groups (etc. diff stimuli)
    
    for iRepeatNum = 1:repeatNum % go through repeat in each group
        
        dataStructure{iGroup}.ts{iRepeatNum} = add_jitter_to_spike_train_gaussian(spikeTrainBase,sigmaValuesSec(iGroup)); 
        %generate timestamps
        
    
    end
    
    % record sigma
    dataStructure{iGroup}.sigma = sigmaValuesSec(iGroup);
    
end


end