function outputIdx = cellfind(cellName, searchStr )
% outputIdx = cellfind(cellName, searchStr )

outputIdx = [];
i = 1;
while isempty(outputIdx) && i <= length(cellName)
    
    if cellName{i} == searchStr
        outputIdx = i;
    end
    i=i+1;
    
    
    
end


end