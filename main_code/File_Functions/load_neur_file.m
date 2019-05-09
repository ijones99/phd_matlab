function [outFile fileVarName] = load_neur_file(dirName, neuronName, varargin)
% init vars
prefix = [];
suffix  = [];
fileType = 'default';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'prefix')
            prefix= varargin{i+1};
        elseif strcmp( varargin{i}, 'suffix')
            suffix = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_type')
            fileType = varargin{i+1};
        end
    end
end



if strcmp(fileType,'default')
    dirAndFileString = fullfile(dirName, strcat(prefix,'*', strrep(neuronName,'n','*'),'*', suffix));
elseif strcmp(fileType,'cl_file')
    nLoc = strfind(neuronName,'n');
    neuronName = neuronName(1:nLoc-1);
    dirAndFileString = fullfile(dirName, strcat('cl_','*', neuronName,'*', suffix));
end
fileName = dir(dirAndFileString);

if length(fileName)>1
    fprintf('Error, more than one file found.\n\n');
    for i=1:length(fileName)
       fprintf('%s\n', fileName(i).name);
       
    end
    fprintf('\nTaking first file\n');
end

beforeWhosStruct = whos;

load(fullfile(dirName, fileName(1).name));

afterWhosStruct = whos;

% convert whos to cells
for i=1:length(beforeWhosStruct)
    beforeWhosCell{i} = beforeWhosStruct(i).name;
end
for i=1:length(afterWhosStruct)
    afterWhosCell{i} = afterWhosStruct(i).name;
end

settDiff = setdiff(afterWhosCell, beforeWhosCell);
fileVarName = '';
for i=1:length(settDiff )
    if ~strcmp(settDiff{i}, 'beforeWhosStruct')
        fileVarName = settDiff{i};
    end
end

eval(['outFile = ', fileVarName,';']);
end