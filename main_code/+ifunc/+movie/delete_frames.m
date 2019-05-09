dirName = '/home/ijones/ln_nas/projects/retina_project/Light_Stimuli/Noise_Movies/Noise_Movie/';

chunkSize = 1000;
numChunks = 260;
startVal = repmat(chunkSize,1,numChunks); startVal(1) = 1; startVal = cumsum(startVal);
endVal = repmat(chunkSize,1,numChunks); endVal(1) = 26; endVal = cumsum(endVal);
selOperation = 'rm';

for i = 1:numChunks
    
    eval([sprintf('!%s %sframe_{%08d..%08d}.mat',selOperation, dirName,startVal(i),endVal(i))])
    i
    
end