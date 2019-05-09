function fileInds = get_file_inds_from_neur_names(dirName, pattern, neurNames)

fileNames = dir(fullfile(dirName,pattern));

fileInds = [];

 
if iscell(neurNames)
    for iElNum=1:length(neurNames) % go through all neuron names
        for iFile = 1:length(fileNames)
            if strcmp( fileNames(iFile).name(4:end-4), neurNames{iElNum})
                fileNames(iFile).name(1:end-4)
                fileInds(end+1) = iFile;
            end
            
        end
        
    end
    
elseif ischar(neurNames)
      
        for iFile = 1:length(fileNames)
            if strcmp( fileNames(iFile).name(4:end-4), neurNames)
                fileNames(iFile).name(1:end-4)
                fileInds(end+1) = iFile;
            end
            
        end
        
    
else
    fprintf('Error: wrong electrode number name type or file does not exist.\n');
    
  
    
end



fileInds = unique(fileInds);  



end