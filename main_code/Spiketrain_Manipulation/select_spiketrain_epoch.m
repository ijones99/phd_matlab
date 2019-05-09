function spikeTrainSel = select_spiketrain_epoch(timeStamps, startTime, stopTime,varargin)
% spikeTrainSel = select_spiketrain_epoch(timeStamps, startTime, stopTime)
% P.epochTimescale = 0;

P.epochTimescale = 0;
P = mysort.util.parseInputs(P, varargin, 'error');

spikeTrainSel = timeStamps(find(and(timeStamps>=startTime, ...
    timeStamps<=stopTime)));

if P.epochTimescale % change time scale to epoch time scale
    spikeTrainSel = spikeTrainSel-startTime;
end

end