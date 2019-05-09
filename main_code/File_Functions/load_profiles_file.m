function data = load_profiles_file(neuronName, varargin)
% loads the neuron 

% init vars
P.stim_name=[]; 
P.use_sep_dir=[]; 

% check for arguments
P = mysort.util.parseInputs(P, varargin, 'error');

% directories
dirNameAnalysedData = '../analysed_data/';
if isempty(P.use_sep_dir)
    dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/');
else % load data from separate directory one branch down from profiles dir
    dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/',P.use_sep_dir);
end

fileName = '';
% get filename
dirDate = get_dir_date;
if ~strfind(neuronName, dirDate)
    fileName = strcat(dirDate, '_', neuronName);
else
    fileName = neuronName;
end
% load data

if exist(fullfile(dirNameProfiles,strcat(fileName,'.mat')),'file')
    load(fullfile(dirNameProfiles,strcat(fileName,'.mat')));
else
    fprintf('File %s does not exist in %s\n', neuronName, dirNameProfiles);
end



end