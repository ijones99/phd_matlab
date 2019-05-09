function show_moving_flashing_squares(varargin)
% options
% 'rec' [time]
% 'auto_flash' [frequency]
% 'dot_stim' [diameter]
% 'square_stim' [edge length]
% function: this function draws a square and then moves a flashing circle that steps across 
% the square. This is used to unsure that the stimulus is centered.


umToPixConv = 1.6;%1.72;
umToPixConvH = umToPixConv; %1.67; %this takes into account rotation of image (thus, it is projected as H)
umToPixConvV = umToPixConv; %1.74;%this takes into account rotation of image (thus, it is projected as V)
recordTimeSec = 1;
autoFlash = 1;
autoFlashFreq = 1;% Hz
DotStimSel = 1;
SquareStimSel = 0;
marchingStimWidthPx = round(150/umToPixConv);
backgroundEdgeLengthPx = round(1000/umToPixConv);
StimMarchIncrementPx = round(100/umToPixConv);
marchingLengthPx = round(500/umToPixConv);

% BRIGHTNESS VALUES
pixTransferFuncDir = '';
% load pixel transfer function
load(fullfile(pixTransferFuncDir, 'polyFitCoeff.mat'));
Settings.BLACK_VAL = 0;
Settings.WHITE_VAL = apply_projector_transfer_function(255,p);
blackVal = 0;
whiteVal =  apply_projector_transfer_function(255,p);
darkGrayVal = apply_projector_transfer_function(255*3/8,p);
grayVal = apply_projector_transfer_function(255*4/8,p);
lightGrayVal = apply_projector_transfer_function(255*4/8,p);

backgroundBrightnessVal = grayVal;
marchingStimBrightnessVal = whiteVal;

numRepeats = 5;

if ~isempty(varargin)
    for i=1:length( varargin )
        if strcmp( varargin{i}, 'rec')
            recordTimeSec = round(varargin{i+1});
        elseif strcmp( varargin{i}, 'auto_flash')
            autoFlashFreq = round(varargin{i+1})
        elseif strcmp( varargin{i}, 'background_brightness')
            backgroundBrightnessVal = round(varargin{i+1});
        elseif strcmp( varargin{i}, 'background_edge_length')
            backgroundEdgeLength = round(varargin{i+1})/umToPixConv;
        elseif strcmp( varargin{i}, 'dot_stim')
            DotStimSel = 1;
            SquareStimSel = 0;
        elseif strcmp( varargin{i}, 'marching_stim_brightness')
            marchingStimBrightnessVal = round(varargin{i+1});
        elseif strcmp( varargin{i}, 'marching_stim_width')
            marchingStimWidthPx = round(varargin{i+1})/umToPixConv;
            
        elseif strcmp( varargin{i}, 'marching_length')
            marchingLengthPx = round(varargin{i+1})/umToPixConv;
        elseif strcmp( varargin{i}, 'marching_increments')
            StimMarchIncrementPx = round(varargin{i+1})/umToPixConv;
        elseif strcmp( varargin{i}, 'square_stim')

            SquareStimSel = 1;
            DotStimSel = 0;
        end
    end
end

% number of marching steps
numSteps = floor((marchingLengthPx)/StimMarchIncrementPx );
shiftForStart = round((marchingLengthPx-marchingStimWidthPx)/2);

numLoops = numSteps^2;
% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar

% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL; HideCursor

% Open black window
screenid = max(Screen('Screens'));
window = Screen('OpenWindow', screenid, [0 0 0 0]);

transitionWindow = uint8(zeros(backgroundEdgeLengthPx, backgroundEdgeLengthPx,3));
transitionWindow(:,:,2:3) = backgroundBrightnessVal;
texTransition = Screen(window, 'MakeTexture', double(transitionWindow));
Screen('DrawTexture', window, texTransition);

Screen(window,'Flip');
        
% for the dot stimulus:
if DotStimSel
    % get square with circle in middle
    [indsSection stimulusImageOnBinary] = get_circle_inds(round(backgroundEdgeLengthPx), round(marchingStimWidthPx), 'center');
    
elseif SquareStimSel
    %     square in middel with ones; background zero
    stimulusImageOnBinary = zeros(backgroundEdgeLengthPx);
    backgroundEdgeLengthPx( round(end/2-marchingStimWidthPx/2):round(end/2+marchingStimWidthPx/2), ...
        round(end/2-marchingStimWidthPx/2):round(end/2+marchingStimWidthPx/2)) = 1
end

% init frames
frameOn = uint8(zeros(backgroundEdgeLengthPx,  backgroundEdgeLengthPx, numSteps*numSteps));

% shift marching stim to starting point
frameOn(:,:,1) = uint8(circshift(stimulusImageOnBinary, [-shiftForStart -shiftForStart]));

% build all frames
iFrame = 1;
for i=1:numSteps
    for j=1:numSteps
        frameOn(:,:,iFrame) = uint8(circshift(frameOn(:,:,1), [StimMarchIncrementPx*(i-1) StimMarchIncrementPx*(j-1) ]));
        iFrame = iFrame+1;
    end
end

% fill in brightness values and create off frames
frameOn(frameOn==0) = backgroundBrightnessVal; % surround value
frameOff = frameOn; % off frames 
frameOn(frameOn==1) = marchingStimBrightnessVal; 
frameOff(frameOff==1) = blackVal;

% save frameOn.mat frameOn
% save frameOff.mat frameOff
% create textures
tempFrame = double(zeros(size(frameOn,1),size(frameOn,2),3));

for i=1:numSteps*numSteps
    

    tempFrame(:,:,2) = double(frameOn(:,:,i)); tempFrame(:,:,3) = double(frameOn(:,:,i));
    texOn(i) = Screen(window, 'MakeTexture', double(tempFrame));
    
    tempFrame(:,:,2) = double(frameOff(:,:,i)); tempFrame(:,:,3) = double(frameOff(:,:,i));
    tex_OFF(i) = Screen(window, 'MakeTexture', double(tempFrame));
end
    

% 
% %     % resize to accomodate the projector; rotation included
% %     stimulusImageOnDotBinary = uint8(logical(imresize(stimulusImageOnDotBinary, ...
% %         [SquareEdgeLengthHPxProjAdj, SquareEdgeLengthVPxProjAdj])));
%     
%     % convert to pixel brightness values
%     stimulusImageOnDot = stimulusImageOnDotBinary;
%     % set background brightness; dot value = 1;
%     stimulusImageOnDot(find(stimulusImageOnDot==0)) = backgroundBrightnessVal;
%     stimulusImageOffDot = stimulusImageOnDot;
%     
%     % set dot brightness value
%     stimulusImageOnDot(find(stimulusImageOnDot==1)) =  whiteVal;
%     stimulusImageOffDot(find(stimulusImageOffDot==1)) =  blackVal;
%     
%     % put dot in 
%     
%     % three layers image
%     threeLayerStimImageOnDot = uint8(zeros( SquareEdgeLengthHPxProjAdj, SquareEdgeLengthVPxProjAdj,3));
%     threeLayerStimImageOffDot = threeLayerStimImageOnDot;
%      
%     % fill in 3 layer image
%     finalStimImageOn(:,:,2) =stimulusImageOnDot;
%     finalStimImageOn(:,:,3) =stimulusImageOnDot;
%     finalStimImageOff(:,:,2) =stimulusfrImageOffDot;
%     finalStimImageOff(:,:,3) =stimulusImageOffDot;    
%     
% elseif SquareStimSel
%      % projector-adjusted edge lengths
%     SquareEdgeLengthHPxProjAdj = round(SquareEdgeLengthPx*umToPixConvH/umToPixConv);
%     SquareEdgeLengthVPxProjAdj = round(SquareEdgeLengthPx*umToPixConvV/umToPixConv);
%     
%     % make square
%     finalStimImageOn=uint8(zeros(SquareEdgeLengthHPxProjAdj, SquareEdgeLengthVPxProjAdj, 3));
%     finalStimImageOn(:,:,2)=uint8(whiteVal*ones(SquareEdgeLengthHPxProjAdj,SquareEdgeLengthVPxProjAdj));
%     finalStimImageOn(:,:,3)=finalStimImageOn(:,:,2);    
%         
%     finalStimImageOff=uint8(zeros(SquareEdgeLengthHPxProjAdj, SquareEdgeLengthVPxProjAdj, 3));
%     finalStimImageOff(:,:,2)=uint8(blackVal*ones(SquareEdgeLengthHPxProjAdj,SquareEdgeLengthVPxProjAdj));
%     finalStimImageOff(:,:,3)=finalStimImageOff(:,:,2);   
% end
% 
% % make textures
% w(1) = Screen(window, 'MakeTexture', finalStimImageOn);
% w(2) = Screen(window, 'MakeTexture', finalStimImageOff);

% wait for space bar input
kbWait
% start to record
if recordTimeSec
    paramex(0)
    pause(.5);
    hidens_startSaving(0,'bs-hpws03')
    pause(.2)
end

for i=1:numLoops % goes through number of positions
    
    for jRepeats = 1:numRepeats % repeats for each position
        Screen('DrawTexture', window, texOn(i));
        paramex(6)
        Screen(window,'Flip');
        % if autoflashing, then pause half a frequency cycle and continue
        pause(.5*1/autoFlashFreq);
        
        Screen('DrawTexture', window, tex_OFF(i));
        paramex(4)
        Screen(window,'Flip');
        pause(.5*1/autoFlashFreq);
    end
    Screen('DrawTexture', window, texTransition);
    Screen(window,'Flip');
    pause(1.5*.5*1/autoFlashFreq); % pause for 1.5 times the flip intervals
    
end

% if recording, stop data acquisition
if recordTimeSec
    paramex(0)
    pause(.2);
    hidens_stopSaving(0,'bs-hpws03')
end

Screen(window, 'FillRect', blackVal);
pause(.5)


KbWait;
Screen('CloseAll');

end