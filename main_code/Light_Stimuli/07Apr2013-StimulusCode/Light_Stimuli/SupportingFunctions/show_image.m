function show_image
% show_gray([0...1]) full screen on or off

%%  File Runtime  
umToPixConv = 1.79;
interElecDistHoriz = 16;
interElecDistVert = 18.5;
imageVertPosSeq = [1 0 -1];

% list image names
imageFolder = 'LetterStimuli';
imageFileName = {'x_norm.png', 'a_norm.png', 'x_shear20.png', 'a_shear20.png'};
    
% -------------------- Stimulus Variables ------------------
save_recording = 1;
stimulusFrameDuration = .5;
flipIm = 1;%Flip the image for the projector?
bkgndEdgeLength = 1000;
paramSeq = [1e-2 1e-1 1 1e1 1e2]
numRepetitions = 10;  
waitTimeBetweenRuns = 1;

% file size:
fileRunTime = length(paramSeq)*(numRepetitions*stimulusFrameDuration*2+waitTimeBetweenRuns)/60;
runTime = length(imageFileName)* length(imageVertPosSeq) * fileRunTime;

fprintf('Runtime of %2.2f minutes (%.0f seconds).\n', runTime, runTime*60);
fprintf('Runtime of %2.2f minutes (%.0f seconds) for each file.\n', fileRunTime, fileRunTime*60);

%%


% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar

HideCursor

%Brightness Values
blackVal = 0;
whiteVal = 255;
darkGrayVal = 115;
grayVal = 163;
lightGrayVal = 205;

% get screen id and open a gray window
screenid = max(Screen ('Screens'));
window = Screen('OpenWindow', screenid, [0 grayVal grayVal  0]);

% make gray full screen
screenSize = get(0,'ScreenSize');
fullScreenImage = ones(bkgndEdgeLength,bkgndEdgeLength,3) ;
fullScreenImage(:,:,1) = 0;
w(1) = Screen(window, 'MakeTexture',  fullScreenImage*(grayVal)   );



beep
pause(.3)
beep
pause(.3)
HideCursor
KbWait;


for iImageFileName = imageFileName

for m=imageVertPosSeq
    
    % -------------------- Positioning ------------------
    horizontalPosition = 0; % block contains 3 squares [-1, 0 ,1] = [left, middle, right]
    verticalPosition = m; % block contains 3 locations [1, 0 ,-1] = [top, middle, bottom]
    objCoordsXY = [0,0]; % coords in um
    
    horizDistBtwnBlockCenters = 6*interElecDistHoriz/umToPixConv; % ctr-to-ctr distance between elec configs (horizontal), converted to pixels
    vertDistThirdsPositions = (2/6)*(17*interElecDistVert/umToPixConv); % thirds positions within
    % 17x6 elec configurations , converted to pixels
    subPosition = [horizontalPosition*horizDistBtwnBlockCenters  vertDistThirdsPositions*verticalPosition*(-1) ]
    
    

% perform flip and rotation of image
for i=2
    [imageLoaded map alpha] = imread(fullfile(imageFolder,iImageFileName{i-1}));
    
    for o=1:size(imageLoaded,2)
        o
    letterMap = find(imageLoaded(:,o,1)==0);
    if ~isempty(letterMap)
    letterHeightTop(o) = letterMap(end); %height of letter in pix
    letterHeightBottom(o) = letterMap(1);
    else
            letterHeightTop(o) = ceil(size(imageLoaded,1)/2) %height of letter in pix
            letterHeightBottom(o) = letterHeightTop(o) ;
    end
    end
    letterHeight = max( letterHeightTop ) - min( letterHeightBottom  )+1;
    letterScaleFactor = vertDistThirdsPositions/letterHeight;
    imageLoaded = imresize(imageLoaded,letterScaleFactor);
    
    if flipIm
%         imageModified = zeros(size(imageLoaded,2), size(imageLoaded,1),3 ) ;
        if exist('imageModified')
            clear imageModified
        end
        imageModified(:,:,3) = rot90(flipud(imageLoaded(:,:,3)),-1);
        imageModified(:,:,2) = rot90(flipud(imageLoaded(:,:,2)),-1);
    else
         imageModified = imageLoaded ;

    end

end



% create
j = 2;
for i=paramSeq
    letterAreaPix = length(find(imageModified(:,:,2) == 0));
    percentArea = i; % percent of the area
    selArea = (percentArea/100)*letterAreaPix;
    edgeLengthOfArea = sqrt(selArea);
    HSIZE = [ ceil(edgeLengthOfArea) ceil(edgeLengthOfArea)];
    SIGMA = 5;
    h = fspecial('gaussian',HSIZE,SIGMA);
    imageFiltered = imcomplement(imfilter(imcomplement( imageModified ),h));
    imageFiltered(:,:,1)=0;
    w(j) = Screen(window, 'MakeTexture',  imageFiltered*(grayVal/whiteVal)   );
    j = j+1;
end


maxX = screenSize(3); maxY =screenSize(4) ;
% objCoordsXY = [maxY - size(imageModified,1), maxX - size(imageModified,2)];
objCoordsXY(2)=-objCoordsXY(2); %account for fact that y-axis is reversed
objCoordsXY = objCoordsXY/umToPixConv + [ maxX/2 maxY/2 ]; % thus, (0,0) will be the middle of the screen
objCoordsXY = objCoordsXY + subPosition;

imWidth = size(imageModified,2);
imHeight = size(imageModified,1);

%Create coordinates:
correctionForRectWindow = (maxX - maxY)/2;
% Screen('DrawTexture', window, w(1), [], sourceRect, [], [], [], [], [], [], []);
% Screen(window,'Flip');

if flipIm

    %     objCoordsXY = [ (maxX - origobjCoordsXY(2) - imWidth/2 - correctionForRectWindow ), (maxY - origobjCoordsXY(1)-imHeight/2 + correctionForRectWindow)   ];% however, must rotate and flip coords
    objCoordsXY = [ (objCoordsXY(2)+correctionForRectWindow ), ( objCoordsXY(1)-correctionForRectWindow   )   ];% however, must rotate and flip coords

end
objCoordsXY = objCoordsXY + [- imWidth/2   -imHeight/2]; % Make sure image is positioned from center

sourceRect = [objCoordsXY(1),objCoordsXY(2), objCoordsXY(1)+size(imageModified,2),objCoordsXY(2 )+size(imageModified,1)];





parapin(0)
if save_recording
    hidens_startSaving(0,'bs-hpws03')
    pause(.5)
end

k = 2;



for i=1+1:1+length(paramSeq)
    parapin(0)
    for j=1:numRepetitions
        parapin(6)
        Screen('DrawTexture', window, w(k ), [], sourceRect, [], [], [], [], [], [], []);
        Screen(window,'Flip');
        pause(stimulusFrameDuration)
        parapin(4)
        Screen('DrawTexture', window, w(1), [], sourceRect, [], [], [], [], [], [], []);
        Screen(window,'Flip');
        pause(stimulusFrameDuration)
    end
    parapin(0)
    k = k+1;
    pause(waitTimeBetweenRuns);
end

if save_recording
    pause(.5);
    hidens_stopSaving(0,'bs-hpws03')
end

% Screen('DrawTexture', window, w(1), [], sourceRect, [], [], [], [], [], [], []);
% Screen(window,'Flip');
% pause(stimulusFrameDuration)

end
end
beep
pause(.3)

KbWait;
Screen('CloseAll');

end