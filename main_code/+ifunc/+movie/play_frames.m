dirName = '/home/ijones/ln_nas/projects/retina_project/Light_Stimuli/Noise_Movies/Noise_Movie_Contrast_Vary/';
numFrames = 3000;
frameRate = 30;
frameDur = 1/frameRate;
figure

for i=1:numFrames
    if exist(fullfile(dirName, sprintf('frame_%08d.mat', i)))
        load(fullfile(dirName, sprintf('frame_%08d.mat', i)))
            
        imagesc(frame)
        axis square
        colormap(gray)
        
    end
    pause(frameDur)
    
end



