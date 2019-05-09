function stemh(x,y, varargin)

if nargin < 2
    y = 1:length(x);
end

plot(x',y')
plot(x,y,'ok')

end