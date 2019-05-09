
% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
load settings/stimParams_Marching_Sqr.mat

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
numStimReps = input('Num Stim reps >> ')

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

screenMatrix{1}(find(screenMatrix{1}==0)) = Settings.RGB_ON_STIM_BKND;
screenMatrix{1}(find(screenMatrix{1}==1)) = Settings.RGB_ON_STIM;
screenMatrix{1}(:,:,1) = 0;
% screenMatrix{2}(find(screenMatrix{2}==0)) = Settings.RGB_OFF_STIM_BKND;
% screenMatrix{2}(find(screenMatrix{2}==1)) = Settings.RGB_OFF_STIM;
% screenMatrix{2}(:,:,1) = 0;

% set background
screenMatrixBlank{1}=ones(largeSquareSizePx,largeSquareSizePx, 3);
screenMatrixBlank{1}(find(screenMatrixBlank{1}==1)) = Settings.RGB_ON_STIM_BKND;
screenMatrixBlank{1}(:,:,1) = 0;

% screenMatrixBlank{2}=ones(largeSquareSizePx,largeSquareSizePx, 3);
% screenMatrixBlank{2}(find(screenMatrixBlank{2}==1)) = Settings.RGB_OFF_STIM_BKND;
% screenMatrixBlank{2}(:,:,1) = 0;
% wBlank(2) = Screen(window, 'MakeTexture', screenMatrixBlank{2});

stimFrameInfo = {};
totalNumSteps = sum(round(Settings.movementRangeUm./repmat(Settings.stepSizeUm,size(Settings.movementRangeUm,1),1)),2);
stepCounter = 0;
for iDir = 1:size(Settings.movementRangeUm,1)
    for iRgbStimBrightness = 1:length(screenMatrix)
        startingPointInd = -round((Settings.movementRangeUm(iDir,:)/2));
        stepSizePx = round( Settings.stepSizeUm(iDir)/Settings.umToPixConv);
        stepSizeUm = Settings.stepSizeUm(iDir);
        doApaptation = 1;
        
        for iRepeat = 1:numStimReps%Settings.stimulusRepeats
            for i=1:totalNumSteps(iDir)
                if doApaptation == 1
                  
                    doApaptation = 0;
                end
                
                stepCounter = stepCounter+1;
                stimFrameInfo.stim_show(stepCounter) = 1;
                stimFrameInfo.pos(stepCounter,1:2) = ...
                    [startingPointInd(1)+(i-1)*stepSizeUm*(abs(startingPointInd(1))>0) ...
                    startingPointInd(2)+(i-1)*stepSizeUm*(abs(startingPointInd(2))>0)];
                stimFrameInfo.rep(stepCounter) = iRepeat;
                stimFrameInfo.step_no(stepCounter) = i;
                
                 
            end
        
        end
      
    end
end


save('settings/stimFrameInfo_marchingSqr', 'stimFrameInfo')
