function h = circle(x,y,r, varargin)

lineWidth = 1;
markerFaceColor = [];
markerEdgeColor = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'LineWidth')
            lineWidth = varargin{i+1};
        elseif strcmp( varargin{i}, 'MarkerFaceColor')
            markerFaceColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'MarkerEdgeColor')
            markerEdgeColor = varargin{i+1};
        end
    end
end

% h = CIRCLE(x,y,r)
hold on

th = 0:pi/50:2*pi;

xunit = r * cos(th) + x;

yunit = r * sin(th) + y;

if ~isempty(markerFaceColor) & ~isempty(markerEdgeColor)
    h = plot(xunit, yunit,'LineWidth',lineWidth,...
        'MarkerFaceColor',markerFaceColor,'MarkerEdgeColor',markerEdgeColor);
elseif ~isempty(markerFaceColor) 
        h = plot(xunit, yunit,'LineWidth',lineWidth,...
        'MarkerFaceColor',markerFaceColor);
else
    
    h = plot(xunit, yunit,'LineWidth',lineWidth);
end

hold off

end