function save_to_profiles_file(neuronName, selField, selSubField, dataToAdd, varargin)
% Saves the neuron (first argument) to the existing file
% function save_to_results_file(neuronName, cellNum, data, doClear)

% init vars
stimName=[]; 
suppressPrint = [];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'use_sep_dir') % this is the option to use a directory...
            ...one level down from the profiles directory to separate by stimulus.
            stimName = selField;
        elseif strcmp( varargin{i}, 'no_print')
            suppressPrint = 0;
        end
    end
end

% directories
dirNameAnalysedData = '../analysed_data/';
if isempty(stimName)
    dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/');
else
    dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/', stimName);
    if ~exist(dirNameProfiles, 'dir')
        mkdir( dirNameProfiles);
    end
end

% get filename
fileName = strcat(get_dir_date, '_', neuronName);

% load data
if exist(fullfile(dirNameProfiles,strcat(fileName,'.mat')),'file')
    load(fullfile(dirNameProfiles,fileName));
end

eval(['data.',selField,'.',selSubField,'=dataToAdd;'])

% save data
if ~exist(dirNameProfiles)
    mkdir(dirNameProfiles);
end

save(fullfile(dirNameProfiles,fileName), 'data');
if ~suppressPrint
    fprintf('processed and saved %s to %s%s\n',neuronName,dirNameProfiles,fileName);
end
end