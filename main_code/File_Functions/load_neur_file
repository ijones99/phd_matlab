function [outFile fileVarName] = load_neur_file(dirName, neuronName, varargin)
% init vars
prefix = [];
suffix  = [];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'prefix')
            prefix= varargin{i+1};
        elseif strcmp( varargin{i}, 'suffix')
            suffix = varargin{i+1};
        end
    end
end

dirAndFileString = fullfile(dirName, strcat(prefix,'*', strrep(neuronName,'n','*'),'*', suffix));

fileName = dir(dirAndFileString);

if length(fileName)>1
    fprintf('Error, more than one file found.\n');
end

beforeWhosStruct = whos;

load(dirName, fileName(1).name);

afterWhoseStruct = whos;

% convert whos to cells
for i=1:length(beforeWhosStruct)
    beforeWhosCell{i} = beforeWhosStruct(i).name;
end
for i=1:length(afterWhosStruct)
    afterWhosCell{i} = afterWhosStruct(i).name;
end

fileVarName = diffset(afterWhosCell, beforeWhosCell);

eval(['outFile = ', fileVarName,';']);
end