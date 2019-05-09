function neuron=get_all_spike_traces_all_el(neuron, ntk2)

%%  required neuron fields for spike extractions

neuron.el_idx = ntk2.el_idx
neuron.x = ntk2.x
neuron.y = ntk2.y
neuron.trace = neuron.trace


%% get data
event_param=neuron.event_param;
nr_evs=length(neuron.ts);
for c=1:size(ntk2.sig,2)
%     neuron.trace{c}.data=zeros([size(yica_n{k}.trace,1)  nr_evs]);
end
for e=1:nr_evs
    
    for c=1:size(ntk2.sig,2)        %cut traces from working.sig
%         temp_neur.trace{c}.data(:,e)=ntk2.sig(yica_n{k}.ts(e):(yica_n{k}.ts(e)
%         +event_param.tlen2+2*event_param.margin-1),c);
        neuron.trace{c}.ts_idx = neuron.trace{1}.ts_idx;
        neuron.trace{c}.data(:,e)=ntk2.sig(neuron.ts(e):(neuron.ts(e)+event_param.tlen2+2*event_param.margin-1),c);
    end
end

% neuron.template=get_template(neuronget_template)
neuron.template=get_template(neuron,neuron.template.pre,neuron.template.post);
end