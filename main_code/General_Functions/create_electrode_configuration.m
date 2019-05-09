function y=create_electrode_configuration(sorted_nnn_DS,electrode_number)


%% for the moment you can only give from 2-5 electrodes


k=0;
cost_neuron=25;
config=[];
indici_x=[];
indici_y=[];
all_els=[];
value_pktpk=[];
for i=1:length(sorted_nnn_DS)
neuron=sorted_nnn_DS{i};
[v1 ind1]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
neuron.template.data(:,ind1)=zeros(size(neuron.template.data,1),1);
[v2 ind2]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
neuron.template.data(:,ind2)=zeros(size(neuron.template.data,1),1);


config(k+1).coordinates=['Neuron DSRGC',int2str(i),': ',int2str(neuron.x(ind1)),'/',int2str(neuron.y(ind1)),', ', int2str(cost_neuron),'/',int2str(cost_neuron)];
k=k+1;
config(k+1).coordinates=['Neuron DSRGC',int2str(i),': ',int2str(neuron.x(ind2)),'/',int2str(neuron.y(ind2)),', ', int2str(cost_neuron),'/',int2str(cost_neuron)];
k=k+1;


if electrode_number==2
indici_x=[indici_x neuron.x(ind1) neuron.x(ind2) ];
indici_y=[indici_y neuron.y(ind1) neuron.y(ind2) ];
all_els=[all_els neuron.el_idx(ind1) neuron.el_idx(ind2)];
value_pktpk=[value_pktpk v1 v2];
end    

if electrode_number==3
[v3 ind3]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
neuron.template.data(:,ind3)=zeros(size(neuron.template.data,1),1);
config(k+1).coordinates=['Neuron DSRGC',int2str(i),': ',int2str(neuron.x(ind3)),'/',int2str(neuron.y(ind3)),', ', int2str(cost_neuron),'/',int2str(cost_neuron)];
k=k+1;    
indici_x=[indici_x neuron.x(ind1) neuron.x(ind2) neuron.x(ind3)];
indici_y=[indici_y neuron.y(ind1) neuron.y(ind2) neuron.y(ind3)];
all_els=[all_els neuron.el_idx(ind1) neuron.el_idx(ind2) neuron.el_idx(ind3)];
value_pktpk=[value_pktpk v1 v2 v3];
end    

if electrode_number==4
[v3 ind3]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
neuron.template.data(:,ind3)=zeros(size(neuron.template.data,1),1);
config(k+1).coordinates=['Neuron DSRGC',int2str(i),': ',int2str(neuron.x(ind3)),'/',int2str(neuron.y(ind3)),', ', int2str(cost_neuron),'/',int2str(cost_neuron)];
k=k+1;        
[v4 ind4]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
neuron.template.data(:,ind4)=zeros(size(neuron.template.data,1),1);
config(k+1).coordinates=['Neuron DSRGC',int2str(i),': ',int2str(neuron.x(ind4)),'/',int2str(neuron.y(ind4)),', ', int2str(cost_neuron),'/',int2str(cost_neuron)];
k=k+1;
indici_x=[indici_x neuron.x(ind1) neuron.x(ind2) neuron.x(ind3) neuron.x(ind4)];
indici_y=[indici_y neuron.y(ind1) neuron.y(ind2) neuron.y(ind3) neuron.y(ind4)];
all_els=[all_els neuron.el_idx(ind1) neuron.el_idx(ind2) neuron.el_idx(ind3) neuron.el_idx(ind4)];
value_pktpk=[value_pktpk v1 v2 v3 v4];
end

if electrode_number==5
[v3 ind3]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
neuron.template.data(:,ind3)=zeros(size(neuron.template.data,1),1);
config(k+1).coordinates=['Neuron DSRGC',int2str(i),': ',int2str(neuron.x(ind3)),'/',int2str(neuron.y(ind3)),', ', int2str(cost_neuron),'/',int2str(cost_neuron)];
k=k+1;      
[v4 ind4]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
neuron.template.data(:,ind4)=zeros(size(neuron.template.data,1),1);
config(k+1).coordinates=['Neuron DSRGC',int2str(i),': ',int2str(neuron.x(ind4)),'/',int2str(neuron.y(ind4)),', ', int2str(cost_neuron),'/',int2str(cost_neuron)];
k=k+1;
[v5 ind5]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
neuron.template.data(:,ind5)=zeros(size(neuron.template.data,1),1);
config(k+1).coordinates=['Neuron DSRGC',int2str(i),': ',int2str(neuron.x(ind5)),'/',int2str(neuron.y(ind5)),', ', int2str(cost_neuron),'/',int2str(cost_neuron)];
k=k+1;

indici_x=[indici_x neuron.x(ind1) neuron.x(ind2) neuron.x(ind3) neuron.x(ind4) neuron.x(ind5)];
indici_y=[indici_y neuron.y(ind1) neuron.y(ind2) neuron.y(ind3) neuron.y(ind4) neuron.y(ind5)];
all_els=[all_els neuron.el_idx(ind1) neuron.el_idx(ind2) neuron.el_idx(ind3) neuron.el_idx(ind4) neuron.el_idx(ind5)];
value_pktpk=[value_pktpk v1 v2 v3 v4 v5];
end



end
y.config=config;
y.ind_x=indici_x;
y.ind_y=indici_y;
y.all_els=all_els;
y.pktpk_values=value_pktpk;
