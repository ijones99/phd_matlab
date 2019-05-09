function [cubicFit xValsHiRes cubicCoef,stats,ctr] = fit_curve(xVals, yVals, varargin)

degreeNum = 3;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'degree')
            degreeNum = varargin{i+1};
        end
    end
end



yValsNorm = normalize_values(yVals,[0 1]);
xValsHiRes = min(xVals):10:max(xVals);

% plot(xVals,yValsNorm,'s')
% xlabel('Weight'); ylabel('Proportion');
%
% [logitCoef,dev] = glmfit(xVals',proportion','binomial','logit');
% logitFit = glmval(logitCoef,xValsHiRes ,'logit');

[cubicCoef,stats,ctr] = polyfit(xVals,yValsNorm,degreeNum);
cubicFit = polyval(cubicCoef,xValsHiRes,[],ctr);

end

