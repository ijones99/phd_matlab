function remove_number_prefixes_to_filenames(specDirName, neurNames )
% function remove_number_prefixes_to_filenames(specDirName, neurNames )
% PURPOSE: To remove a prefix number to a file

if isstr(neurNames)
    neurNamesTemp = neurNames;clear neurNames;
    neurNames{1} = neurNamesTemp;
end

for i = 1:length(neurNames)
    % get file name
    fileNameInDirOrig = dir(fullfile(specDirName, strcat('*',neurNames{i},'.*')));
    try
        % make new file name
        fileNameInDirNew = fileNameInDirOrig(1).name(5:end);
        
        eval(['!mv ',fullfile(specDirName,fileNameInDirOrig.name), ' ',fullfile(specDirName,fileNameInDirNew)])
    catch
        fprintf('Error with %s\n',  neurNames{i});
    end
end




end