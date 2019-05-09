function log_stimulus(data,chipGroup, varargin)
% function LOG_STIMULUS(data,chipGroup, varargin)
%
% varargin
%   dir_path: set a specific directory in which to save

dirNameSpecific = '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'dir_path')
            dirNameSpecific = varargin{i+1};
        end
    end
end

dirNameLog = 'log_files/';

% create dir if it doesn't exist
if ~exist(dirNameLog,'dir')
    mkdir(dirNameLog)
end

dirNameFull = [dirNameLog, dirNameSpecific]; % full directory name
if dirNameFull(end) ~= '/'
    dirNameFull(end+1) = '/';
end

% create dir if it doesn't exist
if ~exist(dirNameFull,'dir')
    mkdir(dirNameFull)
end



% check existing files
logFileNames = dir(fullfile(dirNameFull,'*.mat'));

% get number of last log file
if ~isempty(logFileNames)
   lastFileNo = str2num(logFileNames(end).name(end-6:end-4));   
else
    lastFileNo = 0;
end

currLogFileName = sprintf('stimulus_log_%03d', lastFileNo+1);

% get recorded file name
recFileNames = dir(fullfile('../proc/*ntk'));
if isempty(recFileNames)
    fprintf('Error: no file recorded.\n');
    return
end
dateNums = 1:length(recFileNames);

% equivalent of ls -lrt
for i=1:length(dateNums)
   dateNums(i) =  recFileNames(i).datenum;
end

[B, fileNameIdx] = sort(dateNums,'descend');
currRecFileName = recFileNames(fileNameIdx).name;

data.flist = strcat('../proc/', currRecFileName);

dataFields = fields(data);
dataToSave = [];
for iField = 1:length(dataFields)
  eval(sprintf('dataToSave.%s=[];',dataFields{iField}));
end

for iField = 1:length(dataFields)
    % for cell, take appropriate one
    if iscell(getfield(data,dataFields{iField},{1}))
        currFieldContents = getfield(data,dataFields{iField},{chipGroup});
        currFieldContentsNew = currFieldContents{1};
        currFieldContents = currFieldContentsNew;
    else
        currFieldContents = getfield(data,dataFields{iField});
    end
    
   dataToSave= setfield(  dataToSave,      dataFields{iField},currFieldContents)
    
end

clear data;
data = dataToSave;


% save file
save(fullfile(dirNameFull,currLogFileName), 'data');

fprintf('File %s\n', currRecFileName);
fprintf('saved %s\n', currLogFileName);


end