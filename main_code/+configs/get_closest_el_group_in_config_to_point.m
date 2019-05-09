function [patchIdx elNos ] = get_closest_el_group_in_config_to_point( flist, varargin )
%  patchIdx = GET_CLOSEST_EL_GROUP_IN_CONFIG_TO_POINT( flist, varargin )
%
% varargin:
%   'input_xy': input [n1 n2] for xy location
%   'el_group_on_config_placement': e.g. 'exclusive'

elConfigInfo = flists.get_elconfiginfo_from_flist(flist);

% selectedPatches = select_patches_exclusive(numEls, elConfigInfo );
doInputXYCoord = [];
doInputMainElIdxCoord = [];
configType = 'exclusive';
numElsInElGp = 7;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'input_xy')
            doInputXYCoord = varargin{i+1};
        elseif strcmp( varargin{i}, 'input_main_elidx')
            doInputMainElIdxCoord = varargin{i+1};
        elseif strcmp( varargin{i}, 'el_group_on_config_placement')
            configType = varargin{i+1};
        
        end
        
    end
end

if strcmp(configType,'exclusive')
    selectedPatches = select_patches_exclusive(numElsInElGp, elConfigInfo );
end
    


configCtrX = []; configCtrY = [];
for i=1:length(selectedPatches)
    currConfXY = configs.el2pos( selectedPatches{i}.selElNos);
    configCtrX(i) = mean(currConfXY.x);
    configCtrY(i) = mean(currConfXY.y);
end
if ~isempty(doInputXYCoord)
    % get closest electrode to selected point
    [patchIdx, dist]=geometry.get_closest_point_to_matrix(configCtrX, configCtrY,...
        doInputXYCoord);
    elNos = selectedPatches{patchIdx}.selElNos;

elseif  ~isempty(doInputMainElIdxCoord)
    % get closest electrode to selected point
    inputXYCoord = configs.el2pos(doInputMainElIdxCoord);
    [patchIdx, dist]=geometry.get_closest_point_to_matrix(configCtrX, configCtrY,...
        inputXYCoord);
    elNos = selectedPatches{patchIdx}.selElNos
end





end