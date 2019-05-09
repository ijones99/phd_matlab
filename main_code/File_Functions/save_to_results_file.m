function save_to_results_file(neuronName, cellNum, data, doClear)
% Saves the neuron (first argument) to the existing file
% function save_to_results_file(neuronName, cellNum, data, doClear)

if nargin < 4
    doClear = 0;
end

% directories
dirNameAnalysedData = '../analysed_data/';
dirNameResults = fullfile(dirNameAnalysedData,'profiles/');

% get filenames
fileName = strcat(get_dir_date, '_', neuronName);

% load data
if and(~doClear, exist(fullfile(dirNameResults,strcat(fileName,'.mat')),'file'))
    load(fullfile(dirNameResults,fileName));
    eval(['tempCell = re_', neuronName,';']);
else
    tempCell = {};
end

tempCell{cellNum} = data;

eval(['re_', neuronName,'=tempCell;']);

% save data
if ~exist(dirNameResults)
    mkdir(dirNameResults);
end

save(fullfile(dirNameResults,fileName), strcat('re_',neuronName));
fprintf('processed and saved %s to %s%s\n',neuronName,dirNameResults,fileName);

end