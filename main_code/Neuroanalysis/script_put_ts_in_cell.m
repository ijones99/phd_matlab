% Get the timestamps
% % each group of stimuli contains several repetitions
% numRepsPerGroup = 5; % number of repetitions per stimulus group
% numStimGroups = 3; % number of such groups
% stimGroupAllReps = [0:numRepsPerGroup:numRepsPerGroup*(numStimGroups-1)]+stimGroup;
% % the group numbers for the stimulus of interest
%
% data
iNeuron = 1;
stimNum = 1;
acqRate = 2e4;
% iNeuron = 50;

flistFileNameID = get_flist_file_id(flist{1}, suffixName);
% dir names
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);

% all spikes for this neur
spiketrainEntire = tsMatrix{iNeuron}.spikeTimes;

doPrint = 1;
loadStimFrameTs=0;

framenoFileName = strcat('frameno_', flistFileNameID, '.mat');
% load light timestamp framenos
load(fullfile(dirNameFFile,framenoFileName));

% shift timestamps for stimulus frames
frameno = shiftframets(frameno);

% start time indices for stimulus

numStimStartIndPerCluster = 35;
numStimStartIndsToDrop = 5;
indStimIndStartFirst = (stimNum-1)*(numStimStartIndPerCluster*2+1)+1;
indStimIndStarts = repmat(indStimIndStartFirst,1,numStimStartIndPerCluster)+[0:2:numStimStartIndPerCluster*2-2];

% get the stimulus start stop timestamps
stimFramesTsStartStop = get_stim_start_stop_ts(frameno, 0.2);

numStimStartIndPerCluster = 35;

selSpikes = {};stimDurSec = {};
for iRep = numStimStartIndsToDrop+1:numStimStartIndPerCluster
    
    stimStartTs = stimFramesTsStartStop(indStimIndStarts(iRep))/acqRate;
    stimStopTs = stimFramesTsStartStop(indStimIndStarts(iRep)+1)/acqRate;
    
    selSpikes{end+1} = double(get_selected_spikes(spiketrainEntire, stimStartTs, stimStopTs, 'align_to_zero'));
    stimDurSec{end+1} = (stimStopTs-stimStartTs);
    %     dlmwrite('data/test.stad', selSpikes{iRep}, 'delimiter', ' ','-append');
    
end
% start time indices for stimulus
% stimNum = 2;
% indStimIndStartFirst = (stimNum-1)*(numStimStartIndPerCluster*2+1)+1;
% indStimIndStarts = repmat(indStimIndStartFirst,1,numStimStartIndPerCluster)+[0:2:numStimStartIndPerCluster*2-2];
%
% for iRep = numStimStartIndsToDrop+1:numStimStartIndPerCluster
%     
%     stimStartTs = stimFramesTsStartStop(indStimIndStarts(iRep))/acqRate;
%     stimStopTs = stimFramesTsStartStop(indStimIndStarts(iRep)+1)/acqRate;
%     
%     selSpikes{end+1} = double(get_selected_spikes(spiketrainEntire, stimStartTs, stimStopTs, 'align_to_zero'));
%     stimDurSec{end+1} = (stimStopTs-stimStartTs);
%     
% end