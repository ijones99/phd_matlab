
%%
% DESCRIPTION:
% This function presents the stimuli contained in file names:
% Two files are read for this function:
%     A file containing the file names that are generated:
%     Output_File_Names_Ctr_Surr.mat
%     A file for each stimulus set: e.g. Stim01_CtrOutOfPhase.mat
% One file is generated for this function:
%     a timestamp file, which contains information regarding when the
%     function was called.
% -------------------------------------------------------------------------
% SETTINGS
 hidens_stopSaving(1,'172.27.34.19')
cd /home/ijones/Experiment/Light_Stimuli/MainFunctions
SAVE_RECORDING = 1;

stimParamDir = '';
STIM_FILES = {...   % Select stimuli to run
    'StimParams_Bars.mat';
    'StimParams_Noise_Movie';
    'StimParams_Noise_Movie_Varying_Contrast';
    'StimParams_Movies';
    
    'StimParams_Marching_Sqr';
    'StimParams_Drifting_Half_Sine';
    'StimParams_10_Wn100PerCheckerboard.mat'
    'StimParams_Random_Dots';
    'StimParams_SpotsIncrSize';
    'StimParams_Sparse_Flashing_Squares';
    };

% -------------------------------------------------------------------------
% CHECK FOR CORRECT DIRECTORY
% should be '/home/ijones/Experiment/Light_Stimuli'
inputVal = input(strcat(['Directory is ',pwd,'. \nPlease press ENTER if correct']));

% -------------------------------------------------------------------------
% TELL USER WHETHER RECORDING WILL OCCUR
if SAVE_RECORDING
    answer = input('Recording is set to ON (press <enter>)\n');
else
    answer = input('Recording is set to OFF (press <enter>)\n');
end
% -------------------------------------------------------------------------
% Load Settings
mainSettings = stim.settings.create_general_settings_file;

%Transition Screen Size
transScrMtx = single(ones(mainSettings.movieEdgeLengthPx));%set # pixels along edge or...

% Init Psychtoolbox
for i=1
    SCREEN_SIZE = get(0,'ScreenSize');

    % KbName('KeyNamesLinux') %run this command to get the
    % names of the keys
    %     RestrictKeysForKbCheck(66) % Restrict response to the space bar

    whichScreen = 0;
    % do screen tests
    Screen('Preference', 'SkipSyncTests', 0)
    % window = Screen('OpenWindow', whichScreen, [0 MID_GRAY_DECI*WHITE_VAL MID_GRAY_DECI*WHITE_VAL 0]);
    [window screenRect] = Screen('OpenWindow', whichScreen, ...
        [0 mainSettings.BLACK_VAL*mainSettings.WHITE_VAL mainSettings.BLACK_VAL*mainSettings.WHITE_VAL 0]);
    % do not use red LED
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,[0,1,1,0]);
    transitionScreen = Screen(window, 'MakeTexture',  double(single(mainSettings.BLACK_VAL)+ ...
        single(mainSettings.MID_GRAY_DECI)*transScrMtx*single(mainSettings.WHITE_VAL) ));
    % show screen
    Screen(window, 'DrawTexture', transitionScreen    );
    Screen(window,'Flip');
    HideCursor
    % Beeps & wait for keyboard input (space bar)
    beep, pause(.3), beep, pause(.3);
    KbWait;
    pause(.5),
end

for iCurrStimFile = 1:length(STIM_FILES)
    % draw transition screen
    Screen(window, 'DrawTexture', transitionScreen    );
    Screen(window,'Flip');
    pause(1);
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND GRAY
    stimFileName = 'StimParams_00_GratingsWnSurrGray.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_00_gratingswnsurrgray(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end


    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND CORR
    stimFileName = 'StimParams_01_GratingsWnSurrCorr.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_01_gratingswnsurrcorr(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end

    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND CORR
    stimFileName = 'StimParams_02_GratingsWnSurrAntiCorr.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_02_gratingswnsurranticorr(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end

    end
    
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: MOVIES
    % ---- constants ----
    stimFileName = 'StimParams_Movies';

    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            pause(mainSettings.delayBetweenStimuli)
            % --------------------------------------------------------------------
            % mouse cage movie, movie 1
            movieDirBirds400 = strcat('~/Movie_Stimuli/birds_bridge_ij/400umAperture');
            movieDirBirds600 = strcat('~/Movie_Stimuli/birds_bridge_ij/600umAperture');
            movieDir_labelb12ariell = strcat('~/Movie_Stimuli/labelb12ariell/500umAperture');
            movieDirMov5 = strcat('/home/ijones/Movie_Stimuli/Mouse_Cage_Movies/Movie5');
            % load Settings
            clear Settings, load(stimFileName)
            for iSeriesRepeat = 1 % each file is shown once
                for iMovies = [1:length(Settings.allMovieFilePatterns) ]
                    
                    % set correct directories
                    if ismember(iMovies, 1:7)
                        movieDir = movieDir_labelb12ariell;
                        % elseif ismember(iMovies, 8)
                        % movieDir = movieDir_labelb12ariell;
                        % else
                        % movieDir = movieDir_labelb12ariell;
                    end
                    
                    movieFilePattern = Settings.allMovieFilePatterns{iMovies};
                    slashLoc = strfind(movieDir,'/');
                    % load frames
                    [frames Settings.frameCount frameNames] = stim.movie.load_im_frames(fullfile(movieDir,movieFilePattern,'') , ...
                        'set_frame_count',Settings.frameCount,  ...
                        'movie_file_pattern', strcat(movieFilePattern,'*.bmp'), ... %, ...
                        'spec_frame_dims_pix', [mainSettings.movieEdgeLengthPx mainSettings.movieEdgeLengthPx]);
                    % use this argument above to rotate and flip: 'rot_and_flip',
                    stim.file.write_log(strcat([movieDir(slashLoc(end-1):end),movieFilePattern,' movie']),'pre');%log file start stimulus
                    
                    for recStart = 1
                        if SAVE_RECORDING
                            paramex(0);
                            hidens_startSaving(1,'172.27.34.19')
                            pause(.2)
                        end
                    end% Start recording
                    % run stimulus
                    stim.movie.play_movie(window, frames, Settings.frameCount, Settings.frameRate, ...
                        Settings.clipRepeatCount, Settings.delayBetweenStimulusRepeats,mainSettings);
                    
                    for recStop=1
                        if SAVE_RECORDING
                            hidens_stopSaving(1,'172.27.34.19')
                            pause(.2)
                        end
                    end% stop recording
                    
                    stim.file.write_log(strcat([movieDir(slashLoc(end-1):end), movieFilePattern,' movie']),'post');%log file end stimulus
                    pause(Settings.delayBetweenStimulusSeriesRepeats)
                end
            end
            
        end
    end
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND CORR
    stimFileName = 'StimParams_03_GratingsWnSurrUnCorr.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_03_gratingswnsurruncorr(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end

    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WN, SURROUND CHECKERBOARD
    stimFileName = 'StimParams_06_GratingsWnSurrCheckerboard.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));
            load('white_noise_frames.mat');
            StimMats.white_noise_frames = white_noise_frames; clear white_noise_frames;

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_06_gratingswnsurrcheckerboard(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end

    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: SLITS
    stimFileName = 'StimParams_Slits.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_slits(window,Settings,StimMats,screenRect)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: BARS
    stimFileName = 'StimParams_Bars.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            clear Settings StimMats
            % load stimulus data
            pause(mainSettings.delayBetweenStimuli)
            load(fullfile(stimParamDir,stimFileName));
            Settings.f = 60;
            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.1)
                end
            end% Start recording

            % run stimulus
            stim.bars.stim_bars(window,Settings,screenRect)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.1)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end
    end

     % -------------------------------------------------------------------------
    % STIMULUS TYPE: DRIFTING HALF SINE WAVE
    stimFileName = 'StimParams_Drifting_Half_Sine';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            clear Settings StimMats
            % load stimulus data
            pause(mainSettings.delayBetweenStimuli)
            load(fullfile(stimParamDir,stimFileName));
            Settings.f = 60;
            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.1)
                end
            end% Start recording

            % run stimulus
            stim.sine.stim_drifting_half_sine(window,Settings,screenRect)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.1)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: SPOTS INCREASE IN SIZE
    stimFileName = 'StimParams_SpotsIncrSize.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            pause(mainSettings.delayBetweenStimuli)
            clear Settings StimMats %
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_spotsincrsize(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    
     % -------------------------------------------------------------------------
    % STIMULUS TYPE: MARCHING SQUARE
    stimFileName = 'StimParams_Marching_Sqr';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            pause(mainSettings.delayBetweenStimuli)
            % clear data
            clear Settings StimMats
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            fprintf('before function')
            stim.marching_sqr.stim_marching_sqr(Settings, window)
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: WHITE NOISE 25 PERCENT CHECKERBOARD
    stimFileName = 'StimParams_08_Wn25PerCheckerboard.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            pause(mainSettings.delayBetweenStimuli)
            load(fullfile(stimParamDir,stimFileName));

            ccc                                                                                                  ccao
            load('white_noise_frames.mat');

            load(fullfile(stimParamDir,stimFileName));

            StimMats.white_noise_frames = white_noise_frames(:,:,:); clear white_noise_frames;
            pixTransferFuncDir = '';
            % load pixel transfer function
            load(fullfile(pixTransferFuncDir, 'lookupTbMean_ND2_norm.mat'));
            Settings.BLACK_VAL = 0;
            Settings.WHITE_VAL = apply_projector_transfer_function_nearest_neighbor(255,lookupTbMean_ND2_norm);
            Settings.LIGHT_GRAY_25PER_VAL = apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm);% 25 percent above middle gray;
            Settings.DARK_GRAY_75PER_VAL = apply_projector_transfer_function_nearest_neighbor(255*1/8,lookupTbMean_ND2_norm);
            Settings.DARK_GRAY_25PER_VAL = apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm);% 25 percent above middle gray;

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim_08_wn25percheckerboard(window,Settings,StimMats)
            tocTime = toc
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            kbWait
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
     % -------------------------------------------------------------------------
    % STIMULUS TYPE: WHITE NOISE Test CHECKERBOARD
    stimFileName = 'StimParams_09_WnCheckerboardTest.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            pause(mainSettings.delayBetweenStimuli)
            load(fullfile(stimParamDir,stimFileName));
            load('white_noise_frames_test.mat');

            load(fullfile(stimParamDir,stimFileName));

            StimMats.white_noise_frames = white_noise_frames(:,:,:); clear white_noise_frames;
            pixTransferFuncDir = 'DataFiles/';
            % load pixel transfer function
            load(fullfile(pixTransferFuncDir, 'lookupTbMean_ND2_norm.mat'));
            Settings.BLACK_VAL = 0;
            Settings.WHITE_VAL = apply_projector_transfer_function_nearest_neighbor(255,lookupTbMean_ND2_norm);
            Settings.LIGHT_GRAY_25PER_VAL = apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm);% 25 percent above middle gray;
            Settings.DARK_GRAY_75PER_VAL = apply_projector_transfer_function_nearest_neighbor(255*1/8,lookupTbMean_ND2_norm);
            Settings.DARK_GRAY_25PER_VAL = apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm);% 25 percent above middle gray;

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim_09_wn_test_checkerboard(window,Settings,StimMats)
            tocTime = toc
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            kbWait
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: WHITE NOISE Test CHECKERBOARD
    stimFileName = 'StimParams_10_Wn100PerCheckerboard.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % clear stimulus data
            clear Settings StimMats 
            % load stimulus data
            pause(mainSettings.delayBetweenStimuli)
            load('white_noise_frames.mat');
            load(fullfile(stimParamDir,stimFileName));

            StimMats.white_noise_frames = white_noise_frames(:,:,:); clear white_noise_frames;

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim.wn_checkerboard.stim_checkerboard(window,Settings,StimMats)
            tocTime = toc
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            kbWait
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: NOISE MOVIE
    stimFileName = 'StimParams_Noise_Movie';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % clear stimulus data
            clear Settings StimMats 
            % load stimulus data
            pause(mainSettings.delayBetweenStimuli)
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim.noise_movie.stim_noise_movie(window,Settings)
            tocTime = toc
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            kbWait
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: NOISE MOVIE
    stimFileName = 'StimParams_Noise_Movie_Varying_Contrast';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % clear stimulus data
            clear Settings StimMats 
            % load stimulus data
            pause(mainSettings.delayBetweenStimuli)
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim.noise_movie.stim_noise_movie(window,Settings)
            tocTime = toc
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            kbWait
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: NOISE MOVIE
    stimFileName = 'StimParams_Sparse_Flashing_Squares';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % clear stimulus data
            clear Settings StimMats 
            % load stimulus data
            pause(mainSettings.delayBetweenStimuli)
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim.noise_movie.stim_noise_movie(window,Settings)
            tocTime = toc
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            kbWait
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: RANDOM DOTS
    stimFileName = 'StimParams_Random_Dots';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % clear stimulus data
            clear Settings StimMats 
            % load stimulus data
            pause(mainSettings.delayBetweenStimuli)
            load(fullfile(stimParamDir,stimFileName));

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim.noise_movie.stim_noise_movie(window,Settings)
            tocTime = toc
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            kbWait
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: WHITE NOISE 60 PERCENT CHECKERBOARD
    stimFileName = 'StimParams_09_Wn60PerCheckerboard';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));
            load('white_noise_frames.mat');

            load(fullfile(stimParamDir,stimFileName));

            StimMats.white_noise_frames = white_noise_frames; clear white_noise_frames;

            Settings.LIGHT_GRAY_60PER_DECI = Settings.MID_GRAY_DECI + ...
                (1 - Settings.MID_GRAY_DECI)*0.60;

            Settings.DARK_GRAY_60PER_DECI = Settings.MID_GRAY_DECI - ...
                (1 - Settings.MID_GRAY_DECI)*0.60;

            stim.file.write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim_09_wn60percheckerboard(window,Settings,StimMats)
            endTime = toc
            save tocTime.mat endTime
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            stim.file.write_log(stimFileName,'post');%log file end stimulus
            pause(mainSettings.END_EXP_PAUSE)
        end
    end
    % -------- CLOSE OPEN WINDOWS ---------
    iCurrStimFile
end
kbWait
Screen('CloseAll');
