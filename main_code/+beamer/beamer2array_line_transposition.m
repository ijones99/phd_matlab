function adjustedXY = beamer2array_line_transposition(line1
%
%
% rotate 90 degrees counterclockwise and flipud
%
% line1 = [x1 y1]
%         [x2 y2]


adjustedMat = inputMat(end:-1:1,:);
adjustedMat = permute(adjustedMat,[2 1]);
adjustedMat = adjustedMat(:,end:-1:1);


end