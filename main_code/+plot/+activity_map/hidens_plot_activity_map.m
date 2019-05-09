function dataOut = hidens_plot_activity_map( event_data )

freq_thr=0.5;

% change to cell
if not(iscell(event_data))
    event_data = {event_data}
end


for i=1:length(event_data)
if i==1
    freq_map=event_data{i}.event_map.cnt./event_data{i}.event_map.time;
else
    freq_map=event_data{i}.event_map.cnt./event_data{i}.event_map.time+freq_map;
    
end
end

active_els=find(freq_map>=freq_thr);

dataOut.freq_map = freq_map(active_els);
dataOut.x = event_data{1}.x(active_els);
dataOut.y = event_data{1}.y(active_els);



plot_values_on_els(dataOut,dataOut.freq_map,'no_dots','no_border', 'no_plot_format');
% valid_els=find(event_data.event_map.time>=0);



end