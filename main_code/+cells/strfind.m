function idx = strfind(myCell, strVal)
% idx = STRFIND(myCell, strVal)

idxStr = strfind(myCell,strVal);
idx = find(cellfun(@(x) any(x(:)>=1),idxStr))';




end
