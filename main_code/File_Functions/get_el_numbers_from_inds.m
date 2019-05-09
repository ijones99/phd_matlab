function [elNumber] = get_el_numbers_from_inds(dirName, fileNamePattern,inds, varargin)

specificPartToRemove = [];

if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'part_to_remove')
            specificPartToRemove = varargin{i+1};
            
        end
    end
end

filesInDir = dir(fullfile(dirName,fileNamePattern));



% cycle through files in dir
elNumber = [];
for iFileNameList=1:length(inds)
    
    elNumber(iFileNameList) = get_el_nos_from_neur_names( ...
        filesInDir(inds(iFileNameList)).name);
    
end




end