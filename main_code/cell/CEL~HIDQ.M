function outputIdx = cellFind(cellName, searchStr, varargin )


outputIdx = [];
i = 1;
while isempty(outputIdx)
    
    if cellName{i} == searchStr
        outputIdx = i;
    end
    i=i+1;
    
    
    
end


end