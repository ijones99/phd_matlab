function marching_sqr( window, Settings)

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys

fprintf('Start Marching Square\n')
do_record = 1;
fullScreen=0;
showMouse = 0;

umToPixConv = Settings.umToPixConv;
% Values for size of stimulus square
% edgeLength = edgeLength/umToPixConv; % 600 pixels will convert to 1050 um
edgeLengthH = ceil(Settings.edgeLengthUm/umToPixConv);
edgeLengthV = ceil(Settings.edgeLengthUm/umToPixConv);
largeSquareSizePx = Settings.screenSizeUm/umToPixConv;
% Make sure this is running on OpenGL Psychtoolbox:
% AssertOpenGL;

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys

% whichScreen = 0;
% window = Screen(whichScreen, 'OpenWindow');
% Screen(window, 'FillRect', Settings.blackVal);


screenMatrixBase=zeros(largeSquareSizePx,largeSquareSizePx, 3);
IndsMiddleSqr = [round(largeSquareSizePx/2)-round(edgeLengthV/2) ...
    round(largeSquareSizePx/2)-round(edgeLengthV/2)+edgeLengthV]
screenMatrixBase(IndsMiddleSqr(1):IndsMiddleSqr(2),IndsMiddleSqr(1):IndsMiddleSqr(2),2) ...
    = 1;
screenMatrixBase(IndsMiddleSqr(1):IndsMiddleSqr(2),IndsMiddleSqr(1):IndsMiddleSqr(2),3) ...
    = 1;
size(screenMatrixBase)

screenMatrix{1} = screenMatrixBase; % ON stim
% screenMatrix{2} = screenMatrixBase; % OFF stim

screenMatrix{1}(find(screenMatrix{1}==0)) = Settings.RGB_OFF_STIM;
screenMatrix{1}(find(screenMatrix{1}==1)) = Settings.RGB_ON_STIM;
screenMatrix{1}(:,:,1) = 0;
% screenMatrix{2}(find(screenMatrix{2}==0)) = Settings.RGB_OFF_STIM_BKND;
% screenMatrix{2}(find(screenMatrix{2}==1)) = Settings.RGB_OFF_STIM;
% screenMatrix{2}(:,:,1) = 0;

% set background
screenMatrixBlank{1}=ones(largeSquareSizePx,largeSquareSizePx, 3);
screenMatrixBlank{1}(find(screenMatrixBlank{1}==1)) = Settings.RGB_ON_STIM_BKND;
screenMatrixBlank{1}(:,:,1) = 0;
wBlank(1) = Screen(window, 'MakeTexture', screenMatrixBlank{1});
% 
% screenMatrixBlank{2}=ones(largeSquareSizePx,largeSquareSizePx, 3);
% screenMatrixBlank{2}(find(screenMatrixBlank{2}==1)) = Settings.RGB_OFF_STIM_BKND;
% screenMatrixBlank{2}(:,:,1) = 0;
% wBlank(2) = Screen(window, 'MakeTexture', screenMatrixBlank{2});



Screen(window, 'DrawTexture', wBlank(1)    );
Screen(window,'Flip');
pause(1)
totalNumSteps = sum(round(Settings.movementRangeUm./repmat(Settings.stepSizeUm,size(Settings.movementRangeUm,1),1)),2);

for iDir = 1:size(Settings.movementRangeUm,1)
    for iRgbStimBrightness = 1:length(screenMatrix)
        startingPointInd = -round((Settings.movementRangeUm(iDir,:)/Settings.umToPixConv)/2);
        stepSizePx = round( Settings.stepSizeUm(iDir)/Settings.umToPixConv);
        doApaptation = 1;
        
        for iRepeat = 1%:Settings.stimulusRepeats
            for i=1:totalNumSteps(iDir)
                if doApaptation == 1
                    pause(Settings.adaptationTime)
                    doApaptation = 0;
                end
                w(iDir) = Screen(window, 'MakeTexture', circshift(screenMatrix{iRgbStimBrightness},...
                    [startingPointInd(1)+(i-1)*stepSizePx*(abs(startingPointInd(1))>0)...
                    startingPointInd(2)+(i-1)*stepSizePx*(abs(startingPointInd(2))>0)]));
                startingPointInd*stepSizePx+(i-1)*stepSizePx
                Screen('DrawTexture', window, w(iDir));
                parapin(6);
                Screen(window,'Flip');
                parapin(4);
                %pause(Settings.frameShowIntervalSec)
                pause(0.2)
                Screen('DrawTexture', window, wBlank(iRgbStimBrightness));
                parapin(6);
                Screen(window,'Flip');
                pause(0.2);
                %pause(Settings.frameShowIntervalSec)
                Screen('Close',w);
                
            end
            pause(.2)
    end
    pause(.2)
    end
end

Screen('DrawTexture', window, wBlank(iRgbStimBrightness));
Screen(window,'Flip');
pause(0.1)

% KbWait;
% Screen('CloseAll');

end