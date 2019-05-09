function add_number_prefixes_to_filenames(specDirName, neurNames, prefixInds )
% function add_number_prefixes_to_filenames(specDirName, neurNames, prefixInds )
% PURPOSE: To add a prefix number to a file

if isstr(neurNames)
    neurNamesTemp = neurNames;clear neurNames;
    neurNames{1} = neurNamesTemp;
end

% consistency check
if length(neurNames) ~= length(prefixInds)
    
    fprintf('Error with length of neur names or prefix indices.\n')
    
    return
end


for i = 1:length(neurNames)
   % get file name
   fileNameInDirOrig = dir(fullfile(specDirName, strcat('*',neurNames{prefixInds(i)},'.*')));
  
   % prepare text number
   prefixNum = strcat('000', num2str(i)); prefixNum = prefixNum(end-2:end);
    
   % make new file name
   fileNameInDirNew = strcat(prefixNum,'_', fileNameInDirOrig.name);
   try
       eval(['!mv ',fullfile(specDirName,fileNameInDirOrig.name), ' ',fullfile(specDirName,fileNameInDirNew)])
   catch
       fprintf('Error with %s\n',  neurNames{prefixInds(i)});
   end
end




end