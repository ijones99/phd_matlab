function stim_marching_sqr( Settings)

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar
totalNumFlips = 4e4;
flashFreq = .5; %Hz
do_record = 0;
fullScreen=0;
showMouse = 0;

umToPixConv = Settings.umToPixConv;
% Values for size of stimulus square
% edgeLength = edgeLength/umToPixConv; % 600 pixels will convert to 1050 um
edgeLengthH = ceil(Settings.edgeLengthUm/umToPixConv);
edgeLengthV = ceil(Settings.edgeLengthUm/umToPixConv);
largeSquareSizePx = Settings.screenSizeUm/umToPixConv;
% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar

whichScreen = 0;
window = Screen(whichScreen, 'OpenWindow');
Screen(window, 'FillRect', Settings.blackVal);
if ~showMouse
    HideCursor
end
screenMatrixBlank=ones(largeSquareSizePx,largeSquareSizePx, 3).*Settings.grayVal;
screenMatrixBlank(:,:,1) = 0;
screenMatrixBase=zeros(largeSquareSizePx,largeSquareSizePx, 3);
IndsMiddleSqr = [round(largeSquareSizePx/2)-round(edgeLengthV/2) ...
    round(largeSquareSizePx/2)-round(edgeLengthV/2)+edgeLengthV]
screenMatrixBase(IndsMiddleSqr(1):IndsMiddleSqr(2),IndsMiddleSqr(1):IndsMiddleSqr(2),2) ...
    = 1;
screenMatrixBase(IndsMiddleSqr(1):IndsMiddleSqr(2),IndsMiddleSqr(1):IndsMiddleSqr(2),3) ...
    = 1;
size(screenMatrixBase)

screenMatrixON = screenMatrixBase;
screenMatrixOFF = screenMatrixBase;

screenMatrixON(find(screenMatrixON==0)) = Settings.grayVal;
screenMatrixON(find(screenMatrixON==1)) = Settings.whiteVal;
screenMatrixON(:,:,1) = 0;
screenMatrixOFF(find(screenMatrixOFF==0)) = Settings.grayVal;
screenMatrixOFF(find(screenMatrixOFF==1)) = Settings.darkGrayVal;
screenMatrixOFF(:,:,1) = 0;

wBlank = Screen(window, 'MakeTexture', screenMatrixBlank);
% w(2) = Screen(window, 'MakeTexture', Settings.blackVal*m);

totalNumSteps = round(Settings.movementRangeUm/Settings.stepSizeUm);

stepSizePx = round( Settings.stepSizeUm/Settings.umToPixConv);

startingPointInd = -round((Settings.movementRangeUm/Settings.umToPixConv)/2);

for iRepeat = 1:Settings.stimulusRepeats
    for i=1:totalNumSteps
        w(1) = Screen(window, 'MakeTexture', circshift(screenMatrixON,[0 startingPointInd+(i-1)*stepSizePx]));
        startingPointInd*stepSizePx+(i-1)*stepSizePx
        Screen('DrawTexture', window, w(1));
        paramex(6);
        Screen(window,'Flip');
        paramex(4);
        pause(Settings.frameShowIntervalSec)
        Screen('DrawTexture', window, wBlank);
        paramex(6);
        Screen(window,'Flip');
        paramex(4);
        pause(Settings.frameShowIntervalSec)
    end
    pause(2)
end
pause(3)
for iRepeat = 1:Settings.stimulusRepeats
    for i=1:totalNumSteps
        w(1) = Screen(window, 'MakeTexture', circshift(screenMatrixOFF,[0 startingPointInd+(i-1)*stepSizePx]));
        startingPointInd*stepSizePx+(i-1)*stepSizePx
        Screen('DrawTexture', window, w(1));
        paramex(6);
        Screen(window,'Flip');
        paramex(4);
        pause(Settings.frameShowIntervalSec)
        Screen('DrawTexture', window, wBlank);
        paramex(6);
        Screen(window,'Flip');
        paramex(4);
        pause(Settings.frameShowIntervalSec)
    end
    pause(2)
end

Screen('DrawTexture', window, wBlank);
Screen(window,'Flip');
pause(2)

KbWait;
Screen('CloseAll');

end