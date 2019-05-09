function [indsMaxAmp ampsMaxAmp] = get_max_amp_footprint(footprint, numEls)
% function indsMaxAmp = get_max_amp_footprint(footprint, numEls)
allAmplitudes = max(footprint, [], 1) - min(footprint, [], 1);

[Y, I] = sort(allAmplitudes,'descend');

indsMaxAmp = I(1:numEls);
ampsMaxAmp = Y(1:numEls);

end