nFrames = 100;
stimEdgeLengthPx = 750;
dirName = '~/Movie_Stimuli/Noise_Movie/Movie01/';

for i=1:nFrames
    frame = uint8(rand(stimEdgeLengthPx)*255);
    fileName = sprintf('frame%08d.mat',i);
    save(fullfile(dirName,fileName),'frame');
    
    i
    
end