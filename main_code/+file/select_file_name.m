function [fileIdx fileNames] = select_file_name(dirName, strArg, varargin)

%
% Purpose: select file by numbers in file name.
%
fileIdx = [];
selectionType = 'file_name_part';
promptStr = '';
promptStringOnly= 0;
sortByDate = 0;

flist = {};
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'selection_type')
            selectionType = varargin{i+1};
        elseif strcmp( varargin{i}, 'prompt_string')
            promptStr = varargin{i+1};
        elseif strcmp( varargin{i}, 'prompt_string_only')
            promptStr = varargin{i+1};
            promptStringOnly = 1;
        elseif strcmp( varargin{i}, 'dir')
            dirName = varargin{i+1};
        elseif strcmp( varargin{i}, 'flist')
            flist = varargin{i+1};
        elseif strcmp( varargin{i}, 'sort_by_date')
            sortByDate  = 1;
        end
    end
end

if length(dirName) > 0
    if dirName(end) ~= '/';
        dirName(end+1) = '/';
    end
end

fileNames = dir(fullfile(dirName, strArg));

if sortByDate
    fileNames = sortStruct(fileNames,'datenum',1);
end

% list all files
for i=1:length(fileNames)
    fprintf('(%d) %s\n', i, fileNames(i).name);
end

fprintf('\n');
% selection
if strcmp(selectionType ,'natural_order')
    ntkFileNumStr = input('Please enter in file number: ','s');
elseif strcmp(selectionType ,'file_name_part')
    exitLoop= 0;
    while exitLoop== 0
        searchStr = input('Enter selection string >> ','s');
        [currFileIdx strLocAtIdx] = filenames.find_str_in_filenames_cell(searchStr, fileNames);
        if length(currFileIdx) > 1
            warning('Please be more specific')
        else
            fileIdx = currFileIdx;
            exitLoop = 1;
        end
    end
end

fileIdx = currFileIdx ;

end