function spiketrainCell = extract_multiple_epochs(stCurr, stimChangeTs, idxRaster, varargin)
% SPIKETRAINCELL = extract_multiple_epochs(stCurr, stimChangeTs, idxRaster)
%
% varargin
%   'pre_stim_time_sec'


preStimTime_sec=0;


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'pre_stim_time_sec')
            preStimTime_sec = varargin{i+1};
        end
    end
end

acqRate = 2e4;
preStimTime_samples = preStimTime_sec*acqRate;

spiketrainCell = {};

for i=1:size(idxRaster,1)
    
    if max(idxRaster(i,:))<=length(stimChangeTs)
        [spikeTrain spiketrainSeg] = spiketrains.extract_epoch_from_spiketrain(stCurr,...
            stimChangeTs(idxRaster(i,1))-preStimTime_samples,stimChangeTs(idxRaster(i,2)));
        
    else
        % for the last bit of the recording, when there is no frameno
        % change at the conclusion of the experiment
        intervalLength = diff(stimChangeTs(idxRaster(i-1,:))');
        [spikeTrain spiketrainSeg] = spiketrains.extract_epoch_from_spiketrain(stCurr,...
            stimChangeTs(idxRaster(i,1))-preStimTime_samples,stimChangeTs(idxRaster(i,1))+intervalLength);
        
        
    end
    spiketrainCell{i} = spiketrainSeg;
end