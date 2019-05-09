function outputMat = compare_waveforms(inputWaveforms)


numWaveforms = length(inputWaveforms);

outputMat = zeros(numWaveforms);

allPossibleCombos = combnk(1:numWaveforms ,2);

textprogressbar('start comparing all combos')

resolution = 1;

for i=1:length(allPossibleCombos)
    
   
        outputMat(allPossibleCombos(i,1),allPossibleCombos(i,2)) = ...
            sum(sum(abs((inputWaveforms{allPossibleCombos(i,1)}-...
            (inputWaveforms{allPossibleCombos(i,2)})))));
        
   
    textprogressbar(100*i/length(allPossibleCombos))

end
textprogressbar('end')


end