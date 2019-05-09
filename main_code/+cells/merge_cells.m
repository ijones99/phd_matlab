function cellMerged = merge_cells(cell1, cell2, varargin)
% cellMerged = MERGE_CELLS(cell1, cell2, varargin)
doOrderFields = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'no_sort')
            doOrderFields = 0;
        end
    end
end

lenC1 = length(cell1);
lenC2 = length(cell2);
if lenC1 ~= lenC2
    error ('Cells must be same length.');
end

for i=1:lenC1
    % get field names for #2
    fieldNames = fields(cell2{i});
    % add all field names from #2 to #1
    for iFld = 1:length(fieldNames)
        fieldVal = getfield(cell2{i},fieldNames{iFld} );
        cell1{i} = setfield( cell1{i}, fieldNames{iFld},fieldVal);
    end
    
end
cellMerged = {};
if doOrderFields
    for i=1:lenC1
        cellMerged{i}= orderfields(cell1{i});
    end
else
    cellMerged= cell1;
end

end