function  paramCat = gather_indices_cells(absDirNames, localDirName, fileName, fieldName, idxParamSettings ) 
%   paramCat = GATHER_INDICES(absDirNames, localDirName, fileName, fieldName) 
% 
%   E.g. in '../analysed_data/marching_sqr_over_grid/', there is
%       'param_BiasIndex,' which has fields:
%           'clus_num'
%           'date'
%           'index'

if nargin < 6
    idxParamSettings =1;
    warning('idxParamSettings  set to 1')
end

if strcmp(fieldName,'date')
    paramCat = {};
else
    paramCat = [];
end

for iDir = 1:length(absDirNames) % loop through directories
    
    clearvars -except iDir absDirNames fileName paramCat localDirName fieldName
    
    % load struct
    paramData = file.load_single_var(fullfile(absDirNames{iDir}, localDirName),...
        fileName)
    
    % field presence test
    fieldNames = fields(paramData);
    if isempty(find(ismember(fieldNames,fieldName)))
       fprintf('Available fields: \n')
       fieldNames
       error('Field doesn''t exist.\n');
    end
    
    
    paramCurr = getfield(paramData,fieldName);
    
    if strcmp(fieldName,'date')
        if isempty(paramCat)
            paramCat =  repmat({paramCurr},1,length(paramData.clus_num));
        else
            paramCat = [paramCat repmat({paramCurr},1,length(paramData.clus_num))];
        end
    else
        if iscell(paramCurr)
           paramcat = [paramcat paramcurr{idxParamSettings }];
        else
            paramcat = [paramcat paramcurr];
        end
    end
end
  