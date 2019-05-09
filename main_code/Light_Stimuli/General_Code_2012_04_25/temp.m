%%
         Screen('Preference', 'SkipSyncTests', 1); 
	AssertOpenGL;

        % Open a double buffered fullscreen window and set default background
	% color to gray:
    global w;
    global screenRect
	[w screenRect]=Screen('OpenWindow',0 , [0 200 200] );

    
    for ii=1:2
test_drift_pattern_basic(30,.5, 0.005, 0, 400)
    end


	%The same commands wich close onscreen and offscreen windows also close
	%textures. sca
   
     
	Screen('CloseAll');   