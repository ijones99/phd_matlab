function spikeTrain = generate_synthesized_spiketrain(intervalRange, numSpikes)
% function spikeTrain = generate_synthesized_spiketrain(intervalRange, numSpikes)
% arguments
%   intervalRange: [n_low n_high]
%   numSpikes: number of spikes


% create random intervals
randDec = intervalRange(1) + (intervalRange(2)-intervalRange(1)).*rand(1,numSpikes);

% create timestamps
spikeTrain = cumsum(randDec);




end