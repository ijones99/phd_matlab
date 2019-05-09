function y=cluster_multi_channel_PCA(temp_neur)

[spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'active_only','best_n',5,'do_plot');
% splitted2=PCA_recursive_cluster({temp_neur});
splitted2=analyze_and_correct_clusters(spl_neurs,'interactive',1);
splitted2=merge_neurons(splitted2,'interactive', 1,'no_isi');  % , 'no_plotter');
nnn.neurons=splitted2;
sorted_nnn=sort_neurons(nnn.neurons,'ts');
y=sorted_nnn;