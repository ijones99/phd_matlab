function show_checkerboard(varargin)
recComputerName = 'bs-dw17';
SAVE_RECORDING = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'record_computer_name')
            recComputerName = varargin{i+1};
        elseif strcmp( varargin{i}, 'save')
            SAVE_RECORDING = varargin{i+1};
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
stimParamFileName = 'stimParams_Checkerboard.mat';

stimFrameDir = 'stimuli_frames';
stimFrameFileName = 'white_noise_frames.mat';


% load files
% load stim frames
load(fullfile(stimFrameDir, stimFrameFileName));
% load stim params
m = load(fullfile(stimParamDir,stimParamFileName));
Settings = m.Settings;

StimMats.white_noise_frames = white_noise_frames(:,:,:); clear white_noise_frames;

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
stim.checkerboard.checkerboard_base(window,Settings,StimMats);
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



