function show_stimulus2(stimOptionSel, kbWaitStim, varargin )

[junk, currHostName] = system('hostname');

if strfind(currHostName, 'bs-dw27.ethz.ch') % only allow if current computer is retina stimulation computer
    recComputerName = 'bs-dw17';
else
    recComputerName = 'bs-dw05';
end

SAVE_RECORDING = 0;
xyLocationOnScreen = [];
stimParamFileName = [];
slotNo = 0;
% stop recording (as a precaution)
if not(ismac)
    hidens_stopSaving(slotNo,recComputerName)
end
doPause = [];

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
        elseif strcmp( varargin{i}, 'pre_stim_pause')
            doPause = varargin{i+1};
        end
    end
end


% init. part
[ window screenRect transitionScreen ] = ...
    supporting_functions.initialize_screen
% Draw black screen
black=BlackIndex(window)
Screen('FillRect',window, black);


% run stimulation loop, going through each selected stimulus
for i=1:length(stimOptionSel)
    
    doKbWait = 0;
    for iKbWait = 1:length(kbWaitStim)
        if strcmp(stimOptionSel{i}, kbWaitStim{iKbWait})
            doKbWait = 1;
        end
    end
    
    
    %     dlmwrite('timePointTracker', datestr(now),'-append');
    if isempty(doPause)
        stim.run_stim_series(window, Settings, stimOptionSel{i}, ...
            doKbWait, screenRect, SAVE_RECORDING,slotNo, recComputerName )
    else % change pre stim pause for testing
        tic
        stim.run_stim_series(window, Settings, stimOptionSel{i}, ...
            doKbWait, screenRect, SAVE_RECORDING,slotNo, recComputerName,'pre_stim_pause', doPause )
        toc
    end
    %     dlmwrite('timePointTracker', datestr(now),'-append');
end

% close windows
KbWait
Screen('CloseAll');


end



