function stim_drifting_linear_pattern_v2(window,Settings, screenRect)
% function DriftDemo5(angle, cyclespersecond, f, drawmask)
% ___________________________________________________________________
%
% Display animated gratings using the new Screen('DrawTexture') command.
%
% The demo shows two drifting sine gratings through circular apertures. The
% 1st drifting grating is surrounded by an annulus (a ring) that shows a
% second drifting grating with a different orientation.
%
% The demo ends after a key press or after 20 seconds have elapsed.
%
% The demo uses alpha-blending and color buffer masking for masking the
% gratings with circular apertures.
%
% Parameters:
%
% angle = Angle of the grating with respect to the vertical direction.
% cyclespersecond = Speed of grating in cycles per second. f = Frequency of
% grating in cycles per pixel.
% drawmask = If set to 1, then a gaussian aperture is drawn over the grating
% _________________________________________________________________________
%
% see also: PsychDemos, MovieDemo

% HISTORY
% 4/1/09 mk Adapted from Allen Ingling's DriftDemo.m

speedPxPerSec = Settings.SPEED_UM_PER_SEC*Settings.UM_TO_PIX;


texsize=round(Settings.STIM_EDGE_SIZE_PX/2); % Half-Size of the grating image.

try
    AssertOpenGL;
    
    % Get the list of screens and choose the one with the highest screen number.
    screenNumber=max(Screen('Screens'));
    
    % Find the color values which correspond to white and black.
    white=255;%WhiteIndex(screenNumber);
    black=0;%BlackIndex(screenNumber);
    
    % Open a double buffered fullscreen window with a gray background:
    %[window screenRect]=Screen('OpenWindow',screenNumber, gray);
    
    visiblesize=2*texsize+1;
    
    % Create one single static grating image:
    % MK: We only need a single texture row (i.e. 1 pixel in height) to
    % define the whole grating! If srcRect in the Drawtexture call below is
    % "higher" than that (i.e. visibleSize >> 1), the GPU will
    % automatically replicate pixel rows. This 1 pixel height saves memory
    % and memory bandwith, ie. potentially faster.
    
    grating = Settings.PATTERN_VECTOR;
    
    % Store grating in texture:
    gratingtex=Screen('MakeTexture', window, grating,[], 1);
        
    % Definition of the drawn rectangle on the screen:
    dstRect=[0 0 visiblesize visiblesize];
    dstRect=CenterRect(dstRect, screenRect);
    
    % Query duration of monitor refresh interval:
    ifi=Screen('GetFlipInterval', window);
    
    waitframes = 1;
    waitduration = waitframes * ifi;
    
    % Translate requested speed of the grating (in cycles per second)
    % into a shift value in "pixels per frame", assuming given
    % waitduration: This is the amount of pixels to shift our "aperture" at
    % each redraw:
    shiftperframe= (Settings.SPEED_UM_PER_SEC/Settings.UM_TO_PIX) * waitduration;
    

    
    % We run at most 'Settings.STIM_DUR_SEC' seconds if user doesn't abort via
    % keypress.
 
    % Animationloop:
    for iAngle = 1:length(Settings.DIR)
        % Perform initial Flip to sync us to the VBL and for getting an initial
        % VBL-Timestamp for our "WaitBlanking" emulation:
        vbl=Screen('Flip', window);
        vblendtime = vbl + Settings.STIM_DUR_SEC;
        i=0;
        
        while (vbl < vblendtime) && ~KbCheck
            
            % Shift the grating by "shiftperframe" pixels per frame:
            xoffset = i*shiftperframe;
            i=i+1;
            
            % Define shifted srcRect that cuts out the properly shifted rectangular
            % area from the texture:
            srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
            
            % Draw grating texture, rotated by "angle":
            Screen('DrawTexture', window, gratingtex, srcRect, dstRect, Settings.DIR(iAngle));
            
            
            Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,[0,1,1,0]);
               
            % Disable alpha-blending, restrict following drawing to alpha channel:
            %Screen('Blendfunction', window, GL_ONE, GL_ZERO, [0 0 0 1]);
            
            % Enable DeSTination alpha blending and reenalbe drawing to all
            % color channels. Following drawing commands will only draw there
            % the alpha value in the framebuffer is greater than zero, ie., in
            % our case, inside the circular 'dst2Rect' aperture where alpha has
            % been set to 255 by our 'FillOval' command:
            %Screen('Blendfunction', window, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
            
            
            % Restore alpha blending mode for next draw iteration:
            %Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            % Flip 'waitframes' monitor refresh intervals after last redraw.
            parapin(6);
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
%             Screen(window,'Flip');
            parapin(4);
        end;
        Screen('FillRect',window, double(Settings.transScreenVal)*[0 1 1]);
        % Screen('DrawText',window, ['Done: ', stimName],1,1,[100*ones(1,3)]);
        
        Screen('Flip', window);
        pause(Settings.INTERSTIM_PAUSE);
        Priority(0);
  
    end
catch
    %this "catch" section executes in case of an error in the "try" section
    %above. Importantly, it closes the onscreen window if its open.
%     Screen('CloseAll');
%     Priority(0);
%     psychrethrow(psychlasterror);
end %try..catch..
end
