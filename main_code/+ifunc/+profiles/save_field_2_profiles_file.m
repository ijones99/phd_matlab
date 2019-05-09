function save_field_2_profiles_file(neuronName, selField, selSubField, dataToAdd,suppressPrint, varargin)
% Saves the neuron (first argument) to the existing file
% function save_to_results_file(neuronName, cellNum, data, doClear)

% init vars
P.use_sep_dir=[]; 

% check for arguments
P = mysort.util.parseInputs(P, varargin, 'error');

% directories
dirNameAnalysedData = '../analysed_data/';
if isempty(P.use_sep_dir)
    dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/');
else
    dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/', P.use_sep_dir);
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