function outputIdx = cell_find_str(cellName, searchStr, varargin )


outputIdx = [];
i = 1;
while isempty(outputIdx)
    
    if strcmp(cellName{i},searchStr)
        outputIdx = i;
    end
    i=i+1;
    if i > length(cellName)
        break
        outputIdx = [];
    end
    
    
end


end