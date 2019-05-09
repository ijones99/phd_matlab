function fileInds = get_file_inds_from_el_numbers(dirName, pattern, elNumbers)

fileNames = dir(fullfile(dirName,pattern));

fileInds = [];

if isnumeric(elNumbers)
    for iElNum=1:length(elNumbers)
        
        for iFile = 1:length(fileNames)
            if strfind(fileNames(iFile).name, num2str(elNumbers(iElNum)))
               fileNames(iFile).name
                fileInds(end+1) = iFile;
            end
            
        end
        
    end
    
elseif iscell(elNumbers)
    for iElNum=1:length(elNumbers)
        for iFile = 1:length(fileNames)
            if strfind( fileNames(iFile).name(1:end-4), elNumbers{iElNum})
                fileNames(iFile).name(1:end-4)
                fileInds(end+1) = iFile;
            end
            
        end
        
    end
    
else
    fprintf('Error: wrong electrode number input type.\n');
    
  
    
end



fileInds = unique(fileInds);  



end