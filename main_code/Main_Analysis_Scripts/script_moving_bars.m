%% GENERATE LOOKUP AND CONFIG TABLES
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
suffixName = '_moving_bars';
flistName = 'flist_moving_bars'
flist ={}; eval(flistName);
elNumbers = [4631 4938 5444 5749 5851 6059 6361 6464]; %
elConfigClusterType = 'overlapping';
pre_process_data(suffixName, flistName, 'sel_by_els',  elNumbers)
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
%% SUPERVISED SORTING (MANUAL) - create the cl_ files

sort_ums_output(flist, 'add_dir_suffix',suffixName,'all_in_dir');% 'sel_in_dir',3:6); %, 
% sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_in_dir',3)
%% REVIEW CLUSTERS
review_clusters(flist,'add_dir_suffix', suffixName,'all_in_dir'); %'sel_els', 5772, 'sel_in_dir', 12 

%% EXTRACT TIME STAMPS FROM SORTED FILES 
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )

%% SPIKE COMPARISONS
% produces heatmaps
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
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
elNumbers= extract_el_numbers_from_files(  strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/'), ...
    'st_*', flist, 'sel_inds',sortedRedundantClusterGroupsInds{1} )

%% NEURON DATA QUALITY SHEETS
clusterNameCore = '6376n3';
plot_quality_datasheet_from_cluster_name(flist, suffixName, clusterNameCore, 'file_save', 1 )

%% GET THE FILE INDS FROM THE FILE NUMBERS


%%
dateValTxt = '07Aug2012';
dirNameSTA = strcat(fullfile('../Figs/',   flistFileNameID, '/STA'));
selNeuronInds = [1:20]
textLabel = {...
    'Orig'; 'Stat_Surr' ...
     }
    
%     'DynSurr'; 'DynSurrShuff'; 'Pix10'; 'Pix50'; 'Pix90' }
    
pattern = '*.mat';
elNumbers = [4938, 5444, 5647, 5750, 5851];
selNeuronInds = get_file_inds_from_el_numbers(dirNameEl, pattern, elNumbers)

plot_raster_for_natural_movie(flistFileNameID, flist, dateValTxt, dirNameSTA, selNeuronInds, textLabel)