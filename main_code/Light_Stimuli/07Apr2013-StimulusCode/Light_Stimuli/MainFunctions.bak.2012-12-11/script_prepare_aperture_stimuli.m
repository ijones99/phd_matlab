% script get attributes for stimuli

% ---- constants ----
umToPx = 2;
frameEdgeLength = 600;
movieFilePattern = '*.bmp';
frameCount = 900;
circleDiameterUm = 600;

% dir containing movie
% movieDir = '/local0/scratch/ijones/Natural_scenes/birds_bridge/';
allMoviesDir = '/home/ijones/Movie_Stimuli/birds_bridge_ij/600umAperture/';
origMovieDir = '/home/ijones/Movie_Stimuli/birds_bridge_ij/600umAperture/Original_Movie/';
pixTransferFuncDir = '/home/ijones/Matlab/Equipment/Projector';
% load frames of movie
% [frames frameCount frameNames] = load_im_frames(allMoviesDir, ...
% 'rot_and_flip' );

% load 1 frame to get dims
[framesTemp frameCountTemp frameNamesTemp originalImDims] = ...
    load_im_frames(origMovieDir, 'set_frame_count',1, ...
    'movie_file_pattern', movieFilePattern);

% get surround indices

CircleDiameterPix = circleDiameterUm/umToPx;
[indsSurround C] = get_circle_inds(frameEdgeLength, CircleDiameterPix, 'surround');
[indsCtr C] = get_circle_inds(frameEdgeLength, CircleDiameterPix, 'center');

% scale indices to new dims
C = imresize(C, [originalImDims]);
indsSurround = find(C == 0);
indsCtr = find(C > 0);

[frames frameCount frameNames originalImDims] = ...
    load_im_frames(origMovieDir, 'set_frame_count',frameCount, ...
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
% load(fullfile(pixTransferFuncDir, 'polyFitCoeff.mat'));

%% ------------ Create Stimuli Frames and Save to Image Files -------------
% ----------- Orig Movie ----------
% >>>>>>>>> #1) orig movie (w/ trans function) >>>>>>>>>

for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    
    % specific stimulus movie dir
    specificMovieDir = 'Original_Movie';
    
    % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);

    i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));
% ----------- Grey Surround ----------
%% >>>>>>>>> #2) static surround: median of whole movie >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of all frames in surround indices 
    tempFrame(indsSurround) = stimInfo.medianAllFrames;
    % apply transfer function
    tempFrame = uint8(tempFrame);

    % specific stimulus movie dir
    specificMovieDir = 'Stat_Surr_Median_Whole_Movie';

    % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);

    i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));
%% >>>>>>>>> #3) static surround: mean of whole movie >>>>>>>>>
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
       % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);
    i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

%% >>>>>>>>> #4) dynamic surrond surround: median of each frame >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of each frame in surround indices 
    tempFrame(indsSurround) = stimInfo.medianPerFrame(i);
    specificMovieDir = 'Dynamic_Surr_Median_Each_Frame';

 % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i,...
        'resize_im', [frameEdgeLength frameEdgeLength]);
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

%% >>>>>>>>> #5) flickering surround: mean of each frame >>>>>>>>>
for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median value of each frame in surround indices 
    tempFrame(indsSurround) = stimInfo.meanPerFrame(i);
    specificMovieDir = 'Dynamic_Surr_Mean_Each_Frame';

    % save to file
       % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

%% >>>>>>>>> #6) flickering surround: shuffled median of each frame >>>>>>>>>
medianPerFrameVals = shuffle_values(stimInfo.medianPerFrame);

for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put median shuffled value of each frame in surround indices 
    tempFrame(indsSurround) = medianPerFrameVals(i);
    specificMovieDir = 'Dynamic_Surr_Shuffled_Median_Each_Frame';

    % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im', ...
        [frameEdgeLength frameEdgeLength]);
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

%% >>>>>>>>> #7) flickering surround: shuffled mean of each frame >>>>>>>>>
meanPerFrameVals = shuffle_values(stimInfo.meanPerFrame);

for i=1:frameCount
    % use temp vector
    tempFrame = frames(:,:,i);
    % put mean shuffled value of each frame in surround indices 
    tempFrame(indsSurround) = meanPerFrameVals(i);
    specificMovieDir = 'Dynamic_Surr_Shuffled_Mean_Each_Frame';

    % save to file
       % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);
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
        % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

% >>>>>>>>> #9) shuffled pixels of each frame >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround) );

    specificMovieDir = 'Pixelated_Surr_Shuffled_100_Percent_Each_Frame';

       % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);
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
%     apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i, 'resize_im', [600 600]);;i
    % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);
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
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

%% >>>>>>>>> #12) shuffled pixels of each frame 10% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',10 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_10_Percent_Each_Frame';

     % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im', ...
        [frameEdgeLength frameEdgeLength]);

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

%% >>>>>>>>> #13) shuffled pixels of each frame 25% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',25 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_25_Percent_Each_Frame';

       % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));


%% >>>>>>>>> #13) shuffled pixels of each frame 50% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',50 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_50_Percent_Each_Frame';

     % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im', ...
        [frameEdgeLength frameEdgeLength]);
    i
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

%% >>>>>>>>> #14) shuffled pixels of each frame 75% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',75 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_75_Percent_Each_Frame';

        % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im',...
        [frameEdgeLength frameEdgeLength]);
end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));

%% >>>>>>>>> #15) shuffled pixels of each frame 90% >>>>>>>>>
% USES ONLY SURROUND VALUES
for i=1:frameCount    
    % temporary frame
    tempFrame = frames(:,:,i);
    % put shuffled values of each frame into surround
    tempFrame(indsSurround) = shuffle_values( tempFrame(indsSurround),'percent_shuffle',90 );

    specificMovieDir = 'Pixelated_Surr_Shuffled_90_Percent_Each_Frame';

     % save to file
    save_movie_to_file(tempFrame, specificMovieDir, allMoviesDir, i, 'resize_im', ...
        [frameEdgeLength frameEdgeLength]);

end
fprintf(strcat(['Done with ', specificMovieDir,'\n']));



