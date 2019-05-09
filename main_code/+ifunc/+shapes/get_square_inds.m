function [inds rows cols] = get_square_inds(coordX, coordY, squareEdgeSize, areaEdgeSize)


halfSquareEdgeDim = floor(squareEdgeSize/2);

% odd square
if rem(squareEdgeSize,2)
    rows= coordX-halfSquareEdgeDim:coordX+halfSquareEdgeDim;
    cols = coordY-halfSquareEdgeDim:coordY+halfSquareEdgeDim;
    
    
else
    
    rows= coordX-halfSquareEdgeDim:coordX+halfSquareEdgeDim-1;
    cols = coordY-halfSquareEdgeDim:coordY+halfSquareEdgeDim-1;
        
end


rows(find(rows>areaEdgeSize)) = [];rows(find(rows<1)) = [];
cols(find(cols>areaEdgeSize)) = [];cols(find(cols<1)) = [];

allRows = sort(repmat(rows,1,length(cols)));
allCols = repmat(cols,1,length(rows));


inds = sub2ind([areaEdgeSize areaEdgeSize], allRows,allCols);

end