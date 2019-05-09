function do_spikesorting_preprocessing(flist, suffixName, elConfigInfo, varargin)


% init vars
doAllPatches = 1; %default do all patches
numElsInPatch  = 7;
timeToLoad = 55; % time to load in minutes

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'do_sel_patches')
            selectedPatches = varargin{i+1};
            doAllPatches = 0;
        else
            fprintf('argument not recognized\n');
        end
    end
end

% get flist filename id
idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
flistFileNameID = flist{1}(idNameStartLocation:end-11);

% set directories
dataDir = strcat('../analysed_data/', flistFileNameID,suffixName);


% for case of doing all patches
if doAllPatches
    
    % find the electrodes in the directory
    elNumbersFound = extract_el_numbers_from_files(dataDir,'el_*.mat',flist, 'suffix', ...
        suffixName,'dataDir', '01_Pre_Spikesorting/'  );
    
    % load electrodes numbers to load (all electrodes within the block)
    load(fullfile('GenFiles', 'allElsInSelConfig.mat'))
    
    % get remaining electrode-name defined groups
    unprocElInds = find(~ismember(selElIds,elNumbersFound)>0);
    
    
    for i=1:length(elConfigInfo.selElNumbers)
        [elsInPatch{i} elsNumberInList{i}]=get_closest_electrodes(elConfigInfo.selElNumbers(i), elConfigInfo, numElsInPatch)
    end
else
    
end

%%
numKmeansReps = 5;
patchesToSort = [unprocElInds(1:30)]; % break the clusters into groups for indpendent matlab processes
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
        
    basic_sorting_batch_ctr_all_els(flist ,timeToLoad, selElsInPatch, numKmeansReps,  ...
        'sel_by_el_number', unprocElInds ,'add_dir_suffix', ...
        suffixName,'set_threshold',selThresholds );
end