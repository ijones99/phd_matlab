%% show gray for centering
show_gray(0,900)

%% flashing stim
show_flash(0,900)

%% main stimuli 
% SET THE CORRECT POSITION for marching_bars_new( ) & show_image( )!!!!!!

% marching bar, 3 sizes: 6:52 mins
marching_bar_new([200 100 50 ],3,1)
Screen('CloseAll');
% drifting square wave series; middle size, all speeds. This is for comparison with
% sinusoidal gratings
driftingsqrwavegratingseries2

% drifting sine wave series; all speeds, directions and
% sizes: 18 mins
driftingsingratingseries2

% Drifting square wave with marching squares (same file); 
% middle size
driftingsqrwavegratingseries_with_marching_squares2

% stimulus with letters
show_image

















