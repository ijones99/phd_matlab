function neur = load_profiles_file(neuronName, varargin)
% loads the neuron 

% init vars
P.stim_name=[]; 
P.use_sep_dir=[];
P.use_date_in_name=0;

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
if isempty(strfind(neuronName, dirDate)) && P.use_date_in_name
    fileName = strcat(dirDate, '_', neuronName);
else
    fileName = neuronName;
end
% load data
if ~sum(strfind(fileName,'.mat'))
    fileName = sprintf('%s.mat', fileName);
end

if exist(fullfile(dirNameProfiles,strcat(fileName)),'file')
    load(fullfile(dirNameProfiles,strcat(fileName)));
else
    fprintf('File %s does not exist in %s\n', neuronName, dirNameProfiles);
    neur = [];
end



end