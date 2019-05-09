% load flist, which contains all ntk2 file names
flist={};
flist_for_analysis;

% flist file used for obtaining waveforms in initial pass
flistNoForWaveforms = 1;

% -----------------------------------
% --- SPIKE SORTING OF ALL NEURONS IN PATCH ---

% BATCH PROCESSING RUN
% run overnight, create el_ files. Saves light timestamp data.
% input: proc/*.ntk output: ./analysed_data/01_Pre_Spikesorting/
flistName = flist{flistNoForWaveforms}; % name of file to sort for waveform ...
... shapes
TIME_TO_LOAD = 30; % time to load in minutes
% electrodes that constitute the middle patch
selElsInPatch = [5658 5660 5559 ...
    5659 5763 5662 ...
    5760 5762 5764 5761 5865 5867 ...
    5862 5864 5866 5863 5967 5969 ...
    5964 5966 5968 5965 6069 6071 ...
    6066 6068 6070 6067 6171 6173 ...
    6168 6170 6172 6169 6273 6275 ...
    ];
basic_sorting_batch_ctr_all_els(flistName ,TIME_TO_LOAD, selElsInPatch );

% SUPERVISED SORTING
% manual: create the cl_ files
fileNo = 5;
sort_ums_output(flist{fileNo},'all')

% EXTRACT TIME STAMPS & MAX 
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
for fileNo = [5]
    extract_spiketimes_from_cl_files(fileNo)
end

% SPIKE COMPARISONS
% produces heatmaps
create_ts_matching_heatmaps(flist{fileNo})

% PLOT RASTER PLOTS
% plots the raster plots for one stimulus
% set to ON and OFF
script_raster_plot_for_slit

% -- SELECTION OF SPECIFIC NEURONS -- %

% SELECT UNIQUE AND BEST NEURONS
script_get_list_of_unique_neurs 

% EXAMINE QUALITY OF SORTING
% must first load neuronIndsToCompare
plot_cluster_characteristics(neuronIndsToCompare(i), neuronIndsToCompare)

% BATCH SORT NEURONS OF INTEREST
% calls basic_sorting_batch_single_neur.m
% creates el_ files
script_obtain_spikes_from_ntk2.m

% INTERACTIVELY SORT NEURONS OF INTEREST
i=6, close all, sort_ums_output(flist{i},[56 24])

% BATCH SORT WHITE NOISE FILES
% calls basic_sorting_batch_single_neur.m
% creates el_ files

neursToProcess = [56 24];
flist = {};
flist_for_analysis;
flistName = flist{end-1};
TIME_TO_LOAD = 20;
basic_sorting_batch_single_neur_wn_chunk(neursToProcess, flistName, TIME_TO_LOAD)

% -----------------------------------
% --- GENERAL FUNCTIONS --- %

convert_inds_to_chs
convert_inds_to_inds
