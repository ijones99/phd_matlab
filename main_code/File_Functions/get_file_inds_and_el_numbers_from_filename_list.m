function [fileInds elNumbers] = ...
    get_file_inds_and_el_numbers_from_filename_list(dirName, fileNameList, fileNamePattern)

numberItems = length(fileNameList);
fileInds = zeros(1, numberItems);
elNumbers = zeros(1, numberItems);

filesInDir = dir(fullfile(dirName,fileNamePattern));

elNumberPattern = {'\d+'};
% cycle through the list
for iFileNameList=1:numberItems
    % cycle through the files in the directory
    for iFileInDir = 1:length(filesInDir)
        % compare list to files in Dir
        if strfind(filesInDir(iFileInDir).name, fileNameList{iFileNameList})
            fileInds(iFileNameList) = iFileInDir;
            elNumberPositionInFileName = uint8(cell2mat(regexp(filesInDir(iFileInDir).name, elNumberPattern,'once')));
            elNumbers(iFileNameList) = str2num(filesInDir(iFileInDir).name(elNumberPositionInFileName:elNumberPositionInFileName+3));
        end
    end
end

end