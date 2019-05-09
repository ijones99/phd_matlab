function show_stimulus(stimName, varargin )
recComputerName = 'bs-dw17';
SAVE_RECORDING = 0;
xyLocationOnScreen = [];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'record_computer_name')
            recComputerName = varargin{i+1};
        elseif strcmp( varargin{i}, 'save')
            SAVE_RECORDING = varargin{i+1};
        elseif strcmp( varargin{i}, 'xy_loc')
            xyLocationOnScreen = varargin{i+1};
        
        end
    end
end

% init. part 
[ window screenRect transitionScreen ] = supporting_functions.initialize_screen
Screen(window, 'DrawTexture', transitionScreen    );
Screen(window,'Flip');
pause(0.5);
% end initialization part

stimParamDir = '/local0/scratch/ijones/settings';

if strcmp(stimName,'white_noise_checkerboard')
    stimParamFileName = 'stimParams_Checkerboard';
    stimFrameDir = 'stimuli_frames';
    stimFrameFileName = 'white_noise_frames';
    % load stim frames
    load(fullfile(stimFrameDir, strcat(stimFrameFileName,'.mat')));
elseif strcmp(stimName,'moving_bars')
    stimParamFileName = 'stimParams_Moving_Bars';
elseif strcmp(stimName,'marching_sqr')
    stimParamFileName = 'stimParams_Marching_Sqr';
elseif strcmp(stimName,'flashing_spots')
    stimParamFileName = 'stimParams_Flashing_Spots';    
%        stim_spotsincrsize(window,Settings,StimMats)
    
end

% load stim params
m = load(fullfile(stimParamDir,strcat(stimParamFileName,'.mat')));
Settings = m.Settings;

% add white noise frames to Settings
if strcmp(stimName,'white_noise_checkerboard')
    StimMats.white_noise_frames = white_noise_frames(:,:,:); clear white_noise_frames;
end

write_log(stimParamFileName,'pre');%log file start stimulus

for recStart = 1
    if SAVE_RECORDING
        paramex(0);
        hidens_startSaving(1,recComputerName)
        pause(.2)
    end
end% Start recording

% run stimulus
tic
if strcmp(stimName,'white_noise_checkerboard')
    stim.checkerboard.checkerboard_base(window,Settings,StimMats);
elseif strcmp(stimName,'moving_bars')
    stim.moving_bars.stim_bars_ds_scan(window,Settings,screenRect);
elseif strcmp(stimName,'marching_sqr')
    stim.marching_sqr.marching_sqr(window,Settings);
elseif strcmp(stimName,'flashing_spots')
    stim.spots.flashing_spots(window,Settings);
end
tocTime = toc

for recStop=1
    if SAVE_RECORDING
        hidens_stopSaving(1,recComputerName)
        pause(.2)
    end
end% stop recording

write_log(stimParamFileName,'post');%log file end stimulus

% close windows
KbWait
Screen('CloseAll');                        
       


end



