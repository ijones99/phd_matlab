function marching_sqr_v2( window, Settings)
% Version 2 uses xy coords for each location
%
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
wBlank(1) = Screen(window, 'MakeTexture', screenMatrixBlank{1});

Screen(window, 'DrawTexture', wBlank(1)    );
Screen(window,'Flip');


for iRepeat = 1:Settings.stimulusRepeats
    for iRgbStimBrightness = 1:length(screenMatrix)
        
        
        for iLoc=1:size(Settings.XY_LOC_um,1)
            iLocRand = Settings.RAND_XY_LOC(iLoc);
            currXYLoc_px = round(Settings.XY_LOC_um(iLocRand,:)/Settings.umToPixConv);
            
            w = Screen(window, 'MakeTexture', circshift(screenMatrix{iRgbStimBrightness},...
                [-currXYLoc_px(2)  currXYLoc_px(1)]));
            
            Screen('DrawTexture', window, w);
            parapin(6);
            Screen(window,'Flip');
            parapin(4);
            Settings.XY_LOC_um(iLocRand,:)
            pause(1)
            Screen('DrawTexture', window, wBlank(iRgbStimBrightness));
            parapin(6);
            Screen(window,'Flip');
            parapin(4);
            pause(1)
            Screen('Close',w);
            
        end
        
    end
    
end


Screen('DrawTexture', window, wBlank(iRgbStimBrightness));
Screen(window,'Flip');
pause(0.1)

% KbWait;
% Screen('CloseAll');

end