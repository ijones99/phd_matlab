%% VIEW ELECTRODES
plot_electrode_config

%% SUPERVISED SORTING
% manual: create the cl_ files
flistFile = { ...
        'flist_for_white_noise' ...
    }

flist = {};     eval([flistFile{1}]);
suffixName = '_marching_square_over_grid';
% suffixName = '_white_noise_plus_others';
sort_ums_output(flist, 'all_in_dir','add_dir_suffix',suffixName );

%% EXTRACT TIME STAMPS FROM SORTED FILES 
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )

%% SPIKE COMPARISONS
% produces heatmaps
flistFileNameID = 'T11_10_23_13_white_noise_plus_others';
tsMatrix = load_spiketrains(flistFileNameID);
binWidthMs =1;
[heatMap] = get_heatmap_of_matching_ts(binWidthMs, tsMatrix  );
figure, imagesc(heatMap);

%% FIND REDUNDANT CLUSTERS
[sortedRedundantClusterGroupsInds redundantClusterGroupsInds ] = find_redundant_clusters(tsMatrix, heatMap, ...
    'bin_width', 0.5,'matching_thresh',0.30 );

%% SELECT UNIQUE AND BEST NEURONS
% This function plots all of the neuron spike trains for the unique neurons
fileNo = 1;
selNeuronInds = find_unique_neurons(tsMatrix, heatMap, 'bin_width', 0.5,'matching_thresh',0.30 )
% look at el numbers
elNumbers= extract_el_numbers_from_files(  '../analysed_data/T11_10_23_13_white_noise_plus_others/03_Neuron_Selection/', ...
    'st_*', flist, 'sel_inds',sortedRedundantClusterGroupsInds{1} )

%% NEURON DATA QUALITY SHEETS
clusterNameCore = '5161n174';
plot_quality_datasheet_from_cluster_name(flist, suffixName, clusterNameCore, 'file_save', 1 )
