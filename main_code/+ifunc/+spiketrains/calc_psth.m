function psth = calc_psth(spikeTimes, edges)
% function psth = calc_psth(spikeTimes, edges)
% PURPOSE: calculate psth. Does NOT take average;
% rather, all spikes are put into bins. To obtain
% average per trial, divide by number of trails
%
% ARGUMENTS
%   spikeTimes: cells of spiketimes
%   edges: vector with range and increments along which 
%   to bin: e.g. [0:0.1:1];
%
%ijones


numBins = size(edges,2);
numTrials = length(spikeTimes);

psth = zeros(1,numBins);

for i=1:numTrials
    psth = psth+histc(spikeTimes{i},edges);
    
    
end

end