function adjustedXY = beamer2array_xy_adjustment(inputXY)
% adjustedMat = array2beamer_mat_adjustment(inputMat)
% NOTE: inputXY is relative to the center of the config!
%
% rotate 90 degrees counterclockwise and flipud


adjustedMat = inputMat(end:-1:1,:);
adjustedMat = permute(adjustedMat,[2 1]);
adjustedMat = adjustedMat(:,end:-1:1);


end