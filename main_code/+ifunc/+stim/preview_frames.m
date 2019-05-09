dirName = '~/ln_nas/projects/retina_project/Light_Stimuli/Noise_Movies/Noise_Movie/';
dirName = '/media/ijones/Light_Stimuli_Frames/Noise_Movie/';
figure
for i = 1:1000
    
    fileName = sprintf('frame_%08d.mat',i);
    
    if exist(fullfile(dirName,fileName))
        load(fullfile(dirName,fileName));
        imagesc(frame), colormap(gray)
        title(num2str(i))
        pause(1/20);
    end
end