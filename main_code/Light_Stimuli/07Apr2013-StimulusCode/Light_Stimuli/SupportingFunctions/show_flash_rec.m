function show_flash(fullScreen, edgeLength)

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
% edge length is in um
RestrictKeysForKbCheck(66) % Restrict response to the space bar

flashFreq = .5; %Hz
do_record = 1;
RecTime = 60;%seconds
numLoops = ceil(RecTime*flashFreq);

umToPixConv = 2;%1.79;
umToPixConvH = 2;%1.67; %this takes into account rotation of image (thus, it is projected as H)
umToPixConvV = 2;%1.74;%this takes into account rotation of image (thus, it is projected as V)
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
HideCursor

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar

% Values for projector brightness
blackVal = 0;
whiteVal = 255;
darkGrayVal = 115;
grayVal = 163;
lightGrayVal = 205;   %hidens_stopSaving(0,'bs-hpws03')

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
    win1 = Screen(whichScreen, 'OpenWindow');
    Screen(win1, 'FillRect', blackVal);

    m=zeros(edgeLengthH,edgeLengthV, 3);
    m(:,:,2)=ones(edgeLengthH,edgeLengthV );
    m(:,:,3)=m(:,:,2);
    w(1) = Screen(win1, 'MakeTexture', grayVal*m);
    w(2) = Screen(win1, 'MakeTexture', blackVal*m);
    Screen('DrawTexture', win1, w(1));
    Screen(win1,'Flip');
   
    paramex(0)
    pause(.5);
    kbWait
    hidens_startSaving(0,'bs-hpws03')
    pause(.2)
    for i=1:numLoops
        

        Screen('DrawTexture', win1, w(1));
                paramex(6)
        Screen(win1,'Flip');
        pause(.5*1/flashFreq);
        Screen('DrawTexture', win1, w(2));
                paramex(4)
        Screen(win1,'Flip');
        pause(.5*1/flashFreq);
    end

        paramex(0)
        pause(.2);
        hidens_stopSaving(0,'bs-hpws03')



end

Screen('DrawTexture', win1, w(1));
Screen(win1,'Flip');
pause(2)


KbWait;
Screen('CloseAll');

end