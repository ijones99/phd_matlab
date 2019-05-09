% script get attributes for stimuli

% ---- constants ----
umToPx = 1.72;
frameEdgeLength = 600;
movieFilePattern = '*.bmp';
frameCount = 900;

% dir containing movie
% movieDir = '/local0/scratch/ijones/Natural_scenes/birds_bridge/';
allMoviesDir = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Light_Stimuli/Natural_scenes/birds_bridge_ij';
origMovieDir = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Light_Stimuli/Natural_scenes/birds_bridge';
pixTransferFuncDir = '/home/ijones/Matlab/Equipment/Projector';
% load frames of movie
% [frames frameCount frameNames] = load_im_frames(allMoviesDir, ...
% 'rot_and_flip' );

% load 1 frame to get dims
[framesTemp frameCountTemp frameNamesTemp originalImDims] = load_im_frames(origMovieDir, 'set_frame_count',1, ...
    'movie_file_pattern', movieFilePattern);

% get surround indices

CircleDiameterPix = 300/umToPx;
[indsSurround C] = get_circle_inds(frameEdgeLength, CircleDiameterPix, 'surround');
[indsCtr C] = get_circle_inds(frameEdgeLength, CircleDiameterPix, 'center');

% scale indices to new dims
C = imresize(C, [originalImDims]);
indsSurround = find(C == 0);
indsCtr = find(C > 0);

[frames frameCount frameNames originalImDims] = load_im_frames(origMovieDir, 'set_frame_count',frameCount, ...
    'movie_file_pattern', movieFilePattern, 'spec_frame_dims_pix', [originalImDims]);



% prepare masks with NaNs in center and surround: surround (e.g.) ...
... contains ones in the surround
maskSurr = single(~C);
maskSurr(find(maskSurr == 0)) = NaN;
maskCtr = single(C);
maskCtr(find(maskCtr == 0)) = NaN;

% initialize median values for surround and center for each frames
allFrameValues = single(zeros(size(frames,3), prod(size(frames(:,:,1)))));

clear stimInfo
% get median & mean of surround 
for i=1:size(frames,3)
    tempFrames = frames(:,:,i);
    stimInfo.medianPerFrame(i) = median(tempFrames(:));     
    stimInfo.meanPerFrame(i) = mean(tempFrames(:));
    stimInfo.stdPerFrame(i) = std(double(tempFrames(:)));     
    allFrameValues(i,:) =  tempFrames(:);
    i
end

% Get median, mean and std all frames
stimInfo.medianAllFrames = median(allFrameValues(:));
stimInfo.meanAllFrames = mean(allFrameValues(:));
stimInfo.stdAllFrames = std(allFrameValues(:));

% save movie data info to file
save(fullfile(allMoviesDir,'stimInfo.mat'), 'stimInfo');

% load pixel transfer function
load(fullfile(pixTransferFuncDir, 'polyFitCoeff.mat'));

%% ------------ Create Stimuli Frames and Save to Image Files -------------
% ----------- Orig Movie ----------

% >>>>>>>>> #4) dynamic surrond surround: median of each frame >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of each frame in surround indices 
    tempFrame(indsSurround) = stimInfo.medianPerFrame(i);
    specificMovieDir = 'Dynamic_Surr_Median_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i, 'resize_im', [600 600]);;i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));



% >>>>>>>>> #6) flickering surround: shuffled median of each frame >>>>>>>>>
medianPerFrameVals = shuffle_values(stimInfo.medianPerFrame);

for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median shuffled value of each frame in surround indices 
    tempFrame(indsSurround) = medianPerFrameVals(i);
    specificMovieDir = 'Dynamic_Surr_Shuffled_Median_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i, 'resize_im', [600 600]);;i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));



% >>>>>>>>> #10) shuffle brightness and contrast values between frames >>>>>>>>>

% shuffle brightness and contrast
shuffledBrightness = shuffle_values(stimInfo.medianPerFrame);
shuffledContrast = shuffle_values(stimInfo.stdPerFrame);

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
    tempFrame(indsSurround) = uint8(double(contrastAdjFrame)-double(contrastAdjFrameBrightnessDiff));
    specificMovieDir = 'Surr_Indep_Shuffled_Median_and_Std';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i, 'resize_im', [600 600]);;i
end





