function medianVal = nanmedian2d( inputMatrix)
% function medianVal = nanmedian2d( inputMatrix)
    
medianVal = nanmedian(reshape(inputMatrix,[1 size(inputMatrix,1)*size(inputMatrix,2)]));

end