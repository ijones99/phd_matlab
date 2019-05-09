%% ---------- Analysis of Data -------------
% This script will be used to go through the data during the experiment
% following recording of each patch

% Make a new directory for every experiment with the script
% ~/Scripts/create_exp_dir
%% ---------- PHASE I: FIND DS CELLS ----------------
% load all configs
dirName.configs = '~/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile18x3/';
dirName.configs = '../Configs/';
load(fullfile(dirName.configs, 'elConfigInfoAll.mat'))
% plot Configs
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
cmap = jet;
for i=1:length(elConfigInfoAll)   
    % plot waveforms
    plot_electrode_config('el_config_info', elConfigInfoAll{i}.info, ...
        'marker_color', cmap(randi([1, length(cmap)],1,1),:), ...
        'label', num2str(elConfigInfoAll{i}.number));
end
%% >>>> select a config and record from it while showing bars
%% ---------- After recording one patch, select patch number ----------
patchNum = 1; 
elConfigInfoAll{patchNum}.number
dirName.General = sprintf('ds_cell_search_%03d',patchNum); 
mkdir(sprintf('../proc/%s', dirName.General));
%% >>>> During experiment: put ntk file into directory
%% ---------- Set directories ----------
flistName = sprintf('flist_%s',dirName.General);
make_flist_select(strcat(flistName,'.m'),'add_dir', dirName.General)
numEls = 7; 
flist = {}; eval(flistName);
dirName.St = strcat('../analysed_data/',   dirName.General,'/03_Neuron_Selection/');
dirName.Cl = strcat('../analysed_data/',   dirName.General,'/02_Post_Spikesorting/');
dirName.analysedData = strcat('../analysed_data/',   dirName.General,'/');

% ----------- Create electrode groups for sorting ----------
elConfigInfoAll{patchNum}.info.selChNos = convert_el_numbers_to_chs(flist{1},elConfigInfoAll{patchNum}.info.selElNos);
selectedPatches = select_patches_exclusive_with_spaces(numEls, elConfigInfoAll{patchNum}.info, 'do_plot' );

%% Pre-spikesorting
numKmeansReps = 1; timeToLoad = 1; selThresholds  = 3.5;
    load_ntk_and_compute_energies(elConfigInfo, flist ,timeToLoad, selectedPatches, ...
        numKmeansReps, 'specify_output_dir', dirName.General,'set_threshold',selThresholds);

%% Manual spikesorting - create the cl_ files
sort_ums_output(flist, 'specify_output_dir',dirName.General, 'all_in_dir', 'display_mode_bands' ); %, 'sel_in_dir',1:12

%% Extract time stamps from files 
% auto: create st_ files & create neuronIndList.mat file with names of all neurons found.
dataAllNeurs = extract_data_from_cl_files_to_variable(...
    flist,elConfigInfoAll{patchNum}.info, 'specify_dir_name',dirName.General);

%% open chip viewer and plotter
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
%% Get ntk data
ntkData = get_ntk_data(flist, 1*60*2e4);
cmap = jet;
for i=1:length(dataAllNeurs)
    % Get waveforms
    [data] = extract_waveforms_from_ntkdata(ntkData, dataAllNeurs{i}.ts )
    
    % plot waveforms
    
    plot_footprints_all_els_2( elConfigInfoAll{patchNum}.info, data.waveform,...
        'plot_color', cmap(randi([1, length(cmap)],1,1),:));
end
%% get all config info from the created configurations 
dirName.configs = '~/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile18x3/';
dirName.configs = '../Configs/';
elConfigInfoAll = get_all_config_info(dirName.configs);
save(fullfile(dirName.configs, 'elConfigInfoAll.mat'), 'elConfigInfoAll');



