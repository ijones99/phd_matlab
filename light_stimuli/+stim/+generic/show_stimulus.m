function show_stimulus(stimName, varargin )
recComputerName = 'bs-dw17';
SAVE_RECORDING = 0;
xyLocationOnScreen = [];
stimParamFileName = [];
slotNo = 0;
% stop recording (as a precaution)
hidens_stopSaving(slotNo,recComputerName)
doPause = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'record_computer_name')
            recComputerName = varargin{i+1};
        elseif strcmp( varargin{i}, 'save')
            SAVE_RECORDING = 1;
        elseif strcmp( varargin{i}, 'xy_loc')
            xyLocationOnScreen = varargin{i+1};
        elseif strcmp( varargin{i}, 'stim_param_file')
            stimParamFileName = varargin{i+1};
        elseif strcmp( varargin{i}, 'pause_before_stim')
            doPause = varargin{i+1};
        end
    end
end

% init. part
% transition screen 163 for dots
[ window screenRect transitionScreen ] = supporting_functions.initialize_screen
Screen(window, 'DrawTexture', transitionScreen    );
Screen(window,'Flip');

% end initialization part

stimParamDir = '/local0/scratch/ijones/settings';

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
        stimParamFileName = 'stimParams_Moving_Bars';
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
       
end

fprintf('>>>>>>>>>>>>>>>>>>>>>Will load %s.>>>>>>>>>>>>>>>>>>>\n',stimParamFileName)
% load stim params
m = load(fullfile(stimParamDir,strcat(stimParamFileName,'.mat')));
Settings = m.Settings;

% add white noise frames to Settings
if strcmp(stimName,'white_noise_checkerboard')
    Settings.white_noise_frames = white_noise_frames(:,:,:); clear white_noise_frames;
end
% [newX,newY]=Screen('DrawText', windowPtr, text [,x] [,y] [,color] [,...
% backgroundColor] [,yPositionIsBaseline] [,swapTextDirection]);


black=BlackIndex(window);
Screen('TextFont',window, 'Courier');
Screen('TextSize',window, 12);
Screen('TextStyle', window, 0);
Screen('FillRect',window, black);
Screen('DrawText',window, stimName,1,1,[150*ones(1,3)]);
Screen('Flip', window);

KbWait
Screen('FillRect',window, black);
Screen('Flip', window);
HideCursor
write_log(stimParamFileName,'pre');%log file start stimulus
if doPause
    pause(doPause)
end
for recStart = 1
    if SAVE_RECORDING
        if exist('parapin.mexglx','file')
            parapin(0);
        else
            paramex(0);
        end
        hidens_startSaving(slotNo,recComputerName)
        pause(.2)
    end
end% Start recording

% run stimulus
tic
if strcmp(stimName,'white_noise_checkerboard')
    stim.checkerboard.checkerboard_base(window,Settings);
elseif strcmp(stimName,'moving_bars')
    stim.moving_bars.stim_bars_ds_scan(window,Settings,screenRect);
elseif strcmp(stimName,'moving_bars_2reps')
    stim.moving_bars.stim_bars_ds_scan(window,Settings,screenRect);
elseif strcmp(stimName,'marching_sqr')
    stim.marching_sqr.marching_sqr(window,Settings);
elseif strcmp(stimName,'flashing_spots')
    
    stim.spots.flashing_spots(window,Settings);
 elseif strcmp(stimName,'drifting_grating_plus_spots')
    stim.drifting_grating.drifting_grating_plus_spots(Settings);   
end
tocTime = toc

for recStop=1
    if SAVE_RECORDING
        hidens_stopSaving(slotNo,recComputerName)
        pause(.2)
    end
end% stop recording

write_log(stimParamFileName,'post');%log file end stimulus

% close windows
KbWait
Screen('CloseAll');



end



