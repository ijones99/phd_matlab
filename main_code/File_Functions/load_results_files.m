 function resultsData = load_results_files(fileName, varargin)
% function resultsData = load_results_files(fileName, varargin)
% arguments: 
%   'dir_name' for directory name override; otherwise,
%   ../analysed_data/Results dir will be used.

% constants
dirNameAnalysedData = '../analysed_data/';
dirNameResults = fullfile(dirNameAnalysedData,'Neuron_Profiles/');
addDate = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'dir_name') % for override
            dirNameResults = varargin{i+1};

        end
    end
end

% get the neuron name
neuronName = fileName;
if ~isempty(strfind(neuronName,'.mat')) % if there is a suffix, remove it
    neuronName = strrep(fileName,'.mat','');
end

if ~isempty(strfind(neuronName,'_')) % if there is a suffix, remove it
    underscoreLoc = strfind( neuronName,'_' );
    neuronName = neuronName(underscoreLoc +1:end);
end


if isempty(strfind(fileName,'.mat'))
    fileName = strcat(fileName,'.mat');
end



% load data
% fileName = strcat(get_dir_date,'_',fileName);
if exist(fullfile(dirNameResults,strcat(get_dir_date,'_',fileName)),'file')
    load(fullfile(dirNameResults,strcat(get_dir_date,'_',fileName)));
    eval(['resultsData = re_', neuronName,';']);
else
    fprintf('Error with %s\n', fileName);
end

end