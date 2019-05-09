function pre_process_data_by_el(suffixName, flistName, elNumbers, elConfigClusterType)


%% GENERATE LOOKUP AND CONFIG TABLES
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
numEls = 7; 

flist = {}; eval(flistName);

flistFileNameID = get_flist_file_id(flist{1}, suffixName);
% dir names
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);

% ---------- Load Files if already generated ---------
% GenFiles/Selected_Patches_#.mat
% load GenFiles/elConfigInfo

%% CREATE CONFIG FILES
% FILE LOCATION: NRK file in 'Configs/'
elConfigInfo = get_el_pos_from_nrk2_file;

% add channel # to elConfigInfo & save
elConfigInfo.channelNr = convert_el_numbers_to_chs(flist{1}, elConfigInfo.selElNos); elConfigInfo = sort_el_config_info(elConfigInfo); saveElConfigInfo(elConfigInfo);
%% VIEW AND SELECT ELECTRODE PATCHES
if strcmp(elConfigClusterType,'overlapping')
    selectedPatches = select_patches_overlapping(numEls, elConfigInfo )
end
% selectedPatchesNew = parse_cell(selectedPatches,1:3);

%% COMPUTE ENERGIES, ETC. (AUTO)
% ---------- Settings ----------
tic
numKmeansReps = 3; timeToLoad = 200; selThresholds  = 3.5;
    load_ntk_and_compute_energies(elConfigInfo, flist ,timeToLoad, selectedPatches, ...
        numKmeansReps, 'add_dir_suffix', suffixName,'set_threshold',selThresholds, ...
      'sel_by_el_number', elNumbers) 
   toc 
%   'all_in



end