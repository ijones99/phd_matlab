function outputMat = compare_amplitude_differences(electrodeP2PAmps)
% This function compares groups of values by taking the absolute difference between
% each possible pair and summing these values. The output is a similarity
% matrix.

numVarsInMatrix = length(electrodeP2PAmps);

% init. output square matrix
outputMat = -1*ones(numVarsInMatrix);

% make all possible combinations
allPossibleCombos = combnk(1:numVarsInMatrix ,2);

textprogressbar('start comparing all combos')
resolution = 1;

for i=1:length(allPossibleCombos)
    
   
        outputMat(allPossibleCombos(i,1),allPossibleCombos(i,2)) = ...
      sum(sum(abs(electrodeP2PAmps{allPossibleCombos(i,1)}-electrodeP2PAmps{allPossibleCombos(i,2)})));
        
   
    textprogressbar(100*i/length(allPossibleCombos))

end


for i=1:size(outputMat,1)
    outputMat(i,i) = 0;
    
end


textprogressbar('end')

outputMat(find(outputMat==-1))=max(max(outputMat));

end