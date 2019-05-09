function [idx strLocAtIdx]= find_str_in_flist_cell(strIn, flist)
% [idx strLocAtIdx]= FIND_STR_IN_FLIST_CELL(strIn, flist)
%
% Purpose: find string in filenames cell list.
%

idx = [];
strLocAtIdx = [];

for i=1:length(flist)
    strLocInCell = strfind(flist{i}, strIn);
    if ~isempty(strLocInCell)
        idx(end+1) = i;
        strLocAtIdx(end+1) = strLocInCell(1);
        if length(strLocInCell) >1
            warning('Considering only first location.\n');
        end
    end


end