% -----------------------------------
% --- SPIKE SORTING OF ALL NEURONS IN PATCH ---
% cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/03July2012/Matlab
% BATCH PROCESSING RUN
% run overnight, create el_ files. Saves light timestamp data.
% input: proc/*.ntk output: ./analysed_data/01_Pre_Spikesorting/
TIME_TO_LOAD = 55; % time to load in minutes
flistFile = { ...
        'flist_build_footprint' ...
%         'flist_mov2_orig_stat_surr_med' ...
    }
flist = {};     eval([flistFile{1}]);

suffixName = '_multiple_configs_around_neuron';
% suffixName = '_orig_stat_surr_med_plus_others'

% get flist filename id
idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
flistFileNameID = flist{1}(idNameStartLocation:end-11);

% set directories
DATA_DIR = '../analysed_data/';
FILE_DIR = strcat('../analysed_data/', flistFileNameID,suffixName,'_plus_others/');

% dir in which to put output files

procElNos = extract_el_numbers_from_files(FILE_DIR,'el_*.mat',flist, 'suffix', ...
suffixName,'data_dir', '01_Pre_Spikesorting/'  );

% load electrodes numbers to load (all electrodes within the block)
load selElIds

% get remaining electrode-name defined groups
unprocElInds = find(~ismember(selElIds,procElNos)>0);

% get inds

%%
numKmeansReps = 5;
patchesToSort = [unprocElInds(1:6)]; % break the clusters into groups for indpendent matlab processes
%%
% electrodes that constitute the middle patch
selElsInPatch = selElIds;
% elNumbers = 5161;
for iFlistFile =1:length(flistFile)
    % load flist, which contains all ntk2 file names
    flist={};
    eval([flistFile{iFlistFile}]);
    
    % SORT PATCHES OF INTEREST
    selThresholds = 3.5;
        
    basic_sorting_batch_ctr_all_els(flist ,TIME_TO_LOAD, selElsInPatch, numKmeansReps,  ...
        'sel_by_el_number', unprocElInds ,'add_dir_suffix', ...
        suffixName,'set_threshold',selThresholds );
end