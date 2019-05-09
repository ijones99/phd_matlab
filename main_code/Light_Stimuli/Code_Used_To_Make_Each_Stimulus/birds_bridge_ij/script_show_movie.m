% Script Show Stimuli
%% Stimulus preparation
% ------- Constants -----------
frameRate = 30; % Movie playback rate in frames/sec
clipRepeatCount = 1;
delayBetweenRepeats = 0; % seconds
frameCount = 50; % if specifying number of frames


movieDir = strcat('/local0/scratch/ijones/Natural_Movie_Frames/birds_bridge/');


%% Start playing stimuli

% #1) NEW STIM: movie with median of whole movie surround
% ---- constants ----
allMovieFilePatterns = {'ss_ma*.bmp' 'ds_me*.bmp' 'ds_ma*.bmp' ...
    'ps_ra*.bmp' 'ps_re*.bmp' 'ps_wn*.bmp' ...
    'ps_wne*.bmp' 'ps_rbc*.bmp' 'ps_wne*.bmp' ...
    'natural*.bmp'};
movieFilePattern = allMovieFilePatterns{5};
% clear frames
clear frames
% load frames
[frames frameCount frameNames] = load_im_frames(movieDir, ...
    'set_frame_count',900, 'movie_file_pattern', movieFilePattern);

%% play movie
play_movie(frames, frameCount, frameRate, clipRepeatCount, delayBetweenRepeats);

