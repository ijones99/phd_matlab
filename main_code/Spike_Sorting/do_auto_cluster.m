function do_auto_cluster(timeToLoad, flist, suffixName)

% -----------------------------------
% --- SPIKE SORTING OF ALL NEURONS IN PATCH ---

% BATCH PROCESSING RUN
% run overnight, create el_ files. Saves light timestamp data.
% input: proc/*.ntk output: ./analysed_data/01_Pre_Spikesorting/

% example suffixName = '_white_noise_plus_others';
% settings
numKmeansReps = 10;
selThresholds = 3.5;

% get flist filename id
idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
flistFileNameID = flist{1}(idNameStartLocation:end-11);

% set directories
dirParentAnalysedData = '../analysed_data/';
dirSpecAnalysedData = strcat('../analysed_data/', flistFileNameID,suffixName);

% find electrode numbers of processed data files
procElNos = extract_el_numbers_from_files(dirSpecAnalysedData,'el_*.mat',flist, 'suffix', ...
suffixName,'data_dir', '01_Pre_Spikesorting/'  );



% get remaining electrode-name defined groups
unprocElInds = find(~ismember(IdsOfAllElsInConfig,procElNos)>0);

patchesToSort = [unprocElInds(1:7)]; % break the clusters into groups for indpendent matlab processes

% SORT PATCHES OF INTEREST


basic_sorting_batch_ctr_all_els(flist ,timeToLoad, IdsOfAllElsInConfig, numKmeansReps,  ...
    'sel_by_el_number', unprocElInds ,'add_dir_suffix', ...
    suffixName,'set_threshold',selThresholds );

end