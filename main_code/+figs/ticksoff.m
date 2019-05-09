function ticksoff(varargin)

xOff = 0;
yOff = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'x')
            xOff = 1;
        elseif strcmp( varargin{i}, 'y')
            yOff = 1;
        end
    end
end

if xOff
    set(gca, 'XTick', []);
end


if yOff
    set(gca, 'YTick', []);
end






end