function spikeCount = count_spikes(spikeTrains, timeUnits, timeDur)
%  spikeCount = SPIKETRAIN_ANALYSIS.COUNT_SPIKES(spikeTrains, timeUnits, timeDur)

if ~iscell(spikeTrains)
    error('spikeTrains must be cell.\n');
end

if nargin <3
    timeDur = 1e20;
end
if nargin <2
    timeUnits = 'seconds';
end

if strcmp(timeUnits,'samples')
   dataMultUnit = 1;
elseif strcmp(timeUnits,'seconds')
    dataMultUnit = 2e4;
end

spikeCount = [];
for i=1:length(spikeTrains)
    currSpiketrain = spikeTrains{i};
    spikeCount(i) = length(currSpiketrain(find(currSpiketrain<dataMultUnit*timeDur)));
end



end