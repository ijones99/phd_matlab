function pre_process_data(suffixName, flistName, varargin)
% PRE_PROCESS_DATA(suffixName, flistName, varargin)
% varargin
%   'sel_by_els': center el number

% init vars
configType = 'overlapping';
tsRetrievalType = 'all_in_dir';
selEls = [];
selInds = [];
numKmeansReps = 1; timeToLoad = 200; 
selThresholds  = 4;
patchNo = [];
selectedPatches = {};
flist={};
dirNameSave = '';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'config_type')
            configType = varargin{i+1};
        elseif strcmp( varargin{i}, 'sel_by_els')
            tsRetrievalType = varargin{i};
            selEls = varargin{i+1};
        elseif strcmp( varargin{i}, 'flist')
            flist = varargin{i+1};
         elseif strcmp( varargin{i}, 'dir_name')
            dirNameSave = varargin{i+1};
        elseif strcmp( varargin{i}, 'sel_by_inds')
            tsRetrievalType = varargin{i};
            selInds= varargin{i+1};
        elseif strcmp( varargin{i}, 'kmeans_reps')
            numKmeansReps = varargin{i+1};
        elseif strcmp( varargin{i}, 'patches')
            selectedPatches = varargin{i+1};
        elseif strcmp( varargin{i}, 'patch_no')
            patchNo = varargin{i+1};
        elseif strcmp( varargin{i}, 'threshold')
            selThresholds = varargin{i+1};
        end
    end
end

%% GENERATE LOOKUP AND CONFIG TABLES
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
numEls = 7;
if isempty(flist)
    flist = {}; eval(flistName);
end
if isempty(dirNameSave)
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameSave = flistFileNameID;
    
end
    
% dir names
dirNameSt = strcat('../analysed_data/',   dirNameSave,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',   dirNameSave,'/02_Post_Spikesorting/');
dirNameEl = strcat('../analysed_data/',   dirNameSave,'/01_Pre_Spikesorting/');
dirNameFFile = strcat('../analysed_data/',   dirNameSave);

% ---------- Load Files if already generated ---------
% GenFiles/Selected_Patches_#.mat
% load GenFiles/elConfigInfo

%% CREATE CONFIG FILES
% FILE LOCATION: NRK file in 'Configs/'
elConfigInfo = flists.get_elconfiginfo_from_flist(flist);

% add channel # to elConfigInfo & save
elConfigInfo.channelNr = convert_el_numbers_to_chs(flist, elConfigInfo.selElNos); elConfigInfo = sort_el_config_info(elConfigInfo); saveElConfigInfo(elConfigInfo);
%% VIEW AND SELECT ELECTRODE PATCHES
if isempty(selectedPatches)
    if strcmp(configType,'overlapping')
        selectedPatches = select_patches_overlapping(numEls, elConfigInfo );
        %     save selectedPatches.mat selectedPatches
        % ---------- Settings ----------
        
        
    elseif strcmp(configType,'manual')
        selectedPatches = select_patches_manual(numEls, 1, elConfigInfo );
        % ---------- Settings ----------
        
    elseif strcmp(configType,'exclusive')
        selectedPatches = select_patches_exclusive(numEls, elConfigInfo );
        % ---------- Settings ----------
        
        
    end
else
    warning('Override config type with patches input.\n')
end
% selectedPatchesNew = parse_cell(selectedPatches,1:3);

% if certain patches selected, then only use selected patches
% if ~isempty(patchNo)
%     selectedPatches = selectedPatches(patchNo);
% end

%% COMPUTE ENERGIES, ETC. (AUTO)

tic
if strcmp(tsRetrievalType,'sel_by_els')
    load_ntk_and_compute_energies(elConfigInfo, flist ,timeToLoad, selectedPatches, ...
        numKmeansReps, 'add_dir_suffix', suffixName,'set_threshold',selThresholds, ...
        'sel_by_el_number', selEls, 'specify_output_dir', dirNameSave)
    
elseif  strcmp(tsRetrievalType,'sel_by_inds')
    load_ntk_and_compute_energies(elConfigInfo, flist ,timeToLoad, selectedPatches, ...
        numKmeansReps, 'add_dir_suffix', suffixName,'set_threshold',selThresholds, ...
        'sel_patch_number', selInds, 'specify_output_dir', dirNameSave)
    
    
elseif  strcmp(tsRetrievalType,'all_in_dir')
    load_ntk_and_compute_energies(elConfigInfo, flist ,timeToLoad, selectedPatches, ...
        numKmeansReps, 'add_dir_suffix', suffixName,'set_threshold',selThresholds, 'specify_output_dir', dirNameSave)
end
toc
                     


end