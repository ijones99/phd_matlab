function [numMatchingSpikes matchingIdx] = compare_spiketrains(st1, st2, spikePrecisionPlusMinus)
% numMatchingSpikes = COMPARE_SPIKETRAINS(st1, st2, spikePrecisionPlusMinus)

if nargin < 3
    spikePrecisionPlusMinus = 0;
end

if spikePrecisionPlusMinus
    st1 = round2(st1, spikePrecisionPlusMinus*2);
    st2 = round2(st2, spikePrecisionPlusMinus*2);
end

matchingIdx = find(ismember(st1,st2));

numMatchingSpikes = length(matchingIdx);




end