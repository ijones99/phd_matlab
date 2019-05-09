function run_recording_init_functions
%%
% ------------ Set variables ------------ %
showGrayDuration =  5*60; %seconds
% ----
% ----
% ------------ End set variables -------- %

% ------------------------------------- %
% -- Initial phase                   -- %
% ------------------------------------- %

% STIM COMPUTER: 5 mins middle-gray
show_gray('stim_duration', showGrayDuration,'timer_beep', 1 ) %build in an interrupt function, beep after 5 mins
% STIM COMPUTER:  keep showing gray after that time until button pressed

% ------------------------------------- %
% -- Record from larger squares -- %
% ------------------------------------- %

% STIM COMPUTER: idle, showing gray; 
% REC COMPUTER: user start recording

% STIM COMPUTER: start flashing once user has pressed button
beep(), pause(.2), beep() % signal to alert to change of stimulation activity
show_flashing %build in an interrupt function

% REC COMPUTER: start configuration sequence of large sections on cmdgui 

% --- now flashing is occurring and recordings are being made --- %

% STIM COMPUTER: press button when recording is finished

% STIM COMPUTER: Show gray
beep(), pause(.2), beep() % signal to alert to change of stimulation activity
show_gray

% STIM COMPUTER: waiting and showing gray

% REC COMPUTER: Plot activity map of all activity: 9 plots in one window
% REC COMPUTER: calculate best square
% REC COMPUTER: Prompt for best square position; save to info file
% REC COMPUTER: center the stimulus on selected large square %

% ------------------------------------- %
% -- Record from smaller squares -- %
% ------------------------------------- %

% STIM COMPUTER: idle, showing gray; 
% REC COMPUTER: start recording

% STIM COMPUTER: start flashing once user has pressed button
beep(), pause(.2), beep() % signal to move on
show_flashing %build in an interrupt function

% REC COMPUTER: start configuration sequence of large sections on cmdgui 
 
% --- now flashing is occurring and recordings are being made --- %

% STIM COMPUTER: press button when recording is finished

% STIM COMPUTER: Show gray
show_gray
beep(), pause(.2), beep(), pause(.4), beep()

% STIM COMPUTER: waiting

% REC COMPUTER: Plot activity map of all activity: 9 plots in one window
% MANUALLY: calculate best square
% MANUALLY: Prompt for best square position; save to info file
% MANUALLY: center the stimulus on selected large square %









%%
end
