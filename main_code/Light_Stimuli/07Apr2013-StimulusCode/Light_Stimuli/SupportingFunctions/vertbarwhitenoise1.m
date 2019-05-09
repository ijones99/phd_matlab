function white_noise_vert_bar
clear 
%white_noise_vert_bar project a white noise stimulus with psychotoolbox
%
%
% Author:ijones 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%

alignarray = 0;
secPerMinute = 60;
RunningTime = (1/20)*secPerMinute; %minutes to run
numberRepeats = 1;
LoopDelay = 0.0212;%0.0307;
FrameRate = 30;
InterFrameInterval = (1/FrameRate) - LoopDelay   ;   %seconds between frames (must be greater than 0.017)
NumFrames = ceil((RunningTime/(InterFrameInterval + LoopDelay))/ numberRepeats)                        % Number of unique frames
NumPixelsPerSquare = 30;
Bars = 20;
EdgeLength = NumPixelsPerSquare*Bars;
BarOrientation = 'h';

%user prompts
alignarrayprompt = input('Align array [n/y]?','s');
if isempty(alignarrayprompt) || alignarrayprompt == 'n'
    alignarray = 0;
elseif alignarrayprompt == 'y'
    alignarray = 1;
end
createNewWhiteNoise = input('Create new whitenoise file [n/y]?','s');
if isempty(createNewWhiteNoise) || createNewWhiteNoise == 'n'
    %do not create a new whitenoise file; use SavedCompressedFrames,
    %array 'savedframes' 
    load SavedCompressedFrames
elseif createNewWhiteNoise == 'y'
    %create new white noise array
    saved_frames = genframes(NumFrames,EdgeLength, NumPixelsPerSquare, BarOrientation );
else
    disp('Error with prompt input');
    return;
end

%HideCursor

whichScreen = 0;
Screen('Preference', 'SkipSyncTests', 0)  
window = Screen(whichScreen, 'OpenWindow');
N=4 % number of stimulus switches 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%

White  = WhiteIndex(window); % pixel value for white
Black  = BlackIndex(window); % pixel value for black
Gray = (Black+White)/2;
savestimulus = 0      ;% 1 = true, 0 = false;



Screen(window, 'FillRect', Black);
Screen(window, 'PutImage', Black);
Screen(window, 'Flip');


InterFrameInterval
expandedframe1 = sparse(EdgeLength,EdgeLength);

if alignarray == 1
    saved_frames(find(saved_frames==0)) = 1;
end
beep()
pause(.4)
beep()
pause(.4)
beep()  

KbWait;
pause(.5);
parapin(0);


Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,[0,1,1,0]);

for m = 1:numberRepeats
tic    
for i = 1:NumFrames 
  expandedframe1 =   (kron(saved_frames(:,:,i),ones(NumPixelsPerSquare)));
  w = Screen(window, 'MakeTexture',  Black+White*expandedframe1 );
  
  Screen(window, 'DrawTexture', w    );
  parapin(6); 
  Screen(window,'Flip'); 
  parapin(4);
  %pause for amount specified minus the intrinsic rate
  if(KbCheck)
    break;
  end;
  pause(InterFrameInterval   ); 
 
    
  Screen('Close', w); 
  %Screen('CloseAll');
  %whos
end
refreshRate = NumFrames/toc
end
save refreshRate

parapin(0);

lastframe = Screen(window, 'MakeTexture', Black);
Screen(window, 'DrawTexture', lastframe);
% parapin(6); 
Screen(window,'Flip'); 
% parapin(4);
%end   

KbWait;
Screen('CloseAll');
clear
end
 
