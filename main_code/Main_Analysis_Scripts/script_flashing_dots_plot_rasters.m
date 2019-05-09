
%% GENERATE LOOKUP AND CONFIG TABLES
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
suffixName = '_spots_incr_size_bars';
flistName = 'flist_spots_incr_size_bars'
flist = {}; eval(flistName);
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
elConfigClusterType = 'overlapping';
if exist('GenFiles/elConfigInfo.mat','file')
    load GenFiles/elConfigInfo.mat
end
elNumbers = [ 1612        1914        2217        3127        3431        4340        4638        4741        4743        4944        4945        5149        5152        5255        5357        5456        5658        5865 ...
      6071        6168        6169        6172        6271        6275        6373        6478        6579        6581]

elConfigClusterType = 'overlapping';
%% pre process
pre_process_data(suffixName, flistName, elConfigClusterType, 'sel_by_el', elNumbers)

%% SUPERVISED SORTING (MANUAL) - create the cl_ files

% sort_ums_output(flist, 'add_dir_suffix',suffixName, 'all_in_dir' ); %, 'sel_in_dir',1:12
selEls = [5548];
sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_els_in_dir', selEls);%'all_in_dir');% ,  selEls(30:31)); %, 'sel_in_dir',1:12
%% REVIEW CLUSTERS
review_clusters(flist,'add_dir_suffix', suffixName,'all_in_dir'); %'sel_els', 5772, 'sel_in_dir', 12 

%% EXTRACT TIME STAMPS FROM SORTED FILES 
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.

extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )

%% SPIKE COMPARISONS
% produces heatmaps
tsMatrix = load_spiketrains(flistFileNameID);
binWidthMs =1;
[heatMap] = get_heatmap_of_matching_ts(binWidthMs, tsMatrix  );
figure, imagesc(heatMap);

%% FIND REDUNDANT CLUSTERS
[sortedRedundantClusterGroupsInds redundantClusterGroupsInds ] = ...
    find_redundant_clusters(tsMatrix, heatMap, ...
    'bin_width', 0.5,'matching_thresh',0.30 );

%% SELECT UNIQUE AND BEST NEURONS
% This function plots all of the neuron spike trains for the unique neurons
fileNo = 1;
selNeuronInds = find_unique_neurons(tsMatrix, heatMap, 'bin_width', 0.5, ...
    'matching_thresh',0.30 );
% look at el numbers
elNumbers= extract_el_numbers_from_files(  strcat('../analysed_data/', ...
    flistFileNameID,'/03_Neuron_Selection/'), ...
    'st_*', flist, 'sel_inds',sortedRedundantClusterGroupsInds{1} )

%% NEURON DATA QUALITY SHEETS
clusterNameCore = '6376n3';
plot_quality_datasheet_from_cluster_name(flist, suffixName, clusterNameCore, ...
    'file_save', 1 )
%% get inds
% elNumbers = {'5444n63' ;'5851n157';   '5548n11'};
elNumbers = 5548;
selNeuronInds = get_file_inds_from_el_numbers(dirNameSt, '*.mat', elNumbers);
%% plot waveforms for later identification
selectedNeurons = {'5548' 
};                                                              
plot_selected_neuron_waveforms(dirNameCl, selectedNeurons)
dirFigsOutput = strrep(dirNameFFile,'analysed_data', 'Figs');
% exportfig(gcf, fullfile(dirFigsOutput,strcat('Selected_Neurons_Waveforms','.ps')) ,'Resolution', 120,'Color', 'cmyk')
            
%% plot rasters
dateValTxt = get_dir_date;

dirNameFlashingDots = strcat(fullfile('../Figs/',   flistFileNameID, '/flashing_dot/rasters/'));
mkdir(dirNameFlashingDots);
selNeuronInds = [6:30];
textLabel = {'flashing_dots'}  
load StimCode/StimParams_SpotsIncrSize.mat
%% plot raster
plot_raster_for_flashing_dots(flistFileNameID, flist, dateValTxt, dirNameFlashingDots, ...
    selNeuronInds, textLabel, Settings, StimMats)
%% plot psth
plot_psth_for_flashing_dots(flistFileNameID, flist, dateValTxt, dirNameFlashingDots, ...
    selNeuronInds, textLabel, Settings, StimMats)
    

