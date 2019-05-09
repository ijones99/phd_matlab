function drifting_grating_plus_spots(w,Settings)

% drifting bars
angle = Settings.driftbars_angle;
cyclespersecond = Settings.driftbars_cyclespersecond;
gratingApertureDiamPx = round(Settings.gratingApertureDiamUm/Settings.UM_TO_PIX_CONV);%Settings.driftbars_gratingsApertureDiamPx; % gratings width
gratingsWidthPx = Settings.driftbars_gratingWidthPx;
texsize = gratingApertureDiamPx/2;% Half-Size of the grating image.


f = 1/(2*gratingsWidthPx);% f = Frequency of gratings in cycles per pixel.
% determines gratings size


rgbONValue = Settings.driftbars_rgbON;
rgbOFFValue  = Settings.driftbars_rgbOFF;

movieDurationSecs=Settings.DOT_DOT_SHOW_TIME; % Abort demo after 60 seconds.


% spot in center



% function DriftDemo6(angle, cyclespersecond, f)
% ___________________________________________________________________
%
% This demo demonstrates how to use Screen('DrawTexture') in combination
% with GLSL texture draw shaders to efficiently combine two drifting
% gratings with each other.
%
% The demo shows a drifting sine grating through a circular aperture. The
% drifting grating is surrounded by an annulus (a ring) that shows a second
% drifting grating with a different orientation.
%
% The demo ends after a key press or after 60 seconds have elapsed.
%
% The demo needs modern graphics hardware with shading support, otherwise
% it will abort.
%
% Compared to previous demos, we apply the aperture to the grating texture
% while drawing the grating texture, ie. in a single drawing pass, instead
% of applying it in a 2nd pass after the grating has been drawn already.
% This is simpler and faster than the dual-pass method. For this, we store
% the grating pattern in the luminance channel of a single texture, and the
% alpha-mask in the alpha channel of *the same texture*. During drawing, we
% apply a special texture filter shader (created via
% MakeTextureDrawShader()). This shader allows to treat the alpha channel
% separate from the luminance or rgb channels of a texture: It applies the
% alpha channel "as is", but applies some shift to the luminance or rgb
% channels of the texture.
%
% The procedure is repeated with a 2nd masked texture to create two
% different drifting gratings, superimposed to each other.
%
% Please note that the same effect can be achieved by clever alpha blending
% on older hardware, e.g., see DriftDemo5. The point of this demo is to
% demonstrate how to use GLSL shaders for more efficient ways of
% manipulating textures during drawing.
%
% Parameters:
%
% angle = Angle of the gratings with respect to the vertical direction.
% cyclespersecond = Speed of gratings in cycles per second.
% f = Frequency of gratings in cycles per pixel.
%
% _________________________________________________________________________
%
% see also: PsychDemos, MovieDemo






% try
    %     AssertOpenGL;
    
    % Get the list of screens and choose the one with the highest screen number.
    screenNumber=max(Screen('Screens'));
    
    % Find the color values which correspond to white and black.
    white=255%WhiteIndex(screenNumber);
    black=0%sBlackIndex(screenNumber);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);
    
    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
        gray=white / 2;
    end
    inc=white-gray;
    
    % Open a double buffered fullscreen window with a gray background:
    %     w =Screen('OpenWindow',screenNumber, gray);
    
    % Make sure this GPU supports shading at all:
    %     AssertGLSL;
    
    % Enable alpha blending for typical drawing of masked textures:
    %     Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    transScreenBrightness = beamer.brightness2rgb(...
         Settings.transitionScrBrightnessFraction*100);
     
%     [ w screenRect transitionScreen ] = supporting_functions.initialize_screen( ...
%          'transition_screen_dims', [gratingApertureDiamPx gratingApertureDiamPx], ...
%          'transition_screen_brightness',transScreenBrightness )
    
    % Create a special texture drawing shader for masked texture drawing:
    glsl = MakeTextureDrawShader(w, 'SeparateAlphaChannel');
    
    % Calculate parameters of the grating:
    p=ceil(1/f); % pixels/cycle, rounded up.
    fr=f*2*pi;
    visiblesize=2*texsize+1;
    
    % Create one single static grating image:
    x = meshgrid(-texsize:texsize + p, -texsize:texsize);
    %     save('data.mat', 'fr', 'x')
    %     grating = square(fr*x) ;
    grating = math.normalize_values( square(fr*x), [rgbOFFValue rgbONValue] );
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-texsize:texsize, -texsize:texsize)
    circle = white * (x.^2 + y.^2 <= (texsize)^2);
    
    % Set 2nd channel (the alpha channel) of 'grating' to the aperture
    % defined in 'circle':
    grating(:,:,2) = 0;
    grating(1:2*texsize+1, 1:2*texsize+1, 2) = 255;
    
    % Store alpha-masked grating in texture and attach the special 'glsl'
    % texture shader to it:
    
    transScrMtx = ones(Settings.SURR_DIMS);%set # pixels along edge or...
    transitionScreen = Screen(w, ...
        'MakeTexture',  Settings.transScreenVal*uint8(transScrMtx ));
    
    gratingtex1 = Screen('MakeTexture', w, grating , [], [], [], [], glsl);
    for iRepeats = 1:Settings.DOT_STIM_REPEATS
        for iDotBrightness = 1:length(Settings.DOT_BRIGHTNESS_VAL)
            for i = 1:length(Settings.PRESENTATION_ORDER)
                % Build a second drifting grating texture, this time half the texsize
                % of the 1st texture:
                texsizeInner = round(Settings.DOT_DIAMETERS(Settings.PRESENTATION_ORDER(i))./...
                    Settings.UM_TO_PIX_CONV)/2;
                visible2size = 2*texsizeInner;
                x = meshgrid(-texsizeInner:texsizeInner + p, -texsizeInner:texsizeInner);
                grating = Settings.DOT_BRIGHTNESS_VAL(iDotBrightness); %+ inc*cos(fr*x);
                
                % Create circular aperture for the alpha-channel:
                [x,y]=meshgrid(-texsizeInner:texsizeInner, -texsizeInner:texsizeInner);
                circle = white * (x.^2 + y.^2 <= (texsizeInner)^2);
                
                % Set 2nd channel (the alpha channel) of 'grating' to the aperture
                % defined in 'circle':
                grating(:,:,2) = 0;
                grating(1:2*texsizeInner+1, 1:2*texsizeInner+1, 2) = circle;
                
                % Store alpha-masked grating in texture and attach the special 'glsl'
                % texture shader to it:
                gratingtex2 = Screen('MakeTexture', w, grating, [], [], [], [], glsl);
                
                % Definition of the drawn source rectangle on the screen:
                srcRect=[0 0 visiblesize visiblesize];
                
                % Definition of the drawn source rectangle on the screen:
                src2Rect=[0 0 visible2size visible2size];
                
                % Query duration of monitor refresh interval:
                ifi=Screen('GetFlipInterval', w);
                
                waitframes = 1;
                waitduration = waitframes * ifi;
                
                % Recompute p, this time without the ceil() operation from above.
                % Otherwise we will get wrong drift speed due to rounding!
                p = 1/f; % pixels/cycle
                
                % Translate requested speed of the gratings (in cycles per second) into
                % a shift value in "pixels per frame", assuming given waitduration:
                shiftperframe = cyclespersecond * p * waitduration;
                
                % Perform initial Flip to sync us to the VBL and for getting an initial
                % VBL-Timestamp for our "WaitBlanking" emulation:
                vbl = Screen('Flip', w);
                
                % We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
                vblendtime = vbl + movieDurationSecs;
                i=0;
                
                % Animation loop: Run until timeout or keypress.
                parapin(6);
                parapin(4);
                while (vbl < vblendtime) && ~KbCheck
                    
                    % Shift the grating by "shiftperframe" pixels per frame. We pass
                    % the pixel offset 'yoffset' as a parameter to
                    % Screen('DrawTexture'). The attached 'glsl' texture draw shader
                    % will apply this 'yoffset' pixel shift to the RGB or Luminance
                    % color channels of the texture during drawing, thereby shifting
                    % the gratings. Before drawing the shifted grating, it will mask it
                    % with the "unshifted" alpha mask values inside the Alpha channel:
                    yoffset = mod(i*shiftperframe,p);
                    i=i+1;
                    
                    % Draw first grating texture, rotated by "angle":
                    Screen('DrawTexture', w, gratingtex1, srcRect, [], angle, [], [], [], [], [], [0, yoffset, 0, 0]);
                    
                    % Draw 2nd grating texture, rotated by "angle+45":
                    Screen('DrawTexture', w, gratingtex2, src2Rect, [], angle+45, [], [], [], [], [], [0, yoffset, 0, 0]);
                    
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
                 
                end
               
                
                Screen(w, 'DrawTexture', transitionScreen    );
                parapin(6);
                Screen(w,'Flip');
                parapin(4);
                pause(Settings.DOT_INTER_SUB_SESSION_WAIT);
            end
        end
    end
    % The same commands wich close onscreen and offscreen windows also close textures.
%     Screen('CloseAll');
    
% catch
%     % This "catch" section executes in case of an error in the "try" section
%     % above. Importantly, it closes the onscreen window if it is open.
%     
%     black=BlackIndex(w);
%     Screen('TextFont',w, 'Courier');
%     Screen('TextSize',w, 12);
%     Screen('TextStyle', w, 0);
%     Screen('FillRect',w, black);
%     % Draw text
%     Screen('DrawText',w, 'Error',1,1,[150*ones(1,3)]);
%     pause(0.5)
%     Screen('Flip', w);
% end %try..catch..
%       Screen(w, 'DrawTexture', transitionScreen    );
% Screen(window,'Flip');
pause(.5)

