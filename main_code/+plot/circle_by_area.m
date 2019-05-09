function h = circle_by_area(x,y,A,varargin)
lineWidth = 1;
faceColor = 'none';
edgeColor = 'none';
plotColor = 'k';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'LineWidth')
            lineWidth = varargin{i+1};
        elseif strcmp( varargin{i}, 'FaceColor')
            faceColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'EdgeColor')
            edgeColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'color')
            plotColor = varargin{i+1};
        end
    end
end

r = sqrt(A/pi());
d = r*2;

px = x-r;

py = y-r;

h = rectangle('Position',[px py d d],'Curvature',[1,1],'LineWidth',lineWidth,...
    'EdgeColor', plotColor,'FaceColor',faceColor);

daspect([1,1,1])

end