function selEls = select_electrodes_on_activity_map(activity_map) 
% function selEls = select_electrodes_on_activity_map(activity_map) 

figure, hold on

hidens_generate_amplitude_map(activity_map,'no_border','no_colorbar', ...
'no_plot_format','do_use_max');
gui.plot_hidens_els
numStaticEls = 6;
fprintf('Please select %d electrodes on which to spikesort.', numStaticEls);
junk = input('Hit enter and select els:>>');
selEls = clickelectrode('num_els',6)
fprintf('Done selecting electrodes.\n');

end

