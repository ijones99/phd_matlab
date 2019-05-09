function natural_movie_01( window,Settings,screenRect, movieDir, numReps )


%% Stim Runtime         
waitTimeBetweenPresentations =1;
                  
% -------------------- Stimulus Constants ------------------
% framerate for displaying movie
frameRate = 30;
nativeRate = 60;
frameCount = 600;% should be 600
%Brightness Values
blackVal = 0;
whiteVal = 255; 
darkGrayVal = 115;
grayVal = 163;
lightGrayVal = 205;


% check for parapin
if exist('parapin.mexglx','file')
    parapinStr = 'parapin';
else
    parapinStr = 'paramex';
end

screenRefreshRate = 0.0167;


Screen(window, 'FillRect', [ 0 Settings.transScreenVal Settings.transScreenVal 0]);

% Define Half-Size of the grating image.


% Screen('Preference', 'SkipSyncTests', 1);
try
    % Enable alpha blending for proper combination of the gaussian aperture
    % with the drifting sine grating:
    %     Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Also need frequency in radians:
    %     fr=Settings.SCREEN_REFRESH_RATE*2*pi;
    
    % This is the visible size of the grating. It is twice the half-width
    % of the texture plus one pixel to make sure it has an odd number of
    % pixels and is therefore symmetric around the center of the texture:
   
    
    % Create one single static grating image:
    %
    % We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
    % define the whole grating! If the 'srcRect' in the 'Drawtexture' call
    % below is "higher" than that (i.e. visibleSize >> 1), the GPU will
    % automatically replicate pixel rows. This 1 pixel height saves memory
    % and memory bandwith, ie. it is potentially faster on some GPUs.
    %
    % However it does need 2 * texsize + p columns, i.e. the visible size
    % of the grating extended by the length of 1 period (repetition) of the
    % sine-wave in pixels 'p':
    %     x = meshgrid(-texsize:texsize + pixPerCycle, 1);
    
    % Compute actual cosine grating:
    %     grating=gray + inc*cos(fr*x);
    
    %     grating = barImage(:,round(end*.25):round(end*.75))*Settings.MID_GRAY_VAL;
    
    
    % Create a single gaussian transparency mask and store it to a texture:
    % The mask must have the same size as the visible size of the grating
    % to fully cover it. Here we must define it in 2 dimensions and can't
    % get easily away with one single row of pixels.
    %
    % We create a  two-layer texture: One unused luminance channel which we
    % just fill with the same color as the background color of the screen
    % 'gray'. The transparency (aka alpha) channel is filled with a
    % gaussian (exp()) aperture mask:
    %     mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
    %     [x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
    %     circleMask=Circle(length(mask)/2  );%white * (1 - exp(-((x/90).^2)-((y/90).^2)));
    %     circleMask = (1-circleMask)*255;
    %     circleMask(find( circleMask==0  ))=163;
    %     mask(:, :, 2) = circleMask;
    %
    %     masktex=Screen('MakeTexture', window, mask);
    
    % Query maximum useable priorityLevel on this system:
    priorityLevel=MaxPriority(window); %#ok<NASGU>
    
    % We don't use Priority() in order to not accidentally overload older
    % machines that can't handle a redraw every 40 ms. If your machine is
    % fast enough, uncomment this to get more accurate timing.
    %Priority(priorityLevel);
    
    % Definition of the drawn rectangle on the screen:
    % Compute it to  be the visible size of the grating, centered on the
    % screen:
    
    %     dstRect=CenterRect(dstRect, screenRect);
    
    % Query duration of one monitor refresh interval:
    ifiScreen=Screen('GetFlipInterval', window);
    
    % Translate that into the amount of seconds to wait between screen
    % redraws/updates:
    
    % waitframes = 1 means: Redraw every monitor refresh. If your GPU is
    % not fast enough to do this, you can increment this to only redraw
    % every n'th refresh. All animation paramters will adapt to still
    % provide the proper grating. However, if you have a fine grating
    % drifting at a high speed, the refresh rate must exceed that
    % "effective" grating speed to avoid aliasing artifacts in time, i.e.,
    % to make sure to satisfy the constraints of the sampling theorem
    % (See Wikipedia: "Nyquist?Shannon sampling theorem" for a starter, if
    % you don't know what this means):
    waitframes = 1;
    
    % Translate frames into seconds for screen update interval:
    waitduration = waitframes * ifiScreen;
    
    % Recompute p, this time without the ceil() operation from above.
    % Otherwise we will get wrong drift speed due to rounding errors!
    
 
    
    %load the file names of frames of the movie
frameNames = dir(strcat(movieDir,'*bmp'));

% number frames
% frameCount = length(frameNames);

%load files
movieDims = [582 582];
frame = uint8(zeros(movieDims(1),movieDims(2),600));
% frame2 = uint8(zeros(movieDims(1),movieDims(2),length(frameNames)));
for i=1:600
    frame(:,:,i) = imread(strcat(movieDir, frameNames(i).name ),'bmp');
    fprintf('Loaded frame %d\n', i);
end
% create all textures
% toc
w = zeros(frameCount,1);
currFrame = zeros(size(frame,1),size(frame,2),3);
for i=1:frameCount
    currFrame(:,:,2) = frame(:,:,i);
    currFrame(:,:,3) = frame(:,:,i);
   w(i) = Screen(window, 'MakeTexture',  currFrame);
end
flashInterval = 1/frameRate - 1/nativeRate;

    for k=1:numReps
        for j=1:frameCount
            
            Screen('DrawTexture', window, w(j));
            Screen(window,'Flip');
            pause(flashInterval)
            
            if KbCheck
                break;
            end
        end
    end
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
    % We're done!
    return;
end