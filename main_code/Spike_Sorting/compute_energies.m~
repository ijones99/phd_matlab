function compute_energies(flist, selectedPatches)

% run overnight, create el_ files. Saves light timestamp data.
% input: proc/*.ntk output: ./analysed_data/01_Pre_Spikesorting/
TIME_TO_LOAD = 55; % time to load in minutes


suffixName = '_white_noise_plus_others';
% suffixName = '_orig_stat_surr_med_plus_others'

% get flist filename id
idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
flistFileNameID = flist{1}(idNameStartLocation:end-11);

% set directories
dataDir = '../analysed_data/';
specDataDir = strcat('../analysed_data/', flistFileNameID,suffixName,'_plus_others/');

% dir in which to put output files
procElNos = extract_el_numbers_from_files(specDataDir,'el_*.mat',flist, 'suffix', ...
suffixName,'data_dir', '01_Pre_Spikesorting/'  );

numKmeansReps = 4;

for iFlistFile =1:length(selectedPatches)
    
    % SORT PATCHES OF INTEREST
    selThresholds = 3.5;
        
    load_ntk_and_compute_energies(flist ,TIME_TO_LOAD, selElsInPatch, numKmeansReps,  ...
        'add_dir_suffix', suffixName,'set_threshold',selThresholds );
end