function run_stim_series(window, Settings, stimName, ...
    doKbWait, screenRect, SAVE_RECORDING,slotNo, recComputerName, varargin )
% RUN_STIM_SERIES(window, Settings, stimParamFileName, stimName, ...
%     doPause, SAVE_RECORDING,slotNo, recComputerName )


doPause = 30;
doForcePause = 0;
isMac = ismac;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'pre_stim_pause')
            doPause = varargin{i+1};
            doForcePause = 1;
        end
    end
end


stimParamFileName = '';

% end initialization part

if isMac
    stimParamDir = '/Users/ijones/Documents/Matlab/light_stimuli/settings';
else
    stimParamDir = '/local0/scratch/ijones/settings';
end

if strcmp(stimName,'white_noise_checkerboard')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Checkerboard';
    end
    stimFrameDir = 'stimuli_frames';
    stimFrameFileName = 'white_noise_frames';
    % load stim frames
    load(fullfile(stimFrameDir, strcat(stimFrameFileName,'.mat')));
elseif strcmp(stimName,'moving_bars')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Moving_Bars_v3';
        fprintf('Load %s\n', stimParamFileName);
    end
elseif strcmp(stimName,'moving_bars_on_off')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Moving_Bars_ON_OFF';
        fprintf('Load %s\n', stimParamFileName);
    end
elseif strcmp(stimName,'moving_bars_length_test')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Moving_Bars_Length_Test';
        fprintf('Load %s\n', stimParamFileName);
    end
    elseif strcmp(stimName,'moving_bars_speed_test')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Moving_Bars_Speed_Test';
        fprintf('Load %s\n', stimParamFileName);
    end
elseif strcmp(stimName,'moving_bars_for_size_tuning')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Moving_Bars_v4_for_size_tuning';
        fprintf('Load %s\n', stimParamFileName);
    end
elseif strcmp(stimName,'moving_bars_2reps')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Moving_Bars_2Reps';
    end
elseif strcmp(stimName,'marching_sqr')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Marching_Sqr';
    end
elseif strcmp(stimName,'flashing_spots')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Flashing_Spots';
    end
 elseif strcmp(stimName,'drifting_grating_plus_spots')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Moving_Grating_with_Spots';
    end
elseif strcmp(stimName,'flashing_sqr')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Flashing_Sqr';
    end
elseif strcmp(stimName,'marching_sqr_over_grid')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Marching_Sqr_over_Grid';
    end
elseif strcmp(stimName,'drifting_linear_pattern')
    if isempty(stimParamFileName)
        stimParamFileName = 'stimParams_Drifting_Linear_Pattern';
    end
end

fprintf('>>>>>>>>>>>>>>>>>>>>>Will load %s.>>>>>>>>>>>>>>>>>>>\n',stimParamFileName)
% load stim params
m = load(fullfile(stimParamDir,strcat(stimParamFileName,'.mat')));
Settings = m.Settings;
if and(isfield(Settings,'preStartDelaySec'),doForcePause==0)
    doPause = Settings.preStartDelaySec;
end
% doPause=0.5
% add white noise frames to Settings
if strcmp(stimName,'white_noise_checkerboard')
    Settings.white_noise_frames = white_noise_frames(:,:,:); clear white_noise_frames;
end
% [newX,newY]=Screen('DrawText', windowPtr, text [,x] [,y] [,color] [,...
% backgroundColor] [,yPositionIsBaseline] [,swapTextDirection]);

% display transition screen
%rectColor = double(Settings.transScreenVal)*[0 1 1];
Screen('FillRect',window, double(Settings.transScreenVal)*[0 1 1]);
Screen('Flip', window);

Screen('TextFont',window, 'Courier');
Screen('TextSize',window, 12);
Screen('TextStyle', window, 0);

if not(isMac)
    HideCursor(window)
end
if doKbWait
    % Draw text
    Screen('DrawText',window, stimName,1,1,[Settings.transScreenVal*[1 0 0 ]]);
    pause(0.5)
    Screen('Flip', window);
    KbWait
end

tic

%pause(Settings.preStartDelaySec);
warning('no pause')

timePause = toc
save('timePause.mat','timePause')
% save troubleshooting.mat
write_log(stimParamFileName,'pre');%log file start stimulus
for recStart = 1
    if SAVE_RECORDING
        if exist('parapin.mexglx','file')
            parapin(0);
        elseif exist('.test_parapin_mexglx','file')
            parapin(0);
        else
            paramex(0);
        end
        hidens_startSaving(slotNo,recComputerName)
        pause(.2)
    end
end% Start recording

% run stimulus

if strcmp(stimName,'white_noise_checkerboard')
    if ismac
        movieDir = '/Users/ijones/Documents/Matlab/light_stimuli/movies/Natural_Movies/Mouse_Cage_Movies/Movie5/Original_Movie/';
    else
        movieDir = 'ijones/Natural_Movie_Frames/Mouse_Cage_Movies/Movie5/Original_Movie/';
    end
    numReps = 5;
    %     dlmwrite('timePointTrackerWN', datestr(now),'-append');
    %stim.movie.natural_movie_01( window,Settings,screenRect, movieDir, numReps);
    stim.checkerboard.checkerboard_base(window,Settings);

elseif strcmp(stimName,'moving_bars')
    stim.moving_bars.stim_bars_ds_scan_v4(window,Settings,screenRect);
elseif strcmp(stimName,'moving_bars_length_test')
    stim.moving_bars.stim_bars_ds_scan_v4(window,Settings,screenRect);
elseif strcmp(stimName,'moving_bars_speed_test')
    stim.moving_bars.stim_bars_ds_scan_v4(window,Settings,screenRect);
elseif strcmp(stimName,'moving_bars_2reps')
    stim.moving_bars.stim_bars_ds_scan(window,Settings,screenRect);
elseif strcmp(stimName,'marching_sqr')
    stim.marching_sqr.marching_sqr(window,Settings);
elseif strcmp(stimName,'flashing_spots')
    stim.spots.flashing_spots(window,Settings);
elseif strcmp(stimName,'drifting_grating_plus_spots')
    stim.drifting_grating.drifting_grating_plus_spots(window,Settings);
elseif strcmp(stimName,'flashing_sqr')
    stim.flashing_sqr.flashing_sqr(window,Settings);
elseif strcmp(stimName,'flashing_sqr')
    stim.flashing_sqr.flashing_sqr(window,Settings);
elseif strcmp(stimName,'moving_bars_for_size_tuning')
    stim.moving_bars.stim_bars_ds_scan_v4(window,Settings,screenRect);
elseif strcmp(stimName,'marching_sqr_over_grid')
    stim.marching_sqr.marching_sqr_v2(window,Settings);
elseif strcmp(stimName,'drifting_linear_pattern')
    stim.drifting_linear_pattern.stim_drifting_linear_pattern_v2(window,Settings, screenRect);
elseif strcmp(stimName,'moving_bars_on_off')
    stim.moving_bars.stim_bars_ds_scan_v4(window,Settings,screenRect);
end

for recStop=1
    if SAVE_RECORDING
        hidens_stopSaving(slotNo,recComputerName)
        pause(.2)
    end
end% stop recording
Screen('FillRect',window, double(Settings.transScreenVal)*[0 1 1]);
% Screen('DrawText',window, ['Done: ', stimName],1,1,[100*ones(1,3)]);

Screen('Flip', window);
pause(0.5)
write_log(stimParamFileName,'post');%log file end stimulus

end