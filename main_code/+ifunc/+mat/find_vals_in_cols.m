function rowInds = find_vals_in_cols(mat2Search, searchRow)
% rowInds = find_vals_in_cols(mat2Search, searchRow)
% mat2Search: matrix that will be searched
% searchRow: values that will be searched for down columns. Enter NaN
% values for columns that should be ignored

colsToSearch = find(~isnan(searchRow)); % the column numbers to search

indsFound = {};

for iCol=1:length(colsToSearch)

    indsFound{iCol} = find(mat2Search(:,colsToSearch(iCol))==searchRow(colsToSearch(iCol)))';

end

rowInds = indsFound{1};

for iGroups = 2:length(indsFound)
    rowInds = intersect(rowInds,indsFound{iGroups});

end



end