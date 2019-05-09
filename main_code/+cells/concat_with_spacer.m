function strOut = concat_with_spacer(cellsIn,mySpacer)
% strOut = CONCAT_WITH_SPACER(cellsIn,mySpacer)

cellsWithSpacers = cell(1, length(cellsIn)*2-1);
cellsWithSpacers(1:2:end) = cellsIn;
cellsWithSpacers(2:2:end-1) = {mySpacer};
strOut = cell2mat(cellsWithSpacers);
end