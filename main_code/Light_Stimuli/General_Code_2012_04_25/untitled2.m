% KbName('KeyNamesLinux') %run this command to get the 
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar

global screenid
global win

blackVal = 0;
whiteVal = 255;
darkGrayVal = 115/whiteVal; 
grayVal = 163/whiteVal;
lightGrayVal = 205/whiteVal;

%sin wave vacillates between 115 and 205
grayValSinBase = 160/whiteVal ;
sinWaveAmp = 95/whiteVal % +/- this value

% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;
% Choose screen with maximum id - the secondary display on a dual-display
% setup for display:

screenid = max(Screen('Screens'));

win = Screen('OpenWindow', screenid, [0 grayVal*whiteVal grayVal*whiteVal 0]);

KbWait

Screen('CloseAll'); 