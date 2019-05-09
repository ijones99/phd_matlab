function out = separate_into_groups_of_indices(inputNumbers, numPerCell)
%  out = SEPARATE_INTO_GROUPS_OF_INDICES(inputNumbers, numPerCell)

out = {};
for i=1:floor(length(inputNumbers)/numPerCell)
    out{i} = inputNumbers((i-1)*numPerCell+1:(i)*numPerCell);
    
    
end
i=i+1;
lastVals = inputNumbers((i-1)*numPerCell+1:end);
if ~isempty(lastVals)
    
    out{i} = lastVals;
end
end