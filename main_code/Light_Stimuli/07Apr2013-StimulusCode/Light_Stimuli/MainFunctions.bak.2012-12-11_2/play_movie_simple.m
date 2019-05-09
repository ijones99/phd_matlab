function play_movie_simple(movieDir)
% play_movie_simple(movieDir)
% movieDir: string, directory where frames are stored (e.g. bmp files).
 
%% Stim Runtime         
waitTimeBetweenPresentations =1;
                  
% -------------------- Stimulus Constants ------------------
% framerate for displaying movie
frameRate = 30;
nativeRate = 60;

%Brightness Values
blackVal = 0;
whiteVal = 255; 
darkGrayVal = 115;
grayVal = 163;
lightGrayVal = 205;

parapin(0)

% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar
HideCursor

% get screen id and open a gray window
screenid = max(Screen ('Screens'));
window = Screen('OpenWindow', screenid, [0 grayVal grayVal  0]);

% make gray full screen       
screenSize = get(0,'ScreenSize');
fullScreenImage = ones(screenSize(3),screenSize(4),3)*255 ;
fullScreenImage(:,:,1) = 0;
wGray = Screen(window, 'MakeTexture',  fullScreenImage*(grayVal/whiteVal)   );
  
%load the file names of frames of the movie
frameNames = dir(strcat(movieDir,'*bmp'));

% number frames
frameCount = length(frameNames);

%load files
frame = uint8(zeros(600,600,600));
frame2 = uint8(zeros(600,600,600));
for i=1:600
    frame(:,:,i) = imread(strcat(movieDir, frameNames(i).name ),'bmp');
    i
end

%must load separately, otherwise loading is very slow
for i=1:601
    frame2(:,:,i) = imread(strcat(movieDir, frameNames(i+600).name ),'bmp');
    i
end

% put all frames into one variable
frame(:,:,601:frameCount) = frame2; clear frame2;

% create all textures
toc
w = zeros(frameCount,1);
for i=1:frameCount
   w(i) = Screen(window, 'MakeTexture',  frame(:,:,i));
end

% wait for keyboard input
beep, pause(.3), beep, pause(.3), HideCursor, KbWait;

% delay between presentation of frames
flashInterval = 1/frameRate - 1/nativeRate;

for j=1:frameCount
    
    Screen('DrawTexture', window, w(j));
    Screen(window,'Flip');
    pause(flashInterval)

    if KbCheck
        break;
    end
end

pause(.3)
HideCursor
Screen('DrawTexture', window, wGray);
Screen(window,'Flip');

KbWait;
  
Screen('CloseAll');


end
