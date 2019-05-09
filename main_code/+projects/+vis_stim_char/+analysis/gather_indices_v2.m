function  paramCat = gather_indices_v2(absDirNames, localDirName, fileName, fieldNameToCat ) 
%   paramCat = GATHER_INDICES_V2(absDirNames, localDirName, fileName, fieldNameToCat) 
% 
%  args
%       dirNames = projects.vis_stim_char.analysis.load_dir_names;
%       localDirName = 'analysed_data/marching_sqr_over_grid/'
%       fileName = 'dataOut.mat' 
%       fieldNameToCat = { 'latency_ON'  'latency_OFF'}
%           E.g. in '../analysed_data/marching_sqr_over_grid/', there is
%               'param_BiasIndex,' which has fields:
%               'clus_num'
%               'date'
%               'index'



paramCat= {};
if not(iscell(fieldNameToCat))
   fieldNameToCat = {fieldNameToCat };
end

for iDir = 1:length(absDirNames) % loop through directories
    
    clearvars -except iDir absDirNames fileName paramCat localDirName fieldNameToCat idxCat
    
    % load struct
    paramData = file.load_single_var(fullfile(absDirNames{iDir}, localDirName),...
        fileName);
    
    fieldNamesInStruct = fields(paramData);
    % field presence test
    if sum(find(ismember(fieldNameToCat,  fieldNamesInStruct)==0))
        if isempty(find(ismember(fieldNamesInStruct,fieldNameToCat))) 
            fprintf('At least one specified field does not exist.\nAvailable fields: \n')
            cells.print( fieldNamesInStruct)
            error('Field doesn''t exist.\n');
        end
    end
    
    
    for iFld = 1:length(fieldNameToCat) % loop thru fields
        paramCurr = mats.set_orientation( getfield(paramData,fieldNameToCat{iFld}), 'row');
        if strcmp(fieldNameToCat{iFld},'date')
           if not(iscell(paramCurr))
               paramCurr = {paramCurr };
           end
        end
        if strcmp(fieldNameToCat{iFld},'date') && length(paramCurr)==1
            paramCurr = repmat(paramCurr,1, length(paramData.clus_num));
        end
        
        if isempty( paramCat) | length(paramCat) < iFld
            paramCat{iFld} = [paramCurr];
        else
            paramCat{iFld} = [paramCat{iFld} paramCurr];
        end
       
        
    end
    progress_info(iDir, length(absDirNames));
  
end