% script get attributes for stimuli

% ---- constants ----
umToPx = 1.79;

% dir containing movie
% movieDir = '/local0/scratch/ijones/Natural_scenes/birds_bridge/';
movieDir = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Natural_scenes/birds_bridge_ij';
% load frames of movie
% [frames frameCount frameNames] = load_im_frames(movieDir, ...
% 'rot_and_flip' );

% File pattern is used to access files in directory
movieFilePattern = '08*.bmp';
[frames frameCount frameNames] = load_im_frames(movieDir, 'set_frame_count',100, ...
    'movie_file_pattern', movieFilePattern);

% create sharpen filter
sharpFilter = fspecial('unsharp');

% filter frames
for i=1:size(frames,3);   
    frames(:,:,i) = imadjust(imfilter(frames(:,:,i), sharpFilter, 'replicate'));
end

% export filtered frames
for i=1:size(frames,3)
   imwrite(frames(:,:,i),fullfile(movieDir,strcat('natural_scene_BMP-',num2str(1e4+i),'.bmp'  )), 'bmp') ;
   i
end
   
% get surround indices
frameEdgeLength = size(frames,1);
CircleDiameterPix = 300/umToPx;
[indsSurround C] = get_circle_inds(frameEdgeLength, CircleDiameterPix, 'surround');
[indsCtr C] = get_circle_inds(frameEdgeLength, CircleDiameterPix, 'center');

% prepare masks with NaNs in center and surround: surround (e.g.) ...
... contains ones in the surround
maskSurr = single(~C);
maskSurr(find(maskSurr == 0)) = NaN;
maskCtr = single(C);
maskCtr(find(maskCtr == 0)) = NaN;

% initialize median values for surround and center for each frames
allFrameMedianValues = single(zeros(size(frames,3), prod(size(framesSurr))));

clear stimInfo
% get median surround 
for i=1:size(frames,3)
    stimInfo.medianPerFrame(i) = nanmedian(reshape(frames(:,:,i),1, prod(size(frames(:,:,i)))));     
    stimInfo.stdPerFrame(i) = nanstd(double(reshape(frames(:,:,i),1, prod(size(frames(:,:,i))))));     
    allFrameMedianValues(i,:) =  reshape(frames(:,:,i),1, prod(size(frames(:,:,i))));
    i
end

% Get median and std all frames
stimInfo.medianAllFrames = nanmedian(reshape(allFrameMedianValues,1 ... 
    ,prod(size(allFrameMedianValues))));
stimInfo.stdAllFrames = nanstd(reshape(allFrameMedianValues,1 ... 
    ,prod(size(allFrameMedianValues))));

% save movie data info to file
save(fullfile(movieDir,'stimInfo.mat'), 'stimInfo');

%% ------------ Create Stimuli Frames and Save to Image Files -------------
% ----------- Grey Surround ----------
% >>>>>>>>> #1) static surround: median of whole movie >>>>>>>>>

for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of all frames in surround indices 
    tempFrame(indsSurround) = stimInfo.medianAllFrames;
    % name of file
    fileNamePrefix = '01_statSurrAllFr_natural_scene_BMP-';
    imwrite(tempFrame,fullfile(movieDir,strcat(fileNamePrefix, ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end

% >>>>>>>>> #2) flickering surround: median of each frame >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of all frames in surround indices 
    tempFrame(indsSurround) = stimInfo.medianPerFrame(i);
    fileNamePrefix = '02_flickerSurrPerFr_natural_scene_BMP-';
    imwrite(tempFrame,fullfile(movieDir,strcat(fileNamePrefix, ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end
% >>>>>>>>> #3) static surround: wn of all frames >>>>>>>>>
% random noise for surround
brightness =  stimInfo.medianAllFrames;
contrast = stimInfo.stdAllFrames;

% get random values with specified brightness and contrast
surrRandValues = normrnd(brightness,contrast,1,frameCount ));
% clip top and bottom
surrRandValues(find(surrRandValues>255))=255;
surrRandValues(find(surrRandValues<0))=0;

for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of all frames in surround indices 
    
    tempFrame(indsSurround) = surrRandValues(i);
    fileNamePrefix = '03_flickerSurrWN_natural_scene_BMP-';
    imwrite(tempFrame,fullfile(movieDir,strcat(fileNamePrefix, ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end

% ----------- Pixelated Surround ----------
% >>>>>>>>> #4) shuffled of whole movie >>>>>>>>>
% get all pixel values that make up the movie. Then shuffle them; NOTE:
% USES ALL PIXELS OF ALL FRAMES, NOT JUST SURROUND

% shuffle frame pixel values
allFrameMedianValuesShuffled = shuffle_values(allFrameMedianValues);

for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values into surround
    tempFrame(indsSurround) = allFrameMedianValuesShuffled(i,1:length(indsSurround));
    % save data to file
    imwrite(tempFrame,fullfile(movieDir,strcat('04_shuffledAllFr_natural_scene_BMP-', ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end

% >>>>>>>>> #5) shuffled of whole movie >>>>>>>>>
% get all pixel values that make up the movie. Then shuffle them; NOTE:
% USES ALL PIXELS OF ALL OF FRAME, NOT JUST SURROUND

for i=1:frameCount    
    tempFrame = frames(:,:,i);
    
    % shuffle values in one frame
    frameMedianValuesShuffled = shuffle_values(allFrameMedianValues(i,:));
    
    
    % put shuffled values into surround
    tempFrame(indsSurround) = frameMedianValuesShuffled(1,1:length(indsSurround));
    % save data to file
    imwrite(tempFrame,fullfile(movieDir,strcat('05_shuffledEachFr_natural_scene_BMP-', ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end

% >>>>>>>>> #6) white noise of whole movie >>>>>>>>>
brightness =  stimInfo.medianAllFrames;
contrast = stimInfo.stdAllFrames;

for i=1:frameCount    
    tempFrame = frames(:,:,i);
    
    % get random values with specified brightness and contrast
    surrRandValues = round(normrnd(brightness,contrast,1,length(indsSurround) ));
    % clip top and bottom
    surrRandValues(find(surrRandValues>255))=255;
    surrRandValues(find(surrRandValues<0))=0;
    % put rand values into surround
    tempFrame(indsSurround) = surrRandValues;
    % save data to file
    imwrite(tempFrame,fullfile(movieDir,strcat('06_WnAllFr_natural_scene_BMP-', ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end

% >>>>>>>>> #7) white noise of each frame >>>>>>>>>

for i=1:frameCount    
    tempFrame = frames(:,:,i);
    
    brightness =  double(stimInfo.medianPerFrame(i));
    contrast = stimInfo.stdPerFrame(i);
    
    % get random values with specified brightness and contrast
    surrRandValues = round(normrnd(brightness,contrast,1,length(indsSurround) ));
    % clip top and bottom
    surrRandValues(find(surrRandValues>255))=255;
    surrRandValues(find(surrRandValues<0))=0;
    % put rand values into surround
    tempFrame(indsSurround) = surrRandValues;
    % save data to file
    imwrite(tempFrame,fullfile(movieDir,strcat('07_WnEachFr_natural_scene_BMP-', ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end

% >>>>>>>>> #8) shuffle brightness and contrast values between frames >>>>>>>>>

% shuffle brightness and contrast
shuffledBrightness = double(stimInfo.medianPerFrame(randperm(length(stimInfo.medianPerFrame))));
shuffledContrast = stimInfo.stdPerFrame(randperm(length(stimInfo.stdPerFrame)));

for i=1:frameCount    
    tempFrame = frames(:,:,i);
    
    % normalize contrast and brightness using value from all frames
    muDesired =  shuffledBrightness(i);
    contrastDesired = shuffledContrast(i);
    muFr = double(stimInfo.medianPerFrame(i));
    contrastFr = stimInfo.stdPerFrame(i);
    
    % adjust the contrast
    contrastAdjFrame = double(tempFrame(indsSurround))*(contrastDesired/contrastFr);
    % find the brightness difference between this frame and the desired brightness
    % (brightness)
    contrastAdjFrameBrightnessDiff = median(contrastAdjFrame)-muDesired;
    % apply the brightness difference
    tempFrame(indsSurround) = uint8(double(contrastAdjFrame)-contrastAdjFrameBrightnessDiff);

    % save data to file
    imwrite(tempFrame,fullfile(movieDir,strcat('08_ShuffledBrAndContrAllFr_natural_scene_BMP-', ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end

