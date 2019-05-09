function data = load_profiles_file(neuronName, dirName, varargin)
% loads the neuron 
P.none = [];
P = mysort.util.parseInputs(P, varargin, 'error');

% directories
dirNameAnalysedData = '../analysed_data/';
if isempty(dirName)
    dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/');
else % load data from separate directory one branch down from profiles dir
     dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/',dirName);
end

fileName = '';
% get filename
fileName = strcat(get_dir_date, '_', neuronName);

% load data

if exist(fullfile(dirNameProfiles,strcat(fileName,'.mat')),'file')
    load(fullfile(dirNameProfiles,fileName));
else
    fprintf('File %s does not exist in %s\n', neuronName, dirNameProfiles);
end



end