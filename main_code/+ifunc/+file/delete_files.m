

input = input('delete files?')

%%
dirName = '/media/ijones/Light_Stimuli_Frames/Noise_Movie_Contrast_Vary/';
chunkSize = 1000;
numChunks = 100;
startVal = repmat(chunkSize,1,numChunks); startVal(1) = 1; startVal = cumsum(startVal);
endVal = repmat(chunkSize,1,numChunks); endVal(1) = 30; endVal = cumsum(endVal);

for i = 1:numChunks
    
    eval([sprintf('!rm %sframe_{%08d..%08d}.mat',dirName,startVal(i),endVal(i))])
    i
end