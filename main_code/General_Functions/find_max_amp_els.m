function [maxAmpEls]  =  find_max_amp_els(neuronsCollected, selNeur, noEls)
% [maxAmpEls]  =  find_max_amp_els(neuronsCollected, selNeur, noEls)
%  NEURONSCOLLECTED: matrix with all neurons
% SELNEUR: neuron selected
% NOELS: # electrodes to find

% find max & min vals
maxVals = max(neuronsCollected{selNeur}.template.data,[], 1);
minVals = min(neuronsCollected{selNeur}.template.data,[], 1);

% find amps of waveform templates
templateAmps = maxVals - minVals;

% sort amps
[B I] = sort(templateAmps, 'descend');

% output electrodes w/ highest amps
maxAmpEls = neuronsCollected{selNeur}.el_idx([I(1:noEls)]);


end