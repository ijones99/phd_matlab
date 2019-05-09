function load_mat_files_to_workspace(searchStr, varargin)
%LOAD_MAT_FILES    load mat files into work space, calling all with a 
% search string.
% 
% LOAD_MAT_FILES(searchStr), where searchStr is a string that is present in
% all files to be loaded.
% 
% Arguments
%   'add_asterisk'
%   'file_type': e.g. '.mat'
% 
% author ijones

% check for arguments

dirName = '';


if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'add_asterisk')
            searchStr = ['*',searchStr,'*'];
        end
    end
end

if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'file_type')
            if strcmp(searchStr(end),'*')
                searchStr = [searchStr,varargin{i+1}];
            else
                searchStr = [searchStr,'*',varargin{i+1}];
            end
        elseif strcmp( varargin{i}, 'dir_name')
        end
    end
end

if searchStr(end) == '*'
    searchStr = strcat(searchStr,'.mat');
else
    searchStr = strcat(searchStr,'*.mat');
end

fprintf('Search string = %s\n', searchStr);
fileNames = dir(fullfile(dirName,searchStr));
fprintf('Number files found: %d\n', length(fileNames));
for m=1:length(fileNames)
    fprintf('%s\n', fileNames(m).name);
end

% load files
for i=1:length(fileNames)
    
    load(fullfile(dirName,fileNames(i).name));
    progress_info(i, length(fileNames))
end

%
save_to_base(1);

end