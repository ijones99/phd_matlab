
%% Initial setup to run analysis
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
flistName = 'flist_diff_size_dots_moving_bars';
dirName.figs = '../Figs/';
dirName.sta = strcat('../analysed_data/responses/sta/'); mkdir(dirName.sta); 
suffixName = strrep(flistName ,'flist','');
[ suffixName flist flistFileNameID dirName.gp  dirName.st ...
    dirName.el dirName.cl ] = setup_for_ntk_data_loading(flistName, suffixName);
elConfigClusterType = 'overlapping'; elConfigInfo = get_el_pos_from_nrk2_file;
elConfigInfo = add_ntk2_el_list_order_to_elconfiginfo(flist, elConfigInfo);
save('elConfigInfo.mat', 'elConfigInfo');
stimNames = {'White_Noise', 'Orig_Movie', 'Static_Median_Surround', 'Dynamic_Median_Surround', ...
    'Dynamic_Median_Surround_Shuffled', 'Pixelated_Surround_10_Percent', ...
    'Pixelated_Surround_50_Percent', 'Pixelated_Surround_90_Percent', 'Dots_of_Different_Sizes', 'Moving_Bars'};

%% get neuron names
neuronNames = get_neur_names_from_dir(dirName.st, 'st_');
%% get neuron inds from neuron names

selNeuronInds  =  get_file_inds_from_neur_names(dirName.St, '*.mat', neuronNames)
%% pre process data
% elNos = get_el_nos_from_neur_names( neuronNames);

[elNumbers ] = compare_els_between_dir_elconfiginfo(elConfigInfo,dirName.El , ...
   '*.mat', flist);
selElNumbers = elNumbers(17:25);
pre_process_data(suffixName, flistName, 'config_type','overlapping', 'sel_by_els',selElNumbers, 'kmeans_reps',5 );
% pre_process_data(suffixName, flistName, 'sel_by_els', selElNos,'kmeans_reps',5 )

%% SUPERVISED SORTING (MANUAL) - create the cl_ files
pattern = 'el*mat';
selNeuronInds = [ 5138];
sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_els_in_dir', selNeuronInds);...
    %'all_in_dir')%,%'sel_in_dir',selNeuronInds); %, );%

%% EXTRACT TIME STAMPS FROM SORTED FILES
% auto: create st_ files & create neuronIndList.mat file with names of all neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )

%% Plot dot info
selectSegment = 1;
binSize = 0.025;
[psthDataMeanSmoothed psthData psthDataSmoothed] = ...
    plot_psth_for_diff_size_dots(st_5455n98, frameno, selectSegment, ...
    StimMats, Settings, binSize)