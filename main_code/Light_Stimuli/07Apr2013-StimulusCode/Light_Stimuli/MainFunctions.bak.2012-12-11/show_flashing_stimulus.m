function show_flashing_stimulus(varargin)
% options
% 'rec' [time]
% 'auto_flash' [frequency]
% 'dot_stim' [diameter]
% 'square_stim' [edge length]

umToPixConv = 1.72;
umToPixConvH = 1.67; %this takes into account rotation of image (thus, it is projected as H)
umToPixConvV = 1.74;%this takes into account rotation of image (thus, it is projected as V)
recordTimeSec = 0;
autoFlash = 0;
autoFlashFreq = 0;% Hz
DotStimSel = 1;
SquareStimSel = 0;
DotStimDiamPx = 150/umToPixConv;
SquareEdgeLengthPx = 1000/umToPixConv;

% Values for projector brightness
blackVal = 0;
whiteVal = 255;
darkGrayVal = 115;
grayVal = 163;
lightGrayVal = 205; 
dotBrightnessVal = whiteVal;
backgroundBrightnessVal = grayVal;

if ~isempty(varargin)
    for i=1:length( varargin )
        if strcmp( varargin{i}, 'rec')
            recordTimeSec = varargin{i+1};
        elseif strcmp( varargin{i}, 'auto_flash')
            autoFlashFreq = varargin{i+1}
        elseif strcmp( varargin{i}, 'set_square_brightness')
            backgroundBrightnessVal = varargin{i+1}
         elseif strcmp( varargin{i}, 'set_dot_brightness')
            dotBrightnessVal = varargin{i+1}   
            
        elseif strcmp( varargin{i}, 'dot_stim')
            DotStimSel = 1;
            SquareStimSel = 0;
            DotStimDiamPx = varargin{i+1}/umToPixConv;
        elseif strcmp( varargin{i}, 'dot_stim_square_surround')
            SquareEdgeLengthPx = varargin{i+1}/umToPixConv;
        elseif strcmp( varargin{i}, 'square_stim')
            SquareEdgeLengthPx = varargin{i+1}/umToPixConv
            SquareStimSel = 1;
            DotStimSel = 0;
        end
    end
end


% size of square
edgeLengthH = ceil(SquareEdgeLengthPx/umToPixConvH);
edgeLengthPxV = ceil(SquareEdgeLengthPx/umToPixConvV);

% number of loops
if recordTimeSec
    numLoops = ceil(recordTimeSec*autoFlashFreq);
else
    numLoops = 1e5;
end
% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar

% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL; HideCursor

% Open black window

    screenid = max(Screen('Screens'));

    window = Screen('OpenWindow', screenid, [0 0 0 0]);
%     whichScreen = 0;
%     window = Screen(whichScreen, 'OpenWindow');
%     Screen(window, 'FillRect', blackVal);

% for the dot stimulus:
if DotStimSel
    % get square with circle in middle
    [indsSection stimulusImageOnDotBinary] = get_circle_inds(round(SquareEdgeLengthPx), round(DotStimDiamPx), 'center');
    
    % projector-adjusted edge lengths
    SquareEdgeLengthHPxProjAdj = round(SquareEdgeLengthPx*umToPixConvH/umToPixConv);
    SquareEdgeLengthVPxProjAdj = round(SquareEdgeLengthPx*umToPixConvV/umToPixConv);
    
    % resize to accomodate the projector; rotation included
    stimulusImageOnDotBinary = uint8(logical(imresize(stimulusImageOnDotBinary, ...
        [SquareEdgeLengthHPxProjAdj, SquareEdgeLengthVPxProjAdj])));
    
    % convert to pixel brightness values
    stimulusImageOnDot = stimulusImageOnDotBinary;
    % set background brightness; dot value = 1;
    stimulusImageOnDot(find(stimulusImageOnDot==0)) = backgroundBrightnessVal;
    stimulusImageOffDot = stimulusImageOnDot;
    
    % set dot brightness value
    stimulusImageOnDot(find(stimulusImageOnDot==1)) =  dotBrightnessVal;
    stimulusImageOffDot(find(stimulusImageOffDot==1)) =  blackVal;
    
    % three layers image
    threeLayerStimImageOnDot = uint8(zeros( SquareEdgeLengthHPxProjAdj, SquareEdgeLengthVPxProjAdj,3));
    threeLayerStimImageOffDot = threeLayerStimImageOnDot;
     
    % fill in 3 layer image
    finalStimImageOn(:,:,2) =stimulusImageOnDot;
    finalStimImageOn(:,:,3) =stimulusImageOnDot;
    finalStimImageOff(:,:,2) =stimulusImageOffDot;
    finalStimImageOff(:,:,3) =stimulusImageOffDot;    
    
elseif SquareStimSel
     % projector-adjusted edge lengths
    SquareEdgeLengthHPxProjAdj = round(SquareEdgeLengthPx*umToPixConvH/umToPixConv);
    SquareEdgeLengthVPxProjAdj = round(SquareEdgeLengthPx*umToPixConvV/umToPixConv);
    
    % make square
    finalStimImageOn=uint8(zeros(SquareEdgeLengthHPxProjAdj, SquareEdgeLengthVPxProjAdj, 3));
    finalStimImageOn(:,:,2)=uint8(whiteVal*ones(SquareEdgeLengthHPxProjAdj,SquareEdgeLengthVPxProjAdj));
    finalStimImageOn(:,:,3)=finalStimImageOn(:,:,2);    
        
    finalStimImageOff=uint8(zeros(SquareEdgeLengthHPxProjAdj, SquareEdgeLengthVPxProjAdj, 3));
    finalStimImageOff(:,:,2)=uint8(blackVal*ones(SquareEdgeLengthHPxProjAdj,SquareEdgeLengthVPxProjAdj));
    finalStimImageOff(:,:,3)=finalStimImageOff(:,:,2);   
end

% make textures
w(1) = Screen(window, 'MakeTexture', finalStimImageOn);
w(2) = Screen(window, 'MakeTexture', finalStimImageOff);

% wait for space bar input
kbWait(66)
% start to record
if recordTimeSec
    parapin(0)
    pause(.5);
    hidens_startSaving(0,'bs-hpws03')
    pause(.2)
end
% repeat two stimuli

for i=1:numLoops    
    Screen('DrawTexture', window, w(1));
    parapin(6)
    Screen(window,'Flip');
    % if autoflashing, then pause half a frequency cycle and continue
    autoFlashFreq
    if autoFlashFreq
        pause(.5*1/autoFlashFreq);
    else
       kbWait(66) 
       pause(.15)
    end
    Screen('DrawTexture', window, w(2));
    parapin(4)
    Screen(window,'Flip');
    if autoFlashFreq
        pause(.5*1/autoFlashFreq);
    else
       kbWait(66) 
       pause(.15)
    end
end

% if recording, stop data acquisition
if recordTimeSec
    parapin(0)
    pause(.2);
    hidens_stopSaving(0,'bs-hpws03')
end

Screen(window, 'FillRect', blackVal);
pause(.5)


KbWait;
Screen('CloseAll');

end