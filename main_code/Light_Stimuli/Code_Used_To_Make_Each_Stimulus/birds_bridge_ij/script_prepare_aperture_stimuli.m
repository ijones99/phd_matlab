% script get attributes for stimuli

% ---- constants ----
umToPx = 1.72;

% dir containing movie
% movieDir = '/local0/scratch/ijones/Natural_scenes/birds_bridge/';
allMoviesDir = '/local0/scratch/ijones/Natural_Movie_Frames/birds_bridge';
allMoviesDir = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Light_Stimuli/Natural_scenes/birds_bridge_ij/';
origMovieDir = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Light_Stimuli/Natural_scenes/birds_bridge';
pixTransferFuncDir = '/home/ijones/Matlab/Equipment/Projector/';
% load frames of movie
% [frames frameCount frameNames] = load_im_frames(allMoviesDir, ...
% 'rot_and_flip' );

% File pattern is used to access files in directory
movieFilePattern = 'natural*.bmp';
[frames frameCount frameNames] = load_im_frames(origMovieDir, 'set_frame_count',900, ...
    'movie_file_pattern', movieFilePattern);

% % create sharpen filter
% sharpFilter = fspecial('unsharp');
% 
% % filter frames
% for i=1:size(frames,3);   
%     frames(:,:,i) = imadjust(imfilter(frames(:,:,i), sharpFilter, 'replicate'));
% end
% 
% % export filtered frames: movie
% for i=1:size(frames,3)
%    imwrite(frames(:,:,i),fullfile(origMovieDir,strcat('mov_natural_scene_BMP-',num2str(1e4+i),'.bmp'  )), 'bmp') ;
%    i
% end
   
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
allFrameValues = single(zeros(size(frames,3), prod(size(frames(:,:,1)))));

clear stimInfo
% get median & mean of surround 
for i=1:size(frames,3)
    tempFrames = frames(:,:,i);
    stimInfo.medianPerFrame(i) = nanmedian(tempFrames(:));     
    stimInfo.meanPerFrame(i) = nanmean(tempFrames(:));
    stimInfo.stdPerFrame(i) = nanstd(double(tempFrames(:)));     
    allFrameValues(i,:) =  tempFrames(:);
    i
end

% Get median, mean and std all frames
stimInfo.medianAllFrames = nanmedian(allFrameValues(:));
stimInfo.meanAllFrames = nanmean(allFrameValues(:));
stimInfo.stdAllFrames = nanstd(allFrameValues(:));

% save movie data info to file
save(fullfile(allMoviesDir,'stimInfo.mat'), 'stimInfo');

% load pixel transfer function
load(fullfile(pixTransferFuncDir, 'polyFitCoeff.mat'));

%% ------------ Create Stimuli Frames and Save to Image Files -------------
% ----------- Orig Movie ----------
% >>>>>>>>> #1) orig movie (w/ trans function) >>>>>>>>>
frameCount = 900;
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    
    % specific stimulus movie dir
    specificMovieDir = 'Original_Movie';
    
    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);

    i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));
% ----------- Grey Surround ----------
% >>>>>>>>> #2) static surround: median of whole movie >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of all frames in surround indices 
    tempFrame(indsSurround) = stimInfo.medianAllFrames;
    % apply transfer function
    tempFrame = uint8(apply_projector_transfer_function(single(tempFrame),p));

    % specific stimulus movie dir
    specificMovieDir = 'Stat_Surr_Median_Whole_Movie';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);

    i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));
% >>>>>>>>> #3) static surround: mean of whole movie >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of all frames in surround indices 
    tempFrame(indsSurround) = stimInfo.meanAllFrames;
    
    % apply transfer function
    tempFrame = uint8(apply_projector_transfer_function(single(tempFrame),p));

    % specific stimulus movie dir
    specificMovieDir = 'Stat_Surr_Mean_Whole_Movie';
    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i 
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% >>>>>>>>> #4) dynamic surrond surround: median of each frame >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of each frame in surround indices 
    tempFrame(indsSurround) = stimInfo.medianPerFrame(i);
    specificMovieDir = 'Dynamic_Surr_Median_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% >>>>>>>>> #5) flickering surround: mean of each frame >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of each frame in surround indices 
    tempFrame(indsSurround) = stimInfo.meanPerFrame(i);
    specificMovieDir = 'Dynamic_Surr_Mean_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i
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
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% >>>>>>>>> #7) flickering surround: shuffled mean of each frame >>>>>>>>>
meanPerFrameVals = shuffle_values(stimInfo.meanPerFrame);

for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put mean shuffled value of each frame in surround indices 
    tempFrame(indsSurround) = meanPerFrameVals(i);
    specificMovieDir = 'Dynamic_Surr_Shuffled_Mean_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% ----------- Pixelated Surround ----------
% >>>>>>>>> #8) shuffled pixels of whole movie >>>>>>>>>
% get all pixel values that make up the movie. Then shuffle them; NOTE:
% USES ALL PIXELS OF ALL FRAMES, NOT JUST SURROUND

% shuffle frame pixel values
allFrameValuesShuffled = shuffle_values(allFrameValues);

for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values into surround
    tempFrame(indsSurround) = allFrameValuesShuffled(i,1:length(indsSurround));

    specificMovieDir = 'Pixelated_Surr_Shuffled_Whole_Movie';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% >>>>>>>>> #9) shuffled pixels of each frame >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround) );

    specificMovieDir = 'Pixelated_Surr_Shuffled_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i

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
    specificMovieDir = 'Pixelated_Surr_Indep_Shuffled_Median_and_Std';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i
end

% >>>>>>>>> #11) shuffled pixels of each frame 5% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',5 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_05_Percent_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% >>>>>>>>> #12) shuffled pixels of each frame 10% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',10 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_10_Percent_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% >>>>>>>>> #13) shuffled pixels of each frame 25% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',25 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_25_Percent_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));


% >>>>>>>>> #13) shuffled pixels of each frame 50% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',50 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_50_Percent_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% >>>>>>>>> #14) shuffled pixels of each frame 75% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',75 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_75_Percent_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% >>>>>>>>> #15) shuffled pixels of each frame 90% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',90 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_90_Percent_Each_Frame';

    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));



% >>>>>>>>> #3) flickering surround: wn of all frames >>>>>>>>>
% random noise for surround% >>>>>>>>> #3) static surround: mean of whole movie >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames75
    ,:,i);
    % put median value of all frames in surround indices 
    tempFrame(indsSurround) = stimInfo.meanAllFrames;
    
    % apply transfer function
    tempFrame = uint8(apply_projector_transfer_function(single(tempFrame),p));

    % specific stimulus movie dir
    specificMovieDir = 'Stat_Surr_Mean_Whole_Movie';
    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);i 
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));
% all pixels equal to same value
brightness =  stimInfo.medianAllFrames;
contrast = stimInfo.stdAllFrames;

% get random values with specified brightness and contrast
surrRandValues = normrnd(brightness,contrast,1,frameCount );
% clip top and bottom
surrRandValues(find(surrRandValues>255))=255;
surrRandValues(find(surrRandValues<0))=0;

for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of all frames in surround indices 
    
    tempFrame(indsSurround) = surrRandValues(i);
    % file name: dynamic surround, median all frames
    fileNamePrefix = 'ds_ma_natural_scene_BMP-';
    imwrite(tempFrame,fullfile(allMoviesDir,strcat(fileNamePrefix, ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end



% >>>>>>>>> #5) shuffled of whole movie >>>>>>>>>
% get all pixel values that make up the movie. Then shuffle them; NOTE:
% USES ALL PIXELS OF ALL OF FRAME, NOT JUST SURROUND

for i=1:frameCount    
    tempFrame = frames(:,:,i);
    
    % shuffle values in one frame
    frameMedianValuesShuffle= shuffle_values(allFrameValues(i,:));
    
    
    % put shuffled values into surround
    tempFrame(indsSuround) = frameMedianValuesShuffled(1,1:length(indsSurround));
    % save data to file: pixelated surround, random each frame
    imwrite(tempFrame,fullfile(allMoviesDir,strcat('ps_re_natural_scene_BMP-', ...
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
    % save data to file: white noise, all frames
    imwrite(tempFrame,fullfile(allMoviesDir,strcat('ps_wn_WnAllFr_natural_scene_BMP-', ...
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
    % save data to file: white noise, each frame
    imwrite(tempFrame,fullfile(allMoviesDir,strcat('ps_wne_natural_scene_BMP-', ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;
    i
end



% >>>>>>>>> #9) whole field: white noise
% >>>>>>>>>
for i=1:frameCount 
    
    % ----- const settings -----
    brightness =  150;
    contrast = 200;
    edgeLengthSize = 600;
    numPixelsEdge = 10;
    
    % get random values with specified brightness and contrast
    tempFrame = make_whitenoise_frame(brightness, contrast, edgeLengthSize, numPixelsEdge);
    
    % save data to file: white noise, each frame, full field
    imwrite(tempFrame,fullfile(allMoviesDir,strcat('ps_rbc_natural_scene_BMP-', ...
        num2str(1e4+i),'.bmp'  )), 'bmp') ;


end