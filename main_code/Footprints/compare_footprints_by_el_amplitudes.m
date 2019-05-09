function outputMat = compare_amplitude_differences(electrodeP2PAmps)
% This function compares groups of values by taking the absolute difference between
% each possible pair and summing these values. The output is a similarity
% matrix.

numEls = length(electrodeP2PAmps);

% init. output square matrix
outputMat = zeros(numEls);

% make all possible combinations
allPossibleCombos = combnk(1:numWaveforms ,2);

textprogressbar('start comparing all combos')
resolution = 1;

for i=1:length(allPossibleCombos)
    
   
        outputMat(allPossibleCombos(i,1),allPossibleCombos(i,2)) = ...
      sum(abs(electrodeP2PAmps{allPossibleCombos(i,1)}-electrodeP2PAmps{allPossibleCombos(i,1)}));
        
   
    textprogressbar(100*i/length(allPossibleCombos))

end
textprogressbar('end')


end