function outputIdx = cell_find_str_in_field(cellName, fieldName, searchStr, varargin )
% outputIdx = CELL_FIND_STR_IN_FIELD(cellName, fieldName, searchStr, varargin )


outputIdx = [];
i = 1;
while isempty(outputIdx)
    
    fieldContents = getfield(cellName{i},fieldName);
    
    
    
    if strcmp(fieldContents,searchStr)
        outputIdx = i;
    end
    i=i+1;
    if i > length(cellName) | ~isempty(outputIdx)
        break
        
    end
    
    
end


end