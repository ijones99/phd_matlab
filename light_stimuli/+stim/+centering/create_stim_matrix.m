sqrDims = 800;
stimMatrix = zeros(round(sqrDims/1.75)); 
middleSqr = 150; 
rangeVals = [round((sqrDims/2-middleSqr/2)/1.75):round((sqrDims/2+middleSqr/2)/1.75)];

%create cross
stimMatrix(rangeVals,:)=255;
stimMatrix(:,rangeVals)=255;

%create hairline
stimMatrix(round(sqrDims/2/1.75)-1:round(sqrDims/2/1.75)+1,:)=0;
stimMatrix(:,round(sqrDims/2/1.75)-1:round(sqrDims/2/1.75)+1)=0;