function adjustedMat = array2beamer_mat_adjustment(inputMat)
% adjustedMat = array2beamer_mat_adjustment(inputMat)
%
% rotate 90 degrees counterclockwise and flipud


adjustedMat = inputMat(end:-1:1,:,:);
adjustedMat = permute(adjustedMat,[2 1 3]);
adjustedMat = adjustedMat(:,end:-1:1,:);


end