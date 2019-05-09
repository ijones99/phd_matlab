function add_group_sorting_els_to_profiles( neurNames, dirGroups, varargin )
% init vars
groupType = 'felix';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'groupType')
            groupType = varargin{i+1};
        end
    end
end


if strcmp(groupType,'felix')
    % load groups info
    fileNameGps = dir(fullfile(dirGroups, '*_el_groups.mat'));
    load(fullfile(dirGroups, fileNameGps(1).name));
    
    % "groupsidx" is variable for groups
    
    for i=1:length(neurNames)
        
        % group number
        gpNumber = str2num(neurNames{i}(1:4));
        % save to neuron profile
        save_to_profiles_file(neurNames{i}, 'White_Noise', 'inds_for_sorting_els', groupsidx{gpNumber},1);
        
        i
        
    end
    
    
elseif strcmp(groupType,'from_st_file')
    for i=1:length(neurNames)
        try
        [outFile fileVarName] = load_neur_file(dirGroups, neurNames{i}, 'prefix','st_*')
        
        save_to_profiles_file(neurNames{i}, 'White_Noise', 'inds_for_sorting_els', outFile.elidx,1);
        
        i
        catch
           fprintf('Error with %d\n', i) 
        end
        
    end
    
end
end