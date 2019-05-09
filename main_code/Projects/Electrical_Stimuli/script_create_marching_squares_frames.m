% script_make_marching_square_frames(numRows, numCols, numRepeats)

numRows = 5;
numCols = 5;
numRepeats = 10;

frames = uint8(zeros(numRows, numCols, numRepeats*numRows*numCols*2));

squareVals = repmat([1 0],1, numRepeats);

iFrameCounter = 1;
for iRows=1:numRows
    for iCols=1:numRows
        for iNumRepeats = 1:numRepeats*2
            
            frames(iRows,iCols,iFrameCounter) = squareVals(iNumRepeats);
            iFrameCounter = iFrameCounter+1;
            
        end     
    end
end