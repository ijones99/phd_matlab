dirNameTo = '/media/ijones/Light_Stimuli_Frames/Noise_Movie/';
dirNameFrom = '~/ln_nas/projects/retina_project/Light_Stimuli/Noise_Movies/Noise_Movie/';

chunkSize = 1000;
numChunks = 100;
startVal = repmat(chunkSize,1,numChunks); startVal(1) = 1; startVal = cumsum(startVal);
endVal = repmat(chunkSize,1,numChunks); endVal(1) = 30; endVal = cumsum(endVal);

for i = 1:54000
    currName = sprintf('frame_%08d.mat',i);
    if ~exist(fullfile(dirNameTo,currName))
        eval([sprintf('!cp %s%s %s', dirNameFrom, currName, dirNameTo)]);
        if i/100 == round(i/100)
            i
        end
    end
end




dirNameTo = '/media/ijones/Light_Stimuli_Frames/Noise_Movie_Contrast_Vary/';
dirNameFrom = '~/ln_nas/projects/retina_project/Light_Stimuli/Noise_Movies/Noise_Movie_Contrast_Vary/';

chunkSize = 1000;
numChunks = 100;
startVal = repmat(chunkSize,1,numChunks); startVal(1) = 1; startVal = cumsum(startVal);
endVal = repmat(chunkSize,1,numChunks); endVal(1) = 30; endVal = cumsum(endVal);

for i = 1:54000
    currName = sprintf('frame_%08d.mat',i);
    if ~exist(fullfile(dirNameTo,currName))
        eval([sprintf('!cp %s%s %s', dirNameFrom, currName, dirNameTo)]);
         if i/100 == round(i/100)
            i
        end
    end
end

