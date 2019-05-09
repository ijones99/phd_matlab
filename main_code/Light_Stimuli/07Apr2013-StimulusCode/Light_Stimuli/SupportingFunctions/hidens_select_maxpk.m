function y=hidens_select_maxpk(neurons, n_list, electrodes_per_neuron, max_cost, c_sr)


y=cell(1,0);

for i=n_list
    %maxpk=max(n
    [maxpk_v maxpk_i]=max(abs(neurons{i}.template.data));
    cost=max_cost-maxpk_v/max(maxpk_v)*max_cost;
    [s six]=sort(cost);
    
    for el=1:electrodes_per_neuron
        el_idx=six(el);
        y{end+1}.label=['maxpk_n' num2str(i) '_e' num2str(el)];
        y{end}.x=neurons{i}.x(el_idx);
        y{end}.y=neurons{i}.y(el_idx);
        y{end}.cost=cost(six(el));
        if c_sr~=1
            y{end}.c_sr=c_sr;
        end
    end
     
end






