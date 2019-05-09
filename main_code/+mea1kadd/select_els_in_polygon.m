function [elIdSel elIdxSel] = ...
    select_els_in_polygon( elId, xEl, yEl, varargin )
%   [elIdSel elIdxSel] = SELECT_ELS_IN_POLYGON( elId, xEl, yEl, varargin )
%
%   Select a polygon and return the points within
%   the polygon. 
%   
%   
%   INPUT PARAMETERS:
%       ALL_ELS:    A struct returned by all_els=hidens_get_all_electrodes(versionNo)
%
%   OUTPUT PARAMETERS:
%       ELSNUMBERSINSIDE: electrodes found inside polygon
%       INDSLOCALINSIDE: indices to reference values in all_els struct 
%
%    Author ijones bsse



% number of points to click
numPtsInPolygon = 8;

% init vars
figH = [];
axesH = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'axes_h')
            axesH = varargin{i+1};
        elseif strcmp( varargin{i}, 'fig_h')
            figH = varargin{i+1};
        elseif strcmp( varargin{i}, 'num_points')
            numPtsInPolygon = varargin{i+1};
        end
    end
end

% m = input(s);
fprintf('Please hit enter and select %d points.\n', numPtsInPolygon)
% get top figure
figure(gcf);
hold on

% x and y are coordinates selected by the pointer
x = zeros(numPtsInPolygon,1);
y = zeros(numPtsInPolygon,1);
% select the polygon of interest
for i=1:numPtsInPolygon
    if i==1
        [x(i), y(i)] = ginput(1);
        plot(x(i),y(i),'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','g',...
            'MarkerSize',6)
    elseif and(i>1, i<numPtsInPolygon)
        
        [x(i), y(i)] = ginput(1);
        plot(x(i-1:i),y(i-1:i),'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','g',...
            'MarkerSize',6)
    else
          
        [x([i]), y([i])] = ginput(1);
        plot(x([i-1 i 1 ]),y([i-1 i 1]),'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','g',...
            'MarkerSize',6)
    end

fprintf('%2d points left\n', (numPtsInPolygon-i))
%     title(sprintf('Num pts remaining: %d', numPtsInPolygon-i));
end

% indices of electrodes within the polygon
elIdxSel = find(inpolygon(xEl,yEl,x,y))';

% data to return
elIdSel = elId(elIdxSel);


end