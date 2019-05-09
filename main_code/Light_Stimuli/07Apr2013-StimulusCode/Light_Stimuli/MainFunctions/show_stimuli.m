function show_stimuli
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

cd /home/ijones/Experiment/Light_Stimuli/MainFunctions
SAVE_RECORDING = 1;
DelayBetweenStimuli = 10; %seconds

stimParamDir = '';
movieEdgeLengthPx = 750;
STIM_FILES = {...   % Select stimuli to run
    'StimParams_10_Wn100PerCheckerboard_short.mat';
    'StimParams_10_Wn100PerCheckerboard.mat';
    'movies'; 
    'StimParams_SpotsIncrSize.mat';
    'StimParams_Bars.mat';
    'StimParams_Marching_Sqr.mat'...
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
% LOAD PSYCHOTOOLBOX ELEMENTS
% brightness values
for i=1
    % BRIGHTNESS VALUES
    pixTransferFuncDir = '';
    % load pixel transfer function
    load(fullfile(pixTransferFuncDir, 'lookupTbMean_ND2_norm.mat'));
    Settings.BLACK_VAL = 0;
    Settings.WHITE_VAL = apply_projector_transfer_function_nearest_neighbor(255,lookupTbMean_ND2_norm);
    Settings.DARK_GRAY_VAL = apply_projector_transfer_function_nearest_neighbor(255*3/8,lookupTbMean_ND2_norm); % 50% below mid gray
    Settings.MID_GRAY_VAL = apply_projector_transfer_function_nearest_neighbor(255*4/8,lookupTbMean_ND2_norm); % mid gray
    Settings.LIGHT_GRAY_VAL = apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm); % 50% above mid gray
    Settings.DARK_GRAY_DECI = single(Settings.DARK_GRAY_VAL)/single(Settings.WHITE_VAL);
    Settings.MID_GRAY_DECI = single(Settings.MID_GRAY_VAL)/single(Settings.WHITE_VAL);
    Settings.LIGHT_GRAY_DECI = single(Settings.LIGHT_GRAY_VAL)/single(Settings.WHITE_VAL);
end
% um to pixels conversion
    Settings.UM_TO_PIX_CONV = 1.6144;% 

%Transition Screen Size
SURR_DIMS_TRANS = movieEdgeLengthPx;%1074/Settings.UM_TO_PIX_CONV; % length of edges of transition screen
transScrMtx = single(ones(SURR_DIMS_TRANS));%set # pixels along edge or...

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
        [0 Settings.BLACK_VAL*Settings.WHITE_VAL Settings.BLACK_VAL*Settings.WHITE_VAL 0]);
    % do not use red LED
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,[0,1,1,0]);
    transitionScreen = Screen(window, 'MakeTexture',  double(single(Settings.BLACK_VAL)+ ...
        single(Settings.MID_GRAY_DECI)*transScrMtx*single(Settings.WHITE_VAL) ));
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

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end


    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND CORR
    stimFileName = 'StimParams_01_GratingsWnSurrCorr.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end

    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: CENTER WHITE NOISE SURROUND CORR
    stimFileName = 'StimParams_02_GratingsWnSurrAntiCorr.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end

    end
    
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: MOVIES
    % ---- constants ----
    stimFileName = 'movies';

    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            pause(DelayBetweenStimuli)
            % --------------------------------------------------------------------
            % mouse cage movie, movie 1
            movieDirBirds400 = strcat('~/Movie_Stimuli/birds_bridge_ij/400umAperture');
            movieDirBirds600 = strcat('~/Movie_Stimuli/birds_bridge_ij/600umAperture');
            movieDir_labelb12ariell = strcat('~/Movie_Stimuli/labelb12ariell/500umAperture');
            movieDirMov5 = strcat('/home/ijones/Movie_Stimuli/Mouse_Cage_Movies/Movie5');
            allMovieFilePatterns = { ...
                'Original_Movie'; ...
                'Stat_Surr_Median_Whole_Movie';...
                'Dynamic_Surr_Median_Each_Frame';...
                'Dynamic_Surr_Shuffled_Median_Each_Frame';...

                'Pixelated_Surr_Shuffled_50_Percent_Each_Frame';...
                'Pixelated_Surr_Shuffled_90_Percent_Each_Frame';...
                }
     %                 'Pixelated_Surr_Shuffled_10_Percent_Each_Frame';...     
            frameRate = 30; % Movie playback rate in frames/sec
            delayBetweenStimulusRepeats = 0.2; % seconds
            delayBetweenStimulusSeriesRepeats = 1;
            frameCount = 900; % if specifying number of frames
            clipRepeatCount =  35; % number of times to repeat stimulus
                   
            for iSeriesRepeat = 1 % each file is shown once
                for iMovies = [1:length(allMovieFilePatterns) ]
                    
                    % set correct directories
                    if ismember(iMovies, 1:7)
                        movieDir = movieDir_labelb12ariell;
                        % elseif ismember(iMovies, 8)
                        % movieDir = movieDir_labelb12ariell;
                        % else
                        % movieDir = movieDir_labelb12ariell;
                    end
                    
                    movieFilePattern = allMovieFilePatterns{iMovies};
                    slashLoc = strfind(movieDir,'/');
                    % load frames
                    [frames frameCount frameNames] = load_im_frames(fullfile(movieDir,movieFilePattern,'') , ...
                        'set_frame_count',frameCount, 'rot_and_flip', ...
                        'movie_file_pattern', strcat(movieFilePattern,'*.bmp'), ... %, ...
                        'spec_frame_dims_pix', [movieEdgeLengthPx movieEdgeLengthPx]);
                    
                    write_log(strcat([movieDir(slashLoc(end-1):end),movieFilePattern,' movie']),'pre');%log file start stimulus
                    
                    for recStart = 1
                        if SAVE_RECORDING
                            paramex(0);
                            hidens_startSaving(1,'172.27.34.19')
                            pause(.2)
                        end
                    end% Start recording
                    % run stimulus
                     play_movie(window, frames, frameCount, frameRate, clipRepeatCount, delayBetweenStimulusRepeats);
                    
                    for recStop=1
                        if SAVE_RECORDING
                            hidens_stopSaving(1,'172.27.34.19')
                            pause(.2)
                        end
                    end% stop recording
                    
                    write_log(strcat([movieDir(slashLoc(end-1):end), movieFilePattern,' movie']),'post');%log file end stimulus
                    pause(delayBetweenStimulusSeriesRepeats)
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

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
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

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end

    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: SLITS
    stimFileName = 'StimParams_Slits.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end
    end
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: BARS
    stimFileName = 'StimParams_Bars.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            clear Settings StimMats
            % load stimulus data
            pause(DelayBetweenStimuli)
            load(fullfile(stimParamDir,stimFileName));
            Settings.f = 60;
            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.1)
                end
            end% Start recording

            % run stimulus
            stim_bars(window,Settings,screenRect)

            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.1)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            Settings.END_EXP_PAUSE = 3;
            pause(Settings.END_EXP_PAUSE)
        end
    end

    % -------------------------------------------------------------------------
    % STIMULUS TYPE: SPOTS INCREASE IN SIZE
    stimFileName = 'StimParams_SpotsIncrSize.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            pause(DelayBetweenStimuli)
            clear Settings StimMats %
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            Settings.END_EXP_PAUSE=3;
            pause(Settings.END_EXP_PAUSE)
        end
    end
    
     % -------------------------------------------------------------------------
    % STIMULUS TYPE: MARCHING SQUARE
    stimFileName = 'StimParams_Marching_Sqr.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            pause(DelayBetweenStimuli)
            % clear data
            clear Settings StimMats
            % load stimulus data
            load(fullfile(stimParamDir,stimFileName));

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            fprintf('Run file')
            stim_marching_sqr(Settings, window)
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            Settings.END_EXP_PAUSE= 3;
            pause(Settings.END_EXP_PAUSE)
        end
    end
    
    % -------------------------------------------------------------------------
    % STIMULUS TYPE: WHITE NOISE 25 PERCENT CHECKERBOARD
    stimFileName = 'StimParams_08_Wn25PerCheckerboard.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            pause(DelayBetweenStimuli)
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

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            
            pause(Settings.END_EXP_PAUSE)
        end
    end
     % -------------------------------------------------------------------------
    % STIMULUS TYPE: WHITE NOISE Test CHECKERBOARD
    stimFileName = 'StimParams_09_WnCheckerboardTest.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % load stimulus data
            pause(DelayBetweenStimuli)
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

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            
            pause(Settings.END_EXP_PAUSE)
        end
    end
       % STIMULUS TYPE: WHITE NOISE Test CHECKERBOARD
    stimFileName = 'StimParams_10_Wn100PerCheckerboard.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % clear stimulus data
            clear Settings StimMats 
            % load stimulus data
            pause(DelayBetweenStimuli)
            load('white_noise_frames.mat');
            load(fullfile(stimParamDir,stimFileName));

            StimMats.white_noise_frames = white_noise_frames(:,:,:); clear white_noise_frames;

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim_09_wn_100per_checkerboard(window,Settings,StimMats)
            tocTime = toc
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            
%             pause(Settings.END_EXP_PAUSE)
pause(2)
        end
    end
    
    % STIMULUS TYPE: WHITE NOISE Test CHECKERBOARD SHORT
    stimFileName = 'StimParams_10_Wn100PerCheckerboard_short.mat';
    for stimType = 1
        if sum(strcmp(STIM_FILES{iCurrStimFile}, stimFileName ))
            % clear stimulus data
            clear Settings StimMats 
            % load stimulus data
            pause(DelayBetweenStimuli)
            load('white_noise_frames_short.mat');
            load(fullfile(stimParamDir,stimFileName));

            StimMats.white_noise_frames = white_noise_frames(:,:,:); clear white_noise_frames;

            write_log(stimFileName,'pre');%log file start stimulus

            for recStart = 1
                if SAVE_RECORDING
                    paramex(0);
                    hidens_startSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% Start recording

            % run stimulus
            tic
            stim_09_wn_100per_checkerboard(window,Settings,StimMats)
            tocTime = toc
            for recStop=1
                if SAVE_RECORDING
                    hidens_stopSaving(1,'172.27.34.19')
                    pause(.2)
                end
            end% stop recording

            write_log(stimFileName,'post');%log file end stimulus
            
%             pause(Settings.END_EXP_PAUSE)
pause(2)
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

            write_log(stimFileName,'pre');%log file start stimulus

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

            write_log(stimFileName,'post');%log file end stimulus
            pause(Settings.END_EXP_PAUSE)
        end
    end
    % -------- CLOSE OPEN WINDOWS ---------
    iCurrStimFile
end
kbWait
Screen('CloseAll');
end