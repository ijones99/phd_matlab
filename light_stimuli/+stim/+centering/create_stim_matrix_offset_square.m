sqrDims = 900;
middleSqrDims = 150;
centerXY = [150 -150];

stimMatrix = zeros(round(sqrDims/1.75));
centerIdxXY = centerXY+[sqrDims/2 sqrDims/2];


rangeVals = [round((centerIdxXY(2)-middleSqrDims/2)/1.75):...
    round((centerIdxXY(1)+middleSqrDims/2)/1.75)];

%create cross
stimMatrix(rangeVals,:)=255;
stimMatrix(:,rangeVals)=255;

%create hairline
% stimMatrix(round(sqrDims/2/1.75)-1:round(sqrDims/2/1.75)+1,:)=0;
% stimMatrix(:,round(sqrDims/2/1.75)-1:round(sqrDims/2/1.75)+1)=0;