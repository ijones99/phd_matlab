function fileNames = get_filenames(searchStr, dirName)
% fileNames = GET_FILENAMES(searchStr, dirName)

if ~strcmp(dirName(end),'/') % make sure a slash is at the end
    dirName(end+1)='/';
end

doSortByDate = 1;

if nargin <2
    dirName= '';
end



fileNames = dir(fullfile(dirName, searchStr));

if doSortByDate
    [~,idx] = sort([fileNames.datenum]);
    fileNames = fileNames(idx);
end



end