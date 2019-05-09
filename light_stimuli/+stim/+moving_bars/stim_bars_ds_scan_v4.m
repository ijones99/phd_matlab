function stim_bars_ds_scan_v4( w,Settings,screenRect )

% check for parapin
if exist('parapin.mexglx','file')
    parapinStr = 'parapin';
else
    parapinStr = 'paramex';
end

screenRefreshRate = 0.0167;


Screen(w, 'FillRect', [ 0 Settings.transScreenVal Settings.transScreenVal 0]);

% Define Half-Size of the grating image.

texsize=Settings.SURR_DIMS(2) / 2;

% Screen('Preference', 'SkipSyncTests', 1);
try
    % Enable alpha blending for proper combination of the gaussian aperture
    % with the drifting sine grating:
    %     Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Also need frequency in radians:
    %     fr=Settings.SCREEN_REFRESH_RATE*2*pi;
    
    % This is the visible size of the grating. It is twice the half-width
    % of the texture plus one pixel to make sure it has an odd number of
    % pixels and is therefore symmetric around the center of the texture:
    visiblesize=2*texsize+1;
    
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
    %     masktex=Screen('MakeTexture', w, mask);
    
    % Query maximum useable priorityLevel on this system:
    priorityLevel=MaxPriority(w); %#ok<NASGU>
    
    % We don't use Priority() in order to not accidentally overload older
    % machines that can't handle a redraw every 40 ms. If your machine is
    % fast enough, uncomment this to get more accurate timing.
    %Priority(priorityLevel);
    
    % Definition of the drawn rectangle on the screen:
    % Compute it to  be the visible size of the grating, centered on the
    % screen:
    dstRectDefault=[0 0 visiblesize visiblesize];
    %     dstRect=CenterRect(dstRect, screenRect);
    
    % Query duration of one monitor refresh interval:
    ifiScreen=Screen('GetFlipInterval', w);
    
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
    pixPerCycle=1/Settings.SCREEN_REFRESH_RATE;  % pixels/cycle
    
    transMatrix = double(Settings.transScreenVal)*double(ones(Settings.SURR_DIMS, ...
        Settings.SURR_DIMS  ));
    transMatrixTex=Screen('MakeTexture', w, transMatrix);
    
    % make bar image to show on screen
    horScrDim = Settings.SURR_DIMS(1); vertScrDim = Settings.SURR_DIMS(2);
    barImage = uint8(ones(vertScrDim, horScrDim*2 ));
    [blankBarY,blankBarX,blankBar3,blankBar4] = size(barImage);
    timerVal = [];
    for iRep = 1%:Settings.STIM_REPETITIONS
        for iOffset = 1%:length(Settings.OFFSET_UM)
            offsetPx = Settings.OFFSET_UM(iOffset)/Settings.UM_TO_PIX_CONV;
            fprintf('offset = %d\n',Settings.OFFSET_UM(iOffset))
            for iBrightness = 1%:length(Settings.RGB)
                rgbBrightness = Settings.RGB(iBrightness);
                
                for iBarLength = 1%:length(Settings.BAR_LENGTH)
                    barLengthPx = Settings.BAR_LENGTH(iBarLength)/Settings.UM_TO_PIX_CONV;
                    
                    for iBarWidth = 1%:length(Settings.BAR_WIDTH)
                        barWidthPx = Settings.BAR_WIDTH(iBarWidth)/Settings.UM_TO_PIX_CONV;
                        
                        for iVel = 2%1%:length(Settings.SPEED)
                            movingBarSpeedPx = Settings.SPEED(iVel)/Settings.UM_TO_PIX_CONV;
                            
                            for iAngle = 1:length(Settings.DIRECTIONS)
                                inputAngle = Settings.DIRECTIONS(iAngle);
                                currDirection = inputAngle;
                                fprintf('angle = %d\n', currDirection);
                                offsetXYPx = round(geometry.angle2xy(inputAngle,offsetPx));
                                offsetXYPx = [0 0];
                                dstRect=psychtoolbox.center_rect_offset(dstRectDefault, screenRect, ...
                                    offsetXYPx);
                                
                                
                                
                                % Animationloop:
                                Screen('DrawTexture', w, transMatrixTex);
                                
                                grCycleWidthPx = barLengthPx; % width of cycle in um
                                
                                screenRefreshRate=1/grCycleWidthPx;
                                
                                grDriftSpeedPxSec = movingBarSpeedPx;
                                grCyclesPerSecond = grDriftSpeedPxSec/grCycleWidthPx  ;
                                
                                grating = barImage*Settings.STIM_BACKGROUND_BRIGHTNESS;
                                barDimY1 = max(round(vertScrDim/2)-round(barWidthPx/2), 1)+offsetPx;
                                barDimY2 = min(round(vertScrDim/2)+round(barWidthPx/2), blankBarY)+offsetPx;
                                barDimX1 = max(round(horScrDim-barLengthPx/2),1);
                                barDimX2 = min(round(horScrDim+barLengthPx/2),blankBarX) ;
                                grating( barDimY1:barDimY2,...
                                    barDimX1:barDimX2)=rgbBrightness;
                                
                                gratingtex=Screen('MakeTexture', w, grating);
                                
                                % Translate requested speed of the grating (in cycles per second) into
                                % a shift value in "pixels per frame", for given waitduration: This is
                                % the amount of pixels to shift our srcRect "aperture" in horizontal
                                % directionat each redraw:
                                %                         shiftperframe= grCyclesPerSecond * pixPerCycle * waitduration;
                                shiftperframe= movingBarSpeedPx * waitduration;
                                % Perform initial Flip to sync us to the VBL and for getting an initial
                                % VBL-Timestamp as timing baseline for our redraw loop:
                                
                                vbl=Screen('Flip', w);
                                
                                % We run at most 'Settings.STIM_DUR' seconds if user doesn't abort via keypress.
                                vblendtime = vbl + 200;%Settings.SURR_DIMS(1)/shiftperframe;
                                eval([parapinStr,'(',num2str(6),')']);
                                i=0;
                                eval([parapinStr,'(',num2str(4),')']);
                                tic
                                while(i < (Settings.SURR_DIMS(1)+barLengthPx)/shiftperframe)%vblendtime)
                                    
                                    % Shift the grating by "shiftperframe" pixels per frame:
                                    % the mod'ulo operation makes sure that our "aperture" will snap
                                    % back to the beginning of the grating, once the border is reached.
                                    % Fractional values of 'xoffset' are fine here. The GPU will
                                    % perform proper interpolation of color values in the grating
                                    % texture image to draw a grating that corresponds as closely as
                                    % technical possible to that fractional 'xoffset'. GPU's use
                                    % bilinear interpolation whose accuracy depends on the GPU at hand.
                                    % Consumer ATI hardware usually resolves 1/64 of a pixel, whereas
                                    % consumer NVidia hardware usually resolves 1/256 of a pixel. You
                                    % can run the script "DriftTexturePrecisionTest" to test your
                                    % hardware...
                                    %         xoffset = mod(i*shiftperframe,p);
                                    xoffset = (i*shiftperframe)-round(barLengthPx/2);
                                    
                                    i=i+1;
                                    
                                    % Define shifted srcRect that cuts out the properly shifted rectangular
                                    % area from the texture: We cut out the range 0 to visiblesize in
                                    % the vertical direction although the texture is only 1 pixel in
                                    % height! This works because the hardware will automatically
                                    % replicate pixels in one dimension if we exceed the real borders
                                    % of the stored texture. This allows us to save storage space here,
                                    % as our 2-D grating is essentially only defined in 1-D:
                                    srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
                                    %                             dstRect = [0 0 Settings.SURR_DIMS(1) Settings.SURR_DIMS(2)];
                                    % Draw grating texture, rotated by "angle":
                                    %                             w, gratingtex, srcRect, dstRect, currDirection
                                    Screen('DrawTexture', w, gratingtex, srcRect, dstRect, currDirection);
                                    
                                    
                                    
                                    %         if drawmask==1
                                    %             % Draw gaussian mask over grating:
                                    %             %             Screen('DrawTexture', w, masktex, [0 0 visiblesize visiblesize], dstRect, Settings.angle);
                                    %         end;
                                    
                                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                                    % Providing this 'when' timestamp allows for optimal timing
                                    % precision in stimulus onset, a stable animation framerate and at
                                    % the same time allows the built-in "skipped frames" detector to
                                    % work optimally and report skipped frames due to hardware
                                    % overload:
                                    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifiScreen);
                                    
                                    % Abort demo if any key is pressed:
                                    
                                    if KbCheck
                                        pause(1);
                                        break;
                                    end
                                end
                                Screen('DrawTexture', w, transMatrixTex);
                                
                                eval([parapinStr,'(',num2str(6),')']);
                                vbl = Screen('Flip', w);
                                eval([parapinStr,'(',num2str(4),')']);
                                % Restore normal priority scheduling in case something else was set
                                % before:
                                Priority(0);
                                
                                %The same commands wich close onscreen and offscreen windows also close
                                %textures.
                                %     Screen('CloseAll');
                                %                                 tic
                                pause(Settings.STIM_TIME_OFF_SEC );
                                dlmwrite('pauseTimer', toc,'-append');
                                
                                
                                tic
                                pause(Settings.STIM_TIME_OFF_SEC );
                                dlmwrite('pauseTimer', toc,'-append');
                                %                              timerVal(end+1)
                                %                              = toc\
                                
                                junk = input('>>> ');
                            end
                            %                             save('timerVal.mat','timerVal')
                            %                             save('currSettings', 'Settings')
                        end
                    end
                end
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