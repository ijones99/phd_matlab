function save_to_profiles_file(neuronName, selField, selSubField, dataToAdd, varargin)
% Saves the neuron (first argument) to the existing file
% function save_to_results_file(neuronName, cellNum, data, doClear)
%
% Purpose: save data to profile structure. Default save to ../analysed_data/profiles/
%
%
% varargin  
%   'use_sep_dir'
%   'no_print'
%   'add_struct_fields'  
%   'dir'

% init vars
stimName=[]; 
suppressPrint = [];
addStruct = [];
% directories
dirNameAnalysedData = '../analysed_data/';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'use_sep_dir') % this is the option to use a directory...
            ...one level down from the profiles directory to separate by stimulus.
            stimName = selField;
        elseif strcmp( varargin{i}, 'no_print')
            suppressPrint = 0;
        elseif strcmp( varargin{i}, 'add_struct_fields')
            addStruct = varargin{i+1};
        elseif strcmp( varargin{i}, 'dir')
            dirNameAnalysedData= varargin{i+1};
        end
    end
end


if isempty(stimName)
    dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/');
else
    dirNameProfiles = fullfile(dirNameAnalysedData,'profiles/', stimName);
    if ~exist(dirNameProfiles, 'dir')
        mkdir( dirNameProfiles);
    end
end

% get filename
fileName = [neuronName,'.mat'];

if ~strfind(fileName,get_dir_date)
    fileName = strcat(get_dir_date, '_', fileName);
end

if ~strfind(fileName,'.mat')
    fileName = [fileName,'.mat'];
end

% load data
if exist(fullfile(dirNameProfiles,strcat(fileName)),'file')
    neur = profiles.load_profiles_file(fileName);
end


if isempty(addStruct)
    eval(['neur.',selField,'.',selSubField,'=dataToAdd;'])
else
    fieldNamesStruct = fields(addStruct);
    for i=1:length(fieldNamesStruct)
       eval(sprintf('neur.%s.%s=addStruct.%s;',selField, ...
           fieldNamesStruct{i}, fieldNamesStruct{i})) 
    end
end

% save data
if ~exist(dirNameProfiles)
    mkdir(dirNameProfiles);
end

save(fullfile(dirNameProfiles,fileName), 'neur');
if ~suppressPrint
    fprintf('processed and saved %s to %s%s\n',neuronName,dirNameProfiles,fileName);
end
end