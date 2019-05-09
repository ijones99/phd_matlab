function idxOut = select_els_near_line( xPosAll, yPosAll, varargin )
% idxOut = SELECT_ELS_NEAR_LINE( xPosAll, yPosAll, varargin )
%   
%  
%    Author ijones bsse

% number of points to click
numPtsInPolygon = 5;
dThresh = 17.5*2;
% init vars
figH = [];
axesH = [];
plotStyle = 'ro';
doPlot = 0;
myText = '';
selColor = 'c';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        switch varargin{i},
            case 'axes_h'
                axesH = varargin{i+1};
            case 'fig_h'
                figH = varargin{i+1};
            case 'num_pts'
                numPtsInPolygon = varargin{i+1};
            case 'plot'
                doPlot = 1;
            case 'color'
                selColor = varargin{i+1};
            case 'text'
                myText =  varargin{i+1};
            case 'd_thresh'
                dThresh =  varargin{i+1};
        end
    end
end

% get top figure
figure(gcf);
plot(xPosAll,yPosAll,'k.')
hold on

% x and y are coordinates selected by the pointer
indNearest = zeros(numPtsInPolygon,1);
x = zeros(numPtsInPolygon,1);
y = zeros(numPtsInPolygon,1);
% select points of line
hold on
axis equal
shg
if not(isempty(myText))
    fprintf([myText ,'\n']);
end
junk = input('press enter');
for i=1:numPtsInPolygon
    % sel point
        [x(i), y(i)] = ginput(1);
        % find euclidian distance
        plot(x(i), y(i),'ro','LineWidth',2);
        text(x(i)+2, y(i), num2str(i))
end
shg
% create lines between points
xLinePts = []; yLinePts = [];

for i=1:numPtsInPolygon-1
    [xSteps ySteps] = geometry.create_line(x(i), y(i),x(i+1), y(i+1),10);
    xLinePts(end+1:end+length(xSteps)) = xSteps;
    yLinePts(end+1:end+length(ySteps)) = ySteps;
end
    
% get distances
d = nan( length(xPosAll), length(xLinePts));
for i=1:length(xLinePts)
    eucDist = pdist2([mats.set_orientation(xPosAll,'col') ...
    mats.set_orientation(yPosAll,'col')], [xLinePts(i) yLinePts(i)]);
    d(:,i) = eucDist;
end

[idxOut,cols,vals] = find(d<dThresh);

plot(xPosAll(idxOut), yPosAll(idxOut), 'o','Color', selColor, 'LineWidth',2);


end


