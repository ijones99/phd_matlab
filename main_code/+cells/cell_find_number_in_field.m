function outputIdx = cell_find_number_in_field(cellName, fieldName, searchVal, varargin )
% outputIdx = CELL_FIND_NUMBER_IN_FIELD(cellName, fieldName, searchVal, varargin )


outputIdx = [];
i = 1;
while isempty(outputIdx)
    
    fieldContents = getfield(cellName{i},fieldName);
    
    
    
    if find(fieldContents==searchVal)
        outputIdx = i;
    end
    i=i+1;
    if i > length(cellName) | ~isempty(outputIdx)
        break
        
    end
    
    
end


end