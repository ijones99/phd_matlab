function [fileList dirsFound numFilesFound] = build_filelist_from_ground_up(dirName, fileStr) 
% [fileList dirsFound numFilesFound]  = BUILD_FILELIST_FROM_GROUND_UP(dirName, fileStr) 

if nargin < 2
    fileStr = '';
end
if ~strcmp(dirName(end),'/') % make sure a slash is at the end
    dirName(end+1)='/';
end

% Check for existing file and load if necessary.
fileListName = 'file_list.mat';
% if exist(fullfile(dirName, fileListName), 'file') 
%     load(fullfile(dirName, fileListName));
% else
fileList = {};
% save location
% fileList{end+1,1} = fullfile(dirName, fileListName);
% end

% get dir names
dirNames = filenames.get_dirnames(dirName);

dirsFound = dirNames;
numFilesFound = [];

% go through each dir and create a file list
for iDir = 1:length(dirNames)
    % get filelist
    fileNames ={};
    fileNames = filenames.get_filenames('*.mat', fullfile(dirName,dirNames{iDir}));
    numFilesFound(iDir) = length(fileNames);
    % append names
    for i=1:length(fileNames)
        % check for repeats

            fileList{end+1,1} = dirNames{iDir};
            fileList{end,2} = fileNames(i).name;
            fileList{end,3} = [];

    end
    
end
numFilesFound = numFilesFound';


% save filelist
save(fullfile(dirName, fileListName), 'fileList');
fprintf('\nSaved fileList.mat to %s.\n', fullfile(dirName, fileListName));
end