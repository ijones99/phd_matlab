function [neuronNames, dateNumInds] = get_file_names_from_dir(dirPath, searchStr, varargin)
% function neuronNames = get_neur_names_from_dir(dirPath, searchStr, varargin)
%   arguments
%       inds:
%       remove_date;

inds = [];
doGetSortDatenumInds = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'inds') % for override
            inds = varargin{i+1};
        elseif strcmp( varargin{i}, 'get_sort_by_datenum_inds') % for override
            doGetSortDatenumInds = 1;
        
        
        end
  
    end
end
    
fileNames = dir(fullfile(dirPath,strcat([searchStr])));


neuronNames = {};

if isempty(inds)
    for iInd = 1:length(fileNames)
        
        neuronNames{end+1} = strrep(strrep(fileNames(iInd).name,'.mat',''),searchStr,'');    

        
    end
else
    for iInd = inds
        
        neuronNames{end+1} = strrep(strrep(fileNames(iInd).name,'.mat',''),searchStr,'');    

    end
end

if doGetSortDatenumInds
    dateNumVals = [];
    for iFile = 1:length(fileNames)
        dateNumVals(iFile) = fileNames(iFile).datenum;
    end
    
    [Y, dateNumInds] = sort(dateNumVals,'ascend');
end

end