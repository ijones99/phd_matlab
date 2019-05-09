function spikeTimesOut = segment_spiketrains(spikeTimes, switchTime)
% spikeTimesOut = SEGMENT_SPIKETRAINS(spikeTimes, switchTime)
switchTime = [0 switchTime ];
numSwitches = length(switchTime);


spikeTimesOut = {};

for i=1:numSwitches
    if i<numSwitches
    spikeTimesOut{i} = spikeTimes(find(and(spikeTimes>=switchTime(i),  ...
        (spikeTimes<switchTime(i+1)))));
    else
        spikeTimesOut{i} = spikeTimes(find(spikeTimes>=switchTime(i)));
        
    end
    
end



end