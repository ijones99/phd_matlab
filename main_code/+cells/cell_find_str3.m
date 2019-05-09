function idx = cell_find_str3(myCell, strVal)
% idx = CELL_FIND_STR3(myCell, strVal)

idxStr = strfind(myCell,strVal);
idx = find(cellfun(@(x) any(x(:)==1),idxStr))';




end
