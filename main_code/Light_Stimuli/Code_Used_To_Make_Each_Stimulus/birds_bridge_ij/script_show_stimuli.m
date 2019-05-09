%%
% DESCRIPTION:
% This function presents the stimuli contained in file names:
% Two files are read for this function:
%     A file containing the file names that are generated: Output_File_Names_Ctr_Surr.mat
%     A file for each stimulus set: e.g. Stim01_CtrOutOfPhase.mat
% One file is generated for this function:
%     a timestamp file, which contains information regarding when the
%     function was called.

% -------------------------------------------------------------------------
% SETTINGS
SAVE_RECORDING = 0;
% Select stimuli to run
stimParamDir = '';
STIM_FILES = {...
    %         'StimParams_Bars.mat'...
    %         'StimParams_SpotsIncrSize.mat'... % 7 mins
    'movies' ...
        
        
        
        
%     'StimParams_00_GratingsWnSurrGray.mat'... % 15 mins
%     'StimParams_01_GratingsWnSurrCorr.mat'... % 15 mins -- need to make...
%     ...wider stimulus
%     'StimParams_02_GratingsWnSurrAntiCorr.mat'... % 15 mins 
%     'StimParams_03_GratingsWnSurrUnCorr.mat'... % 15 mins
%     'StimParams_Slits.mat'... % 72 mins 

    
%     'StimParams_06_GratingsWnSurrCheckerboard.mat'... % 15 mins
   
%     'StimParams_08_Wn25PerCheckerboard'...% 45 mins
%     'StimParams_09_Wn60PerCheckerboard'...% 45 mins
    };

% --------------------------------------------------------------------
% ------- Constants for Movie -----------
frameRate = 30; % Movie playback rate in frames/sec
clipRepeatCount = 1;
delayBetweenRepeats = 0; % seconds
frameCount = 50; % if specifying number of frames


movieDir = strcat('/local0/scratch/ijones/Natural_Movie_Frames/birds_bridge/');

% -------------------------------------------------------------------------
% TELL USER WHETHER RECORDING WILL OCCUR
if SAVE_RECORDING
    answer = input('Recording is set to ON (press <enter>)\n');
else
    answer = input('Recording is set to OFF (press <enter>)\n');
end
% -------------------------------------------------------------------------
% LOAD PSYCHOTOOLBOX ELEMENTS
% brightness values
for i=1
    BLACK_VAL = 0;
    WHITE_VAL = 255;
    DARK_GRAY_DECI = 115/WHITE_VAL;
    MID_GRAY_DECI = 163/WHITE_VAL;
    LIGHT_GRAY_DECI = 205/WHITE_VAL;
end
% um to pixels conversion
UM_TO_PIX_CONV = 1.79;

%Transition Screen Size
SURR_DIMS_TRANS = 1074/UM_TO_PIX_CONV; % length of edges of transition screen
transScrMtx = ones(SURR_DIMS_TRANS);%set # pixels along edge or...

% Init Psychtoolbox
for i=1
    SCREEN_SIZE = get(0,'ScreenSize');

    % KbName('KeyNamesLinux') %run this command to get the
    % names of the keys
    RestrictKeysForKbCheck(66) % Restrict response to the space bar
    HideCursor

    whichScreen = 0;
    % do screen tests
    Screen('Preference', 'SkipSyncTests', 0)
    % window = Screen('OpenWindow', whichScreen, [0 MID_GRAY_DECI*WHITE_VAL MID_GRAY_DECI*WHITE_VAL 0]);
    [window screenRect] = Screen('OpenWindow', whichScreen, [0 BLACK_VAL*WHITE_VAL BLACK_VAL*WHITE_VAL 0]);
    % do not use red LED
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,[0,1,1,0]);
    transitionScreen = Screen(window, 'MakeTexture',  BLACK_VAL+MID_GRAY_DECI*transScrMtx*WHITE_VAL );
    % show screen
    Screen(window, 'DrawTexture', transitionScreen    );
    Screen(window,'Flip');

    % Beeps & wait for keyboard input (space bar)
    beep, pause(.3), beep, pause(.3);
    KbWait;
    pause(.5),
end

for currStimFile = STIM_FILES
    
    Screen(window, 'DrawTexture', transitionScreen    );
    Screen(window,'Flip');
    pause(5);
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND GRAY
    stimFileName = 'StimParams_00_GratingsWnSurrGray.mat';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_00_gratingswnsurrgray(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end


    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND CORR
    stimFileName = 'StimParams_01_GratingsWnSurrCorr.mat';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_01_gratingswnsurrcorr(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end

    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND CORR
    stimFileName = 'StimParams_02_GratingsWnSurrAntiCorr.mat';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_02_gratingswnsurranticorr(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end

    end
    
    
        % -------------------------------------------------------------------------
    % STIMULUS TYPE: MOVIES
    stimFileName = 'movies';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            for iMovies = 1:2%:length(allMovieFilePatterns)
            % #1) NEW STIM: movie with median of whole movie surround
            % ---- constants ----
            allMovieFilePatterns = {'ss_ma*.bmp' 'ds_me*.bmp' 'ds_ma*.bmp' ...
                'ps_ra*.bmp' 'ps_re*.bmp' 'ps_wn*.bmp' ...
                'ps_wne*.bmp' 'ps_rbc*.bmp' 'ps_wne*.bmp' ...
                'natural*.bmp'};
            movieFilePattern = allMovieFilePatterns{iMovies};

            % load frames
            
            frameCount = 30;
            [frames frameCount frameNames] = load_im_frames(movieDir, ...
                'set_frame_count',frameCount, 'movie_file_pattern', movieFilePattern);
            
            write_log(strcat([movieFilePattern,' movie']),'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording
            % run stimulus
            clipRepeatCount = 6;
            play_movie(window, frames, frameCount, frameRate, clipRepeatCount, delayBetweenRepeats);

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(strcat([movieFilePattern,' movie']),'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
            end
        end

    end
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND CORR
    stimFileName = 'StimParams_03_GratingsWnSurrUnCorr.mat';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_03_gratingswnsurruncorr(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end

    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WN, SURROUND CHECKERBOARD
    stimFileName = 'StimParams_06_GratingsWnSurrCheckerboard.mat';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));
            load('white_noise_frames.mat');
            StimMats.white_noise_frames = white_noise_frames; clear white_noise_frames;

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_06_gratingswnsurrcheckerboard(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end

    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: SLITS
    stimFileName = 'StimParams_Slits.mat';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_slits(window,Settings,StimMats,screenRect)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end
    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: BARS
    stimFileName = 'StimParams_Bars.mat';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_bars(window,Settings,StimMats,screenRect)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end
    end

    % -------------------------------------------------------------------------
    % STIMULUS TYPE: SPOTS INCREASE IN SIZE
    stimFileName = 'StimParams_SpotsIncrSize.mat';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_spotsincrsize(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end
    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: WHITE NOISE 25 PERCENT CHECKERBOARD
    stimFileName = 'StimParams_08_Wn25PerCheckerboard';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));
            load('white_noise_frames.mat');

            load(fullfile(stimParamDir,stimFileName));

            StimMats.white_noise_frames = white_noise_frames; clear white_noise_frames;

            Settings.LIGHT_GRAY_25PER_DECI = Settings.MID_GRAY_DECI + ...
                (1 - Settings.MID_GRAY_DECI)*0.25;

            Settings.DARK_GRAY_25PER_DECI = Settings.MID_GRAY_DECI - ...
                (1 - Settings.MID_GRAY_DECI)*0.25;

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_08_wn25percheckerboard(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end
    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: WHITE NOISE 60 PERCENT CHECKERBOARD
    stimFileName = 'StimParams_09_Wn60PerCheckerboard';
    for stimType = 1
        if sum(strcmp(currStimFile, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));
            load('white_noise_frames.mat');

            load(fullfile(stimParamDir,stimFileName));

            StimMats.white_noise_frames = white_noise_frames; clear white_noise_frames;

            Settings.LIGHT_GRAY_60PER_DECI = Settings.MID_GRAY_DECI + ...
                (1 - Settings.MID_GRAY_DECI)*0.60;

            Settings.DARK_GRAY_60PER_DECI = Settings.MID_GRAY_DECI - ...
                (1 - Settings.MID_GRAY_DECI)*0.60;

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    parapin(0);
                    hidens_startSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            stim_09_wn60percheckerboard(window,Settings,StimMats)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(0,'bs-hpws03')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end
    end
    % -------- CLOSE OPEN WINDOWS ---------
end
kbWait
Screen('CloseAll');
