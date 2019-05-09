function [idx strLocAtIdx]= find_str_in_filenames_cell(strIn, fileNames)
% [idx strLocAtIdx]= FIND_STR_IN_FILENAMES_CELL(strIn, fileNames)
%
% Purpose: find string in filenames cell list.
%

idx = [];
strLocAtIdx = [];

for i=1:length(fileNames)
    strLocInCell = strfind(fileNames(i).name, strIn);
    if ~isempty(strLocInCell)
        idx(end+1) = i;
        strLocAtIdx(end+1) = strLocInCell(1);
        if length(strLocInCell) >1
            warning('Considering only first location.\n');
        end
    end


end