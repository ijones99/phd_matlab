function dirNames = get_dirnames(dirName, searchStr)
% dirNames = GET_DIRNAMES(dirName, searchStr)

if nargin <2
    searchStr= '';
end


% get all file names
fileNames = dir(fullfile(dirName, searchStr));
dirNames = {};

for i=1:length(fileNames)
    if fileNames(i).isdir && ~(strcmp(fileNames(i).name,'.') || strcmp(fileNames(i).name,'..')) 
        dirNames{end+1} = fileNames(i).name;
    end
    
    
end

dirNames = dirNames';
end