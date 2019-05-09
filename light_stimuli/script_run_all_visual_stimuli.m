stimOptions = {...
    'moving_bars_on_off';...
    'moving_bars_length_test';...
    'moving_bars_speed_test';...
    'drifting_linear_pattern';...%3
    'marching_sqr_over_grid';...%3
    'marching_sqr';...%4
    
    
    'white_noise_checkerboard';... %6
    'moving_bars';... %2 % narrow moving bars
    'moving_bars_for_size_tuning';... %1
    'flashing_spots';...            %4
    'drifting_grating_plus_spots';... %5
    'flashing_sqr'; ...          %6
    'moving_bars_2_reps'; %9
    }

%%%%%% EDIT NEXT LINE%%%%%%%%%%%%%%%%%
stimOptionSelNo =[6]%[ repmat([4], 1, 100)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimOptionSel = stimOptions(stimOptionSelNo);
stimOptions(stimOptionSelNo(end:-1:1))
choice =input('The above stim sequence is fine (reversed)? >> [y/n]','s');

if choice == 'y'
    doSave =input('Save to file? [y/n]','s');
    if strcmp(doSave,'y') || isempty(doSave)
        fprintf('Save to file...');saveStr = 'save';
    else,  saveStr = ''; fprintf('Do not save to file...'), end
    pause(0.1)
    %% Flashing Spots5
    kbWaitStim = {'flashing_spots'};
    %     kbWaitStim = {'flashing_spots', 'drifting_grating_plus_spots'};
    tic
    stim.generic.show_stimulus2(stimOptionSel,kbWaitStim, 'pre_stim_pause', 3 )%,)
    endTime = toc
end

% README
% Settings.preStartDelaySec: Pre-stimulus waiting time
% Settings.transScreenVal: post-stimulus waiting time
%
%
%
