function out = align_to_negative_peak(neuron)
% function out = ALIGN_TO_NEGATIVE_PEAK(neuron )


event_param=neuron.event_param;


% compute index of min_spike for best el:
get_templ=get_template(neuron);
templ=get_templ.data;
[v ind_best_el]=max(max(templ)-min(templ));

best_templ=templ(:,ind_best_el);
[v ind_min]=min(best_templ);

% Align other events
% ind_min is the position that will be used as reference for ts_pos. Make sure
% every event is aligned to that...

neuron.ts_pos=neuron.ts_pos+(ind_min-get_templ.pre);    % every ts_pos should be at min_spike
pos_loc=neuron.ts+neuron.ts_pos;

neuron.ts=pos_loc-event_param.pre2-event_param.margin;
neuron.ts_pos=ones(size(neuron.ts_pos))*event_param.pre2+event_param.margin;
out = neuron;


end