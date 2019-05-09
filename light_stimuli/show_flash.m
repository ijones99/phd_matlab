function show_flash(fullScreen, edgeLength, varargin)
% function SHOW_FLASH(fullScreen, edgeLength, varargin)
%
% varargin
%   'auto_flash'
%   'flash_freq
%
skipTest = 2;
grayVal = 163;
Screen('Preference', 'VisualDebuglevel', 3)

HideCursor

flashFreq = .5; %Hz
do_record = 0;
doManual = 1;
whiteStim = 0;
for i=1:length(varargin)
   if strcmp(varargin{i},'auto_flash')
       doManual = 0;
   elseif strcmp(varargin{i},'flash_freq')
       flashFreq = varargin{i+1};
   elseif strcmp(varargin{i},'rgb')
       grayVal = varargin{i+1};
   elseif strcmp(varargin{i},'white_stim')
  
       whiteStim = 1;
   end
    
end


% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar
parapin(0)
umToPixConv = 1.79;
umToPixConvH = 1.67; %this takes into account rotation of image (thus, it is projected as H)
umToPixConvV = 1.74;%this takes into account rotation of image (thus, it is projected as V)
% show_gray([0...1], [0:1000] edge length) full screen on (1) or off (0). If [0] is selected, a
% gray square of the second argument edge length "edgeLength" will be
% produced. Edge length is defined in um.
% Press space bar to end the gray stimulus

% Values for size of stimulus square
% edgeLength = edgeLength/umToPixConv; % 600 pixels will convert to 1050 um
edgeLengthH = ceil(edgeLength/umToPixConvH);
edgeLengthV = ceil(edgeLength/umToPixConvV);
% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 0)
HideCursor

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
if ismac
    RestrictKeysForKbCheck(44) % Restrict response to the space bar 
else
   RestrictKeysForKbCheck(66) % Restrict response to the space bar 
end


% Values for projector brightness
blackVal = 0;
whiteVal = 255;
darkGrayVal = 115;

lightGrayVal = 205;   hidens_stopSaving(0,'bs-hpws03')

if fullScreen

    global screenid
    global win

    % Choose screen with maximum id - the secondary display on a dual-display
    % setup for display:

    screenid = max(Screen('Screens'));

    win = Screen('OpenWindow', screenid, [0 grayVal grayVal 0]);

    KbWait

    Screen('CloseAll');

else

    whichScreen = 0;
    window = Screen(whichScreen, 'OpenWindow');
    Screen(window, 'FillRect', blackVal);

    m=zeros(edgeLengthH,edgeLengthV, 3);
    m(:,:,2)=ones(edgeLengthH,edgeLengthV );
    m(:,:,3)=m(:,:,2);
    if whiteStim
        m(:,:,1)=m(:,:,2);%for white
    end
    w(1) = Screen(window, 'MakeTexture', grayVal*m);
    w(2) = Screen(window, 'MakeTexture', blackVal*m);
    Screen('DrawTexture', window, w(1));
    Screen(window,'Flip');

    if doManual ~= 1
        while KbCheck == 0
            Screen('DrawTexture', window, w(1));
            parapin(6);
            Screen(window,'Flip');
            parapin(4);
            pause(.5*1/flashFreq);
            Screen('DrawTexture', window, w(2));
            parapin(6)
            Screen(window,'Flip');
            parapin(4)
            pause(.5*1/flashFreq);
        end

    else
        for i=1:2000
            Screen('DrawTexture', window, w(1));
            parapin(6)
            Screen(window,'Flip');
            parapin(4)
            KbWait
               pause(.2)
            Screen('DrawTexture', window, w(2));
            parapin(6);
            Screen(window,'Flip');
            parapin(4);
            KbWait
               pause(.2)
        end

    end




end

Screen('DrawTexture', window, w(1));
Screen(window,'Flip');
pause(2)


KbWait;
Screen('CloseAll');

end