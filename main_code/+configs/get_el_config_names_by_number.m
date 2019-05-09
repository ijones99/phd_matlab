function fileNames = get_el_config_names_by_number(dirName, fileNumber)
% fileNames = GET_EL_CONFIG_NAMES_BY_NUMBER(dirName, fileNumber)
%
%
% get file names
fileList = dir(fullfile(dirName,'*fi2el.nrk2'));


fileNames = {};
for i=1:length(fileNumber)
    fileNames{i}=strrep(fileList(fileNumber(i)).name,'.fi2el.nrk2','');
    
end




end