function outputMat = normalize_values(inputMat, desiredRange)
% function outputMat = normalize_values(inputMat, desiredRange)

if nargin < 2
    desiredRange = [ 0 1];
end

% inital range
rangeInit = max(max(max(inputMat))) - min(min(min(inputMat))) ;

% norm to [0 1]
if rangeInit~=0
    inputMat = (inputMat - min(min(min(inputMat))))/rangeInit;
    % get range
    rangeSel = desiredRange(2) - desiredRange(1);
    
    % scale to range out
    outputMat = (inputMat*rangeSel) + desiredRange(1);
    
    
else
    warning('all values are equal.\n')
    outputMat  = inputMat*0;
end



end