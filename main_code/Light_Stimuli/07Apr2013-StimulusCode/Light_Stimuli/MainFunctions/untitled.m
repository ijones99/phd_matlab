dirName = '~/ln_nas/projects/retina_project/Light_Stimuli/Noise_Movies/Noise_Movie_Contrast_Vary/';
figure
for i = 1:1000
    fileName = sprintf('frame_%08d.mat',i);
    load(fullfile(dirName,fileName));
    imagesc(frame), colormap(gray)
    pause(0.033);
    
end