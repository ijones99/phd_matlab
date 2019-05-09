function spikeCount = get_spike_count(spikeTrains)
% FUNCTION SPIKECOUNT = GET_SPIKE_COUNT(SPIKETRAINS)
% Description: counts number of spikes in cells of spiketrains

% check input
if ~iscell(spikeTrains)
    fprintf('Error: wrong input datatype.\n');
    return;
end

% number input spike trains
numberSpikeTrains = length(spikeTrains);

% init spike count var
spikeCount = zeros(1,numberSpikeTrains);

% Go through all spike trains
for iSpikeTrain = 1:length(spikeTrains)
    
    spikeCount(iSpikeTrain) = length(spikeTrains{iSpikeTrain}); % get number of spikes
    
    
end




end