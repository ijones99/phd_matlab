% script: Notes on Natural Stimuli

% get info about movie frames: e.g. median of each frame and whole movie
script_get_attributes_for_stimuli

% script to run the stimuli
script_show_stimuli_main

% loads in the frames
[frames frameCount frameNames] = load_im_frames(movieDir,'rot_and_flip', ...
    'set_frame_count',30, 'movie_file_pattern', movieFilePattern);
[frames frameCount frameNames] = load_im_frames(movieDir, ...
    'set_frame_count',900, 'movie_file_pattern', movieFilePattern);

% shuffle pixel values
% Function: retains matrix dimensions
shuffle_values(pixels,'percent_shuffle', .5)

% create white noise
frame = make_whitenoise_frame(brightness, contrast, edgeLengthSize, numPixelsEdge)

% apply transfer function for projector and save frames to file
apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i)

% transfer function
tempFrame = uint8(apply_projector_transfer_function(single(tempFrame),p));

% create movies (avi) from image frames
script_create_movies_from_frames.m