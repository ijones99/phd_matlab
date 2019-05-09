function [idxSel varIdx] = get_param_indices(stimFrameInfo, varargin)

sortField = 'angle';

fieldNames = fields(stimFrameInfo);

for i=1:length(fieldNames)
    fieldValsUniqueVals{i} = unique(getfield(stimFrameInfo, fieldNames{i}));
end

for i=1:length(fieldNames)
    fieldVals{i} = getfield(stimFrameInfo, fieldNames{i});
end

% check for arguments
if ~isempty(varargin)
    % for fields
    for i=1:length(varargin)
        for iFld = 1:length(fieldNames)
            if strcmp( varargin{i}, fieldNames{iFld})
                fieldValsUniqueVals{iFld} = varargin{i+1};
            end
            
        end
    end
end


% indices of specific combination of settings
varIdx = find(ismember(fieldVals{1}, fieldValsUniqueVals{1}));
if isempty(find(ismember(fieldVals{1}, fieldValsUniqueVals{1})))
    error(sprintf('no matching values for %s', fieldNames{1}));
end
for i=2:length(fieldNames)
    if isempty(find(ismember(fieldVals{i}, fieldValsUniqueVals{i})))
       error(sprintf('no matching values for %s', fieldNames{i}));
    end
    varIdx = intersect(varIdx, ...
        find(ismember(fieldVals{i}, fieldValsUniqueVals{i})));
end

% sort according to selection
sortFieldIdx = find(ismember(fieldNames, sortField));
[Y , idxSel ] = sort(fieldVals{sortFieldIdx}(varIdx));

end





