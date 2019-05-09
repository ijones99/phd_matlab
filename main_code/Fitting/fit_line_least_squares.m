function [a b yEst] = fit_line_least_squares(x,y,doPlot)
% [a b yEst] = fit_line_least_squares(x,y,doPlot)
% output: y = a*x + b;
% 
% source: http://www.dsplog.com/2007/07/15/straight-line-fit-using-least-squares-estimate/
% author: ijones

if nargin < 3
    doPlot = 0;
end

Y = y.';
X = [x.' ones(1,length(x)).'];
alpha = inv(X'*X)*X'*Y; % solving for m and c 

% estimated y values according to formula
yEst = alpha(1)*x + alpha(2); 

% output constants;
a = alpha(1);
b = alpha(2);

if doPlot
    plot(x,y,'.');
    hold on
    plot(x,yEst,'r');
end

end