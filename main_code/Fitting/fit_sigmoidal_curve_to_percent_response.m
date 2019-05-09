function [fittedData voltThresh xOut yOut] = fit_sigmoidal_curve_to_percent_response(x,y)
% function [fittedData voltThresh xOut yOut] = FIT_SIGMOIDAL_CURVE_TO_PERCENT_RESPONSE(x,y)
%
% Author: Mr. Jones

negOrder = 0;

if y>1 | y<0
    error('!!!Mister Jones says: y must be between 0 and 1');
end

if ~isint(x)
    error('!!!Mister Jones says: x must have integer values');
end

if sum(find(x<0)) > 0
    negOrder = 1;
    [x, I] = sort(-x);
    y = y(I);
end
    
% must be columns
if isrow(x)
    x = x';
end
if isrow(y)
    y = y';
end

% settings
s = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',[0 ],...
    'Upper',[1 ],...
    'Startpoint',[1 0.5]);
%     'Startpoint',[1 200]);

% formula for sigmoid
f = fittype('(A)/(1+exp(-(x-x_zero)/w))','problem','w','options',s);

% find beginning of crossover region
startOfReg = find(y<=min(y),1,'last')
endOfReg = find(y>0.8,1,'first')

% for the case that there is no response
if isempty(endOfReg)
    endOfReg = length(y);
end
regionWidth = diff(x([startOfReg endOfReg]))*1/4;

% fit

if y == 0
   y = zeros(length(x),1); 
end
[fittedData,gof2] = fit(x,y,f,'problem',regionWidth);

hFit = plot(fittedData,x, y);
    
xFit=get(hFit,'XData');
yFit=get(hFit,'YData');


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
