function outStruct = unique_in_cells_of_structure(inStruct, fieldNameSel, fieldNames)
% outStruct = UNIQUE_IN_CELLS_OF_STRUCTURE(inStruct, fieldNum)
%
% Finds unique values in fields of struct and returns struct with same
% fields and unique values. Unique values are the values from the field of
% choice.

if isempty(fieldNames)
    fieldNames = fields(inStruct);
end
for i=1:length(fieldNames)
    eval(sprintf('outStruct.%s=[];', fieldNames{i}));
end

eval(sprintf('numCells=length(inStruct.%s);',fieldNames{1} ));


for iField=1:length(fieldNames)
    for iCell=1:numCells
        eval(sprintf('outStruct.%s=[outStruct.%s inStruct.%s{%d}];', ...
            fieldNames{iField}, fieldNames{iField}, fieldNames{iField}, iCell));
    end
        
end

% find unique values
eval(sprintf('[C,ia,ic] = unique(outStruct.%s);', fieldNameSel));

for iField=1:length(fieldNames)
     eval(sprintf('outStruct.%s=outStruct.%s(ia);', fieldNames{iField},fieldNames{iField}))
end