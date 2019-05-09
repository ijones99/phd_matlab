% Get the timestamps
% % each group of stimuli contains several repetitions
% numRepsPerGroup = 5; % number of repetitions per stimulus group
% numStimGroups = 3; % number of such groups
% stimGroupAllReps = [0:numRepsPerGroup:numRepsPerGroup*(numStimGroups-1)]+stimGroup;
% % the group numbers for the stimulus of interest
%
% data
iNeuron = 10;
% all spikes for this neur
spiketrainEntire = tsMatrix{iNeuron}.spikeTimes;
stimGroup = [[1 6 11]+3];
numStartStopTsPerStimulusCluster = 11; 

indStimTsBasicPattern = [1 3 5 7 9];
indStimTs = [];
for i=1:length(stimGroup)
    indStimTs = [indStimTs indStimTsBasicPattern+11*(stimGroup(i)-1) ];
end

selSpikes = {};
for iRep = 1:length(indStimTs)
    
    stimStartTs = stimFramesTsStartStop(indStimTs(iRep))/acqRate;
    stimStopTs = stimFramesTsStartStop(indStimTs(iRep)+1)/acqRate;
    
    selSpikes{iRep,1} = double(get_selected_spikes(spiketrainEntire, stimStartTs, stimStopTs, 'align_to_zero'));
%     dlmwrite('data/test.stad', selSpikes{iRep}, 'delimiter', ' ','-append');
    
end