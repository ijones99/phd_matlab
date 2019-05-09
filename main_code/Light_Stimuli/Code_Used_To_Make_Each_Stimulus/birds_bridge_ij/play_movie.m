function play_movie(window, frames, frameCount, frameRate, clipRepeatCount, delayBetweenRepeats)

% play_movie(movieDir)
% --------------
% movieDir: string containing the directory where the frame files are.
% frames: loaded movie frames
% frameCount: # of frames
% frameRate: speed that film should be shown (in Hz)
                  
% -------------------- Stimulus Constants ------------------
% framerate for displaying movie

nativeRate = 60;

%Brightness Values
blackVal = 0;
whiteVal = 255; 
darkGrayVal = 115;
grayVal = 163;
lightGrayVal = 205;

% Make sure this is running on OpenGL Psychtoolbox:
% AssertOpenGL;

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar
HideCursor

% get screen id and open a gray window
% screenid = max(Screen ('Screens'));
% window = Screen('OpenWindow', screenid, [0 blackVal blackVal  0]);

% make gray transition screen      
% screenSize = get(0,'ScreenSize');
transScreenDims = [600 600]; % in pixels
transScreenImage = ones(transScreenDims(1),transScreenDims(2),3)*grayVal ;
transScreenImage(:,:,1) = 0;

% make the gray texture
transScreenTex = Screen(window, 'MakeTexture',  transScreenImage   );

% Draw transition screen window
Screen('DrawTexture', window, transScreenTex);

% flip screen to next frame
Screen(window,'Flip');

% create all textures
w = zeros(frameCount,1);
%create empty frame
tempFrame = uint8(zeros(size(frames,1), size(frames,2), 3));
tic
for i=1:frameCount
   tempFrame(:,:,2:3) = cat(3,frames(:,:,i), frames(:,:,i));
   w(i) = Screen(window, 'MakeTexture',  tempFrame);
end
toc

% wait for keyboard input
beep, pause(.3), beep, pause(.3), HideCursor, KbWait;

% calculate delay between presentation of frames
flashInterval = 1/frameRate - 1/nativeRate;

% initialize parapin
parapin(0)
    % Enable alpha blending for typical drawing of masked textures:
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

for iRepeat = 1:clipRepeatCount
    for j=1:frameCount

        Screen('DrawTexture', window, w(j));
        parapin(6);
        Screen(window,'Flip');
        parapin(4);
        pause(flashInterval)

    end

    %     pause between repeats
    if delayBetweenRepeats >0
        pause(delayBetweenRepeats)
    end
    
end

% Draw transition screen window
Screen('DrawTexture', window, transScreenTex);

% flip screen to next frame
Screen(window,'Flip');

pause(.3)
HideCursor


% KbWait;
  
% close screen
% Screen('CloseAll');

end
