function neuronNames = get_neur_names_from_dir(dirPath, prefix, varargin)
% function neuronNames = get_neur_names_from_dir(dirPath, prefix, varargin)
%   arguments
%       inds:
%       remove_date;

inds = [];
removeDate = 0;
removePrefix = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'inds') % for override
            inds = varargin{i+1};
        elseif strcmp( varargin{i}, 'remove_date') % for override
                removeDate = 1;
        elseif strcmp( varargin{i}, 'remove_prefix') % for override
            removePrefix = 1;
        end
    end
end
    
fileNames = dir(fullfile(dirPath,strcat([prefix,'*.mat'])));


neuronNames = {};

if isempty(inds)
    for iInd = 1:length(fileNames)
        
        neuronNames{end+1} = strrep(strrep(fileNames(iInd).name,'.mat',''),prefix,'');    
        if removeDate
            neuronNames{end} = strrep(neuronNames{end},strcat(get_dir_date,'_'),'');
        end
        
    end
else
    for iInd = inds
        
        neuronNames{end+1} = strrep(strrep(fileNames(iInd).name,'.mat',''),prefix,'');    
        if removeDate
            neuronNames{end} = strrep(neuronNames{end},strcat(get_dir_date,'_'),'');
        end
    end
end


if removePrefix
   for i=1:length( neuronNames) 
      neuronNames{i} = strrep( neuronNames{i},prefix,'');
   end
end

end