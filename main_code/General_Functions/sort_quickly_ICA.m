clear all
close all
sorted_nnn_DS=cell(0,0); 
%%
% cd ~/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/26Nov2010_te//Matlab
flist={};
flist_white_noise; 


%%
kk=1;
siz=200000;
all_data=new_neo_ica_spike_sorter(flist{kk},siz,30,1,0); % NEO_ICA_MULTICHANNEL_SPIKE_SORTING

%% create the structure with all DS cells
for i=1:length(all_data.neurons)
sorted_nnn_DS{length(sorted_nnn_DS)+1}=all_data.neurons{i};
end

%%
sorted_nnn_DS_selected=plot_RGCs_bar_response(sorted_nnn_DS,'interactive'); %plot output of spike sorting

%% export electrodes for NEURODISHROUTER


coordinates=create_electrode_configuration(sorted_nnn_DS_selected,5);

[value_unique index_unique]=unique(coordinates.all_els,'first');
index_unique=sort(index_unique);
figure;plot(coordinates.ind_x(index_unique),-coordinates.ind_y(index_unique),'.r')

for i=1:length(index_unique)
disp(coordinates.config(index_unique(i)).coordinates)
end
