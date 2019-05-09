
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

% cd /home/ijones/Experiment/Light_Stimuli/MainFunctions
SAVE_RECORDING = 0;
DelayBetweenStimuli = 10; %seconds

stimParamDir = '';
movieEdgeLengthPx = 750;
STIM_FILES = {...   % Select stimuli to run
       'StimParams_Bars.mat'; ...
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
    KbWait;
    pause(.5),
end

for i=1:Settings.NUM_REPS
    clear Settings StimMats
    % load stimulus data
    load(fullfile(stimParamDir,stimFileName));

    write_log(stimFileName,'pre');%log file start stimulus
    
    for recStart = 1
        if SAVE_RECORDING
            paramex(0);
            hidens_startSaving(1,'172.27.34.19')
            pause(.1)
        end
    end% Start recording
    
    % run stimulus
    stim_bars_ds_scan(window,Settings,screenRect, iRep)
    
    for recStop=1
        if SAVE_RECORDING
            hidens_stopSaving(1,'172.27.34.19')
            pause(.1)
        end
    end% stop recording
    
    write_log(stimFileName,'post');%log file end stimulus
    pause(Settings.END_EXP_PAUSE)
    
    
end
kbWait
Screen('CloseAll');
