function stim_random_dots_movie.m( w,Settings )
brightSqrValDeci  = [];

visiblesize=Settings.WN_EDGE_LENGTH(1);

% Enable alpha blending for typical drawing of masked textures:
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Definition of the drawn source rectangle on the screen:
%
%screen size: [left bottom width height]
screenSize = get(0,'ScreenSize');

srcRect=[1 1 visiblesize visiblesize  ];
% Query duration of monitor refresh interval:
ifi=Screen('GetFlipInterval', w)

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
vbl = Screen('Flip', w);

% We run at most 'Settings.STIM_DUR' seconds if user doesn't abort via keypress.
vblendtime = vbl + Settings.STIM_DUR;
i=0;

priorityLevel=MaxPriority(w); %#ok<NASGU>
Priority(priorityLevel);
% Animation loop: Run until timeout or keypress.
paramex(0);

LEFT_TOP_CORNER = round((Settings.WN_EDGE_LENGTH(1) - Settings.WN_EDGE_LENGTH(1))/2)+1;%left and top corner
...of stimulus
    RIGHT_BOTTOM_CORNER = Settings.WN_EDGE_LENGTH(1) + LEFT_TOP_CORNER;

paramex(0);
%     while (vbl < vblendtime) & ~KbCheck %#ok<AND2>
Settings.grWaitframes = 1;

% make transition screen
transW = Screen('MakeTexture', w,  double(Settings.BLACK_VAL)+...
    double(Settings.MID_GRAY_VAL)*double(zeros(Settings.WN_EDGE_LENGTH)));
Screen('DrawTexture', w, transW, srcRect);

% Flip 'Settings.grWaitframes' monitor refresh intervals after last redraw.
Screen('Flip', w);

fileNames = dir(fullfile(Settings.DIR_FRAMES,'*.mat'));

tic
for i=1:length(fileNames)
    % Shift the grating by "Settings.shiftperframe" pixels per frame. We pass
    % the pixel offset 'yoffset' as a parameter to
    % Screen('DrawTexture'). The attached 'glsl' texture draw shader
    % will apply this 'yoffset' pixel shift to the RGB or Luminance
    % color channels of the texture during drawing, thereby shifting
    % the gratings. Before drawing the shifted grating, it will mask it
    % with the "unshifted" alpha mask values inside the Alpha channel:
    %         expanded_frame1(LEFT_TOP_CORNER:RIGHT_BOTTOM_CORNER-1,LEFT_TOP_CORNER:RIGHT_BOTTOM_CORNER-1) =   ...
    
    load(fullfile(Settings.DIR_FRAMES,fileNames(i).name));
    
    wn = Screen('MakeTexture', w,  frame);
    
    Screen('DrawTexture', w, wn, srcRect);
    
    paramex(6)
    % Flip 'Settings.grWaitframes' monitor refresh intervals after last redraw.
    Screen('Flip', w);
    
    
    paramex(4)
    pause(1/Settings.FRAME_RATE-0.0166);
    Screen('Close', wn);
    
end
fprintf('runTime = %3.3f',toc);

Priority(0);

Screen('DrawTexture', w, transW, srcRect);

% Flip 'Settings.grWaitframes' monitor refresh intervals after last redraw.
vbl = Screen('Flip', w);


end