function check_dir_for_files(directoryName, fileNames)
% function check_dir_for_files(directoryName, fileNames)
for i=1:length(fileNames)
    fileName = dir(fullfile(directoryName,strcat('*',fileNames{i},'*'))) ;
    if isempty(fileName)
        fprintf('%s missing.\n',  fileNames{i})
    else
        fprintf('%d ', i)
    end
    
    
end

end