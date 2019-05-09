movieDuration = 30; %mins
frameRate_Hz = 30;
nFramesChunk = 1000;
nChunks = ceil(movieDuration*60*frameRate_Hz/nFramesChunk);

dirName.norm = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Light_Stimuli/Noise_Movies/Noise_Movie'; mkdir(dirName.norm )
dirName.contrast = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Light_Stimuli/Noise_Movies/Noise_Movie_Contrast_Vary';mkdir(dirName.contrast);


iFrameCounter = 1;

for i=1:27000
    % get frames
    tic
    [movieFiltSpatTemp movieFiltSpatTempContrastVary] = ...
        ifunc.stim_gen.create_noise_movie_frames('nFrames',nFramesChunk,'frameRate_Hz',frameRate_Hz);
    % save frames
    for j = 1:nFramesChunk
        % save frames for movie
        frame = movieFiltSpatTemp(:,:,j);
        save(fullfile(dirName.norm, sprintf('frame_%08d.mat', iFrameCounter)),'frame');
        
        % save frames for contrast-varying movie
        frame = movieFiltSpatTempContrastVary(:,:,j);
        save(fullfile(dirName.contrast, sprintf('frame_%08d.mat', iFrameCounter)),'frame');
        iFrameCounter = iFrameCounter+1
        fprintf('Percent done: %3.0f\n', 100*iFrameCounter/(nChunks*nFramesChunk));

    end
    chunkElapsedTime = toc/60;
    fprintf('Time elapsed for 1 chunk %d minutes',chunkElapsedTime);
        
end



