function fileList = build_filelist(dirName, fileStr) 
% fileList = BUILD_FILELIST(dirName, fileStr) 

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
% end

% get dir names
dirNames = filenames.get_dirnames(dirName);

% go through each dir and create a file list
for iDir = 1:length(dirNames)
    % get filelist
    fileNames ={};
    fileNames = filenames.get_filenames('*.mat', fullfile(dirName,dirNames{iDir}));
    
    % append names
    for i=1:length(fileNames)
        % check for repeats
        currDirIdx = cells.cell_find_str2(fileList, dirNames{iDir});
        % only append new files
        if isempty(cells.cell_find_str2(fileList(currDirIdx,2),fileNames(i).name));
            fileList{end+1,1} = dirNames{iDir};
            fileList{end,2} = fileNames(i).name;
            fileList{end,3} = [];
        end
    end
    
end

% save filelist
save(fullfile(dirName, fileListName), 'fileList');
fprintf('\nSaved fileList.mat to %s.\n', fullfile(dirName, fileListName));
end