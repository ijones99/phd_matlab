function [matchingList outputMat] = look_for_duplicate_images(imagesStruct, fieldName, thresholdVal)
% [matchingList outputMat] = LOOK_FOR_DUPLICATE_IMAGES(imagesStruct, fieldName, thresholdVal)
%
% Purpose: Do cross correlations between images to look for duplicates.
%
% Arguments: 
%   imagesStruct format: imagesStruct{[1:n]}.fieldName
%   thresholdVal: decimal between 0 and 1. xcorr above this value will be
%   selected

numIms =length(imagesStruct);

% extract images
extractedIms = cell(1,numIms);
for i=1:numIms
    extractedIms{i} = getfield(imagesStruct{i},fieldName);
end

% autocorrelation
outputMat = zeros(numIms);

C = nchoosek(1:numIms,2);

for i=1:size(C,1)
    try
        outputMat(C(i,1),C(i,2))=corr2(extractedIms{C(i,1)},extractedIms{C(i,2)});
    end
end

 [rows,cols,vals] = find(outputMat>thresholdVal)

matIdx = sub2ind([numIms numIms], rows, cols);
corr2Vals = outputMat(matIdx);

matchingList = [rows cols corr2Vals];

end