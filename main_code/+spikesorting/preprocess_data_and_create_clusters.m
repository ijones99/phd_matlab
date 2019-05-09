function [flistFileNameID flist flistName] = preprocess_data_and_create_clusters(varargin)

patchIdx= [];
sortInputOpt = 'elidx';
selectedPatches = {};
thresholdVal = 4.5;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'patch_no')
            sortInputOpt = varargin{i};
            patchIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'patches') % use actual patch structures
            selectedPatches = varargin{i+1};
        end
    end
end

% if isempty(patchIdx) && ~isempty(selectedPatches)
%    error('patch numbers must be selected.\n');
%    
% elseif ~isempty(patchIdx) && isempty(selectedPatches)
%    error('patches must be entered.\n');
% end

%% GENERATE LOOKUP AND CONFIG TABLES
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
% cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/20Dec2012_2/Matlab
numEls = 7;
stimTypes = {'_wn_checkerboard'; ...
    '_marching_sqr_and_moving_bars'; ...
    '_marching_sqr'; ...
    '_moving_bars'; ...
    '_spots';...
    }
fprintf('Select stimulation type:\n ')
for i=1:length(stimTypes)
   fprintf('(%d) %s\n', i, stimTypes{i}); 
end
stimTypeSel = input('Select type [number] >> ');



fileRunNameNumber = input('Enter stim run number >>')
suffixName = sprintf('%s_n_%02d',stimTypes{stimTypeSel}, fileRunNameNumber);
flistName = sprintf('flist%s_n_%02d',stimTypes{stimTypeSel}, fileRunNameNumber);
make_flist_select([flistName,'.m'])
flist ={}; eval(flistName);
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
elConfigClusterType = 'overlapping';
elConfigInfo=flists.get_elconfiginfo_from_flist(flist);
%% look for unprocessed electrodes

warning(sprintf('Threshold set to %d.\n', thresholdVal));
if strcmp(sortInputOpt, 'elidx')
    [elNumbers ] = compare_els_between_dir_elconfiginfo(elConfigInfo,dirNameEl , ...
        '*.mat', flist);
    selElNumbers = elNumbers;
    pre_process_data(suffixName, flistName, 'config_type','exclusive',...
        'sel_by_els',selElNumbers, 'kmeans_reps',1,'threshold', thresholdVal);
elseif strcmp(sortInputOpt, 'patch_no')
    pre_process_data(suffixName, flistName, 'config_type','exclusive',...
        'sel_by_inds',patchIdx, 'kmeans_reps',1);
end
%% SUPERVISED SORTING (MANUAL) - create the cl_ files
% [elNumbers ] = compare_els_between_dir_elconfiginfo(elConfigInfo,dirNameEl , ...
%    '*.mat', flist);
fileType = 'mat';
elNumbers = compare_files_between_dirs(dirNameEl, dirNameCl, fileType, flist)
selInds = input(sprintf('sel inds of el numbers to sort [1:%d]> ',length(elNumbers)));
sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_els_in_dir', ...
    elNumbers(selInds))


end