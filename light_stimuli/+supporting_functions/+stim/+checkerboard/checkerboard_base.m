function checkerboard_base( w,Settings,StimMats )

try
    
    checkerboardEdgeLengthPx = round(Settings.CHECKBRD_NUM_SQUARES*...
        Settings.CHECKERBRD_SQUARE_SIZE_UM/Settings.UM_TO_PIX_CONV);
    visiblesize=checkerboardEdgeLengthPx;
    
    % Enable alpha blending for typical drawing of masked textures:
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    srcRect=[1 1 visiblesize(1) visiblesize(2)  ];
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
    
    checkerBoardSquareSizePx = round(Settings.CHECKERBRD_SQUARE_SIZE_UM/Settings.UM_TO_PIX_CONV);
%     checkerboardSurrDims = checkerBoardSquareSizePx*Settings.NUM_SQUARES_ALONG_EDGE;
    
    expanded_frame1 = ones(Settings.SURR_DIMS)*Settings.MID_GRAY_DECI;
    
%     LEFT_TOP_CORNER = round((Settings.WN_EDGE_LENGTH(1) - Settings.WN_EDGE_LENGTH(1))/2)+1;%left and top corner
%     ...of stimulus
%         RIGHT_BOTTOM_CORNER = Settings.WN_EDGE_LENGTH(1) + LEFT_TOP_CORNER;

    paramex(0);
    %     while (vbl < vblendtime) & ~KbCheck %#ok<AND2>
    Settings.grWaitframes = 1;

    % make transition screen
    checkerboardEdgeLengthPx = Settings.CHECKBRD_NUM_SQUARES*...
        Settings.CHECKERBRD_SQUARE_SIZE_UM/Settings.UM_TO_PIX_CONV;
    transW = Screen('MakeTexture', w,  double(Settings.BLACK_VAL)+...
        double(Settings.MID_GRAY_VAL)*double(zeros(checkerboardEdgeLengthPx(1),...
        checkerboardEdgeLengthPx(2))));
    Screen('DrawTexture', w, transW, srcRect);

    % Flip 'Settings.grWaitframes' monitor refresh intervals after last redraw.
    Screen('Flip', w);
    tic
    for i=1:Settings.STIM_DUR*Settings.STIM_FREQ*60
        % Shift the grating by "Settings.shiftperframe" pixels per frame. We pass
        % the pixel offset 'yoffset' as a parameter to
        % Screen('DrawTexture'). The attached 'glsl' texture draw shader
        % will apply this 'yoffset' pixel shift to the RGB or Luminance
        % color channels of the texture during drawing, thereby shifting
        % the gratings. Before drawing the shifted grating, it will mask it
        % with the "unshifted" alpha mask values inside the Alpha channel:
        %         expanded_frame1(LEFT_TOP_CORNER:RIGHT_BOTTOM_CORNER-1,LEFT_TOP_CORNER:RIGHT_BOTTOM_CORNER-1) =   ...
        expanded_frame1 =   ...
        (kron(StimMats.white_noise_frames(1:Settings.CHECKBRD_NUM_SQUARES(1),...
        1:Settings.CHECKBRD_NUM_SQUARES(2),i),ones(checkerBoardSquareSizePx)));
    
        expanded_frame1((expanded_frame1==0)) = Settings.CHECKERBRD_OFF;
        expanded_frame1((expanded_frame1==1)) = Settings.CHECKERBRD_ON;

        wn = Screen('MakeTexture', w,  double(Settings.BLACK_VAL)+...
            double(expanded_frame1 ));

        Screen('DrawTexture', w, wn, srcRect);

        paramex(6)
        % Flip 'Settings.grWaitframes' monitor refresh intervals after last redraw.
        Screen('Flip', w);
        

        paramex(4)
        pause(1/Settings.STIM_FREQ-0.0333);
        Screen('Close', wn);

    end
    fprintf('runTime = %3.3f',toc);

    Priority(0);

    Screen('DrawTexture', w, transW, srcRect);

    % Flip 'Settings.grWaitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', w);

catch
    % This "catch" section executes in case of an error in the "try" section
    % above. Importantly, it closes the onscreen window if it is open.
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    Priority(0);
end