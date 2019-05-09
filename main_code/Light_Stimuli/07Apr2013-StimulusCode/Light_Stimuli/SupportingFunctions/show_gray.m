function show_gray(fullScreen, edgeLength)

do_record = 0;
% umToPixConv = 1.79;
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

measureOn = 0;

if measureOn == 1
   edgeLengthH = 500;edgeLengthV = 500;  
end

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

    for i=1
        m=zeros(edgeLengthH,edgeLengthV, 3);
        m(:,:,2)=ones(edgeLengthH,edgeLengthV );
        m(:,:,3)=m(:,:,2);
        w(i) = Screen(window, 'MakeTexture', grayVal*m);
    end

    for i=1
        Screen('DrawTexture', window, w(i));
        Screen(window,'Flip');
    end

    if do_record

        recTime = 20;

        hidens_startSaving(1,'bs-hpws03')

        pause(recTime);

        hidens_stopSaving(1,'bs-hpws03')



    end
    
    
    
    KbWait;
    Screen('CloseAll');
end
end