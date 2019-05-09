function [fittedData voltThresh xOut yOut] = fit_sigmoidal_curve_to_percent_response(x,y)
% function [fittedData voltThresh xOut yOut] = FIT_SIGMOIDAL_CURVE_TO_PERCENT_RESPONSE(x,y)
%
% Author: Mr. Jones

if y>1 | y<0
    error('!!!Mister Jones says: y must be between 0 and 1');
end

if ~isint(x)
    error('!!!Mister Jones says: x must have integer values');
end


% must be columns
if isrow(x)
    x = x';
end
if isrow(y)
    y = y';
end

% for the case that there is no response
% if isempty(endOfReg)
%     endOfReg = length(y);
% end

[logitCoef,dev] = glmfit(x,y,'binomial','logit');
yFit = glmval(logitCoef,x,'logit');


diffFromPt = abs(yFit{2}-0.5);
[Y idxClosest ] = min(diffFromPt);

% coeff = coeffvalues(fittedData);
xOut  = [];yOut =[];
if Y < 0.1
    voltThresh = xFit{2}(idxClosest);
    xOut = xFit{2};
    yOut = yFit{2};
else
    warning('curve does not reach 50%');
    voltThresh = nan;
end



% voltThresh = coeff(2);

if voltThresh > max(x) | voltThresh < min(x)
    warning('no proper fit achieved')
    voltThresh = nan;
end


end
