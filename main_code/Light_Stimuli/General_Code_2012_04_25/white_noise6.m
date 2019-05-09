function white_noise6

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar

%
%WHITE_NOISE6 project a white noise stimulus with psychotoolbox
%
%
% Author:ijones 

%%
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%
%Basic Stimulus Settings
lengthOfSquareEdge = 25;%in umeters
Num_Pixels_Per_Square = round(lengthOfSquareEdge*1.75);
%Move from um to pixel units
numberOfCheckersOnOneSide = 15;
Edge_Length = numberOfCheckersOnOneSide*Num_Pixels_Per_Square;%in pix 

%Brightness Values
Black = 0;
White = 255;
DarkGrayVal = 115/White;
GrayVal = 163/White;
LightGrayVal = 205/White;

align_array = 0;
Running_Time = 45*60; %seconds to run
numberRepeats = 1;
Loop_Delay = 1/30;%0.0307;
Frame_Rate = 20;
Inter_Frame_Interval = (1/Frame_Rate) - Loop_Delay   ;   %seconds between frames (must be greater than 0.017)
Num_Frames = ceil((Running_Time/(Inter_Frame_Interval + Loop_Delay))/ numberRepeats)                        % Number of unique frames

% left over from user prompts
align_array = 0;
flashStim = 0;

createNewWhiteNoise = input('Create new whitenoise file [n/y]?','s');
if isempty(createNewWhiteNoise) || createNewWhiteNoise == 'n'
    %do not create a new whitenoise file; use Saved_Compressed_Frames,
    %array 'saved_frames' 
    load Saved_Compressed_Frames
elseif createNewWhiteNoise == 'y'
    %create new white noise array
    saved_frames = Gen_Save_WN_Frames(Num_Frames,Edge_Length, Num_Pixels_Per_Square );
else
    disp('Error with prompt input');
   
    return;
end

HideCursor

whichScreen = 0;
Screen('Preference', 'SkipSyncTests', 0)  

window = Screen('OpenWindow', whichScreen, [0 GrayVal*White GrayVal*White 0]);

%%% VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
White  = WhiteIndex(window); % pixel value for white
Black  = BlackIndex(window); % pixel value for black
Gray = (Black+White)/2;
save_stimulus = 0      ;% 1 = true, 0 = false;
%white = WhiteIndex(window); % pixel value for white
black = BlackIndex(window); % pixel value for black

Inter_Frame_Interval
expanded_frame1 = sparse(Edge_Length,Edge_Length);

if align_array == 1
    saved_frames(find(saved_frames==0)) = 1;
end
if flashStim == 1
    saved_frames(find(saved_frames==0),1:2:end) = 1;
    saved_frames(find(saved_frames==1),2:2:end) = 0;
end
beep
pause(.3)
beep
pause(.3)  

KbWait;
pause(.5);
parapin(0);

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,[0,1,1,0]);
for m = 1:numberRepeats
    max_gray = 0.50 - 0.05;
    min_gray = 0.50 + 0.30;
tic    
for i = 1:Num_Frames 
  
  expanded_frame1 =   (kron(saved_frames(:,:,i),ones(Num_Pixels_Per_Square)));
  expanded_frame1(find(expanded_frame1==0)) = .50-.05;
  expanded_frame1(find(expanded_frame1==1)) = .50+.30;
  
  w = Screen(window, 'MakeTexture',  Black+White*expanded_frame1 );  
  Screen(window, 'DrawTexture', w    );
  parapin(6); 
  Screen(window,'Flip'); 
  parapin(4);
  %pause for amount specified minus the intrinsic rate
  if(KbCheck)
    break;
  end;
  pause(Inter_Frame_Interval); 
 
  Screen('Close', w); 
  %Screen('CloseAll');
  %whos
end
m2 = Num_Frames/toc
end
save m2 m2

parapin(0);

last_frame = Screen(window, 'MakeTexture', black);
Screen(window, 'DrawTexture', last_frame);
% parapin(6); 
Screen(window,'Flip'); 
% parapin(4);
%end   

beep
pause(.3)


KbWait;
Screen('CloseAll');
clear

%%
end
 
