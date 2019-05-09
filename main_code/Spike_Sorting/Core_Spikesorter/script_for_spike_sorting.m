
% SORT PATCHES OF INTEREST BASEL ON ELECTRODE NUMBERS OF INTEREST

TIME_TO_LOAD = 20; %minutes
numKmeansReps = 5;
flist = {};     flist_checkerboard_n_03;
chunkSize = 20; ntk2 = load_ntk2_data(flist, chunkSize);
[elsInPatch chsInPatch indsInPatch] = get_electrodes_sorting_patches(ntk2, 7)
basic_sorting_batch_ctr_all_els(flist ,TIME_TO_LOAD, elsInPatch{1}, ...
    numKmeansReps);

%% SUPERVISED SORTING
% manual: create the cl_ files
flistFile = { ...
        'flist_checkerboard_n_03' ...
%         'flist_mov2_orig_stat_surr_med' ...
    }
flist = {};     eval([flistFile{1}]);

suffixName = '';
% suffixName = '_orig_stat_surr_med_plus_others'

% get electrode #'s of processed clusters
filePattern = 'el_*.mat';
dirName = '../analysed_data/T17_35_49_9/01_Pre_Spikesorting/';
procElNos= extract_el_numbers_from_files(  dirName, filePattern , flist)

% get electrode #'s of sorted neurons
sortedElNos = extract_el_numbers_from_files('cl_*.mat','flist',flist, ...
    'suffix', suffixName,'data_dir', '02_Post_Spikesorting/'  );

filePattern = 'el_*.mat';
dirName = '../analysed_data/T17_35_49_9/02_Post_Spikesorting';
sortedElNos= extract_el_numbers_from_files(  dirName, filePattern , flist)

% get el #'s of files that need to be sorted;
elNosLeftToSort = find(~ismember(procElNos,sortedElNos)==1)

%% SORT COMPUTED ENERGIES
sort_ums_output(flist, 'sel_els_in_dir', procElNos,'add_dir_suffix',suffixName );
% sort_ums_output(flistName, 'loading_mode', 'sel_in_dir','neur_inds', 4);

%% DOUBLE-CHECK CLUSTERING
review_clusters(flist,'sel_els', procElNos, 'add_dir_suffix', suffixName)

%% EXTRACT TIME STAMPS & MAX 
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
% extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName,'sel_els', procElNos)
%% SPIKE COMPARISONS
% produces heatmaps
% flistFileNameID = 'T11_10_23_6_orig_stat_surr_med_plus_others';
flistFileNameID = 'T17_35_49_9';
tsMatrix = load_spiketrains(flistFileNameID);
binWidthMs =1;
[heatMap] = get_heatmap_of_matching_ts(binWidthMs, tsMatrix  );
figure, imagesc(heatMap);

%%
[sortedRedundantClusterGroupsInds redundantClusterGroupsInds ] = find_redundant_clusters(tsMatrix, heatMap, ...
    'bin_width', 0.5,'matching_thresh',0.30 );

%% SELECT UNIQUE AND BEST NEURONS
% This function plots all of the neuron spike trains for the unique neurons
fileNo = 1;
selNeuronInds = find_unique_neurons(tsMatrix, heatMap, 'bin_width', 0.5,'matching_thresh',0.30 )
% look at el numbers
elNumbers= extract_el_numbers_from_files(  '../analysed_data/T17_35_49_9/03_Neuron_Selection/', ...
    'st_*', flist, 'sel_inds',sortedRedundantClusterGroupsInds{1} )



%% CHECK FOR CENTERING OF RECEPTIVE FIELDS
squareEdgeLength = 200;

[xi,yi] = meshgrid(1:squareEdgeLength, ...
    1:squareEdgeLength);

staStackDir = 'Figs/STA/white_noise';
gaussianFitDir = 'Figs/gaussian';
clusterName = '5772n8';
apertureDiameterPx = 400/1.72;

[percentWithinAperture gaussianFittedImage maskedFitImage result ] = ...
    fit_gaussian_to_sta( xi, yi, apertureDiameterPx, staStackDir,gaussianFitDir,clusterName )

h = figure, axis square, hold on, imagesc(maskedFitImage );
%%
exportfig(h,fullfile(gaussianFitDir,strcat('Gaussian_Fit_Mask_', ...
    clusterName)), ...
    'fontmode','fixed', 'fontsize',8,'Color', 'rgb' );

%% CHECK NATURAL MOVIE NEURONS FOUND

% file name
fileNamePattern = '*4753*';
saveFile = 0;

% filename id
idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
idNameEndLocation = strfind(flist{1},'.stream.ntk')-1;
flistFileNameID = strcat(flist{1}(idNameStartLocation:idNameEndLocation),suffixName);

% directory where st_ files are located
dirNameSt = strcat('../analysed_data/',flistFileNameID,'/03_Neuron_Selection/');

% get file names
fileNames = dir( fullfile(dirNameSt, fileNamePattern));

for i=1:length(fileNames)
    fileNameCore = strrep(strrep(fileNames(i).name,'.mat',''), 'st_','');
    plot_quality_datasheet_from_cluster_name(flist, suffixName, fileNameCore, ...
        'no_pca_plot','save_file',saveFile   );
    
end

%% LOAD SELECTED NEURON INDS

print_clusters_to_txt_file('../analysed_data/T11_10_23_13_white_noise_plus_others/03_Neuron_Selection/', ...
    'st*mat', 'neursSelByWNCheckerboard.txt','file_inds', selNeuronInds )

%% plot matches to specific neurons
plot_matches_for_sel_neurs(selNeuronInds, heatMap)

% Plot raster plot response to moving bar 
load ../analysed_data/16_07_02_39/selNeuronInds.mat
fileNo = 1;
raster_plot_for_moving_bar(fileNo, flist{fileNo}, selNeuronInds)

% PLOT RASTER PLOTS
% plots the raster plots for one stimulus
% set to ON and OFF
neuronIndsToCompare = [43]% 66]; 
raster_plot_for_slit(fileNo, flist{fileNo}, neuronIndsToCompare)

% -- SELECTION OF SPECIFIC NEURONS -- %

% SELECT UNIQUE AND BEST NEURONS
flistName = flist{fileNo};

% EXAMINE QUALITY OF SORTING
% must first load neuronIndsToCompare
neuronIndsToCompare = sort(neuronIndsToCompare);
for i=10:length(neuronIndsToCompare)
fileNo = 1;
outputDir = 'Figs/T11_10_23_13_white_noise_plus_others/QualityDataSheets/';
plot_cluster_characteristics(neuronIndsToCompare(i), ...
    neuronIndsToCompare,1,flist{fileNo},outputDir )
% plot_cluster_characteristics(i, neuronIndsToCompare,1,flist{fileNo} )
end


% BATCH SORT NEURONS OF INTEREST
% calls basic_sorting_batch_single_neur.m
% creates el_ files
selFileNameNos = [1];
neursToProcess = neuronIndsToCompare
get_spikes_from_ntk2(selFileNameNos, neursToProcess)

%% INTERACTIVELY SORT NEURONS OF INTEREST

fileNo = [1:15];
load ../analysed_data/16_07_02_39/selNeuronInds.mat
uniqueNeuronsIndSel = get_unique_electrode_numbers(flistName, selNeuronInds)
sort_ums_output(flist(fileNo), 'loading_mode', 'sel_in_list',uniqueNeuronsIndSel(1))
review_clusters(flist(fileNo), 'loading_mode', 'sel_in_dir',[12:14])

%%
neursToProcess = [56 24];
flist = {};
flist_for_analysis;
flistName = flist{end-1};
TIME_TO_LOAD = 60;
basic_sorting_batch_single_neur_wn_chunk(neursToProcess, flistName,  TIME_TO_LOAD)

% -----------------------------------
% --- GENERAL FUNCTIONS --- %

convert_inds_to_chs
convert_inds_to_inds
