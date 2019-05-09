function [elsNumbersSel indNearest] = ...
    select_els_with_pointer( all_els, varargin )
%SELECT_ELS_WITH_POINTER Select a polygon and return the points within
%   the polygon. Intended use: in NeuroRouter
%   [ELSNUMBERSINSIDE INDSLOCALINSIDE] = SELECT_ELS_WITH_POINTER( ALL_ELS )
%   
%   INPUT PARAMETERS:
%       ALL_ELS:    A struct returned by all_els=hidens_get_all_electrodes(versionNo)
%
%   OUTPUT PARAMETERS:
%       elsNumbersSel: electrodes selected
%       indsNearest: indices to reference values in all_els struct 
%
%    Author ijones bsse

% number of points to click
numPtsInPolygon = 5;

% init vars
figH = [];
axesH = [];
plotStyle = 'ro';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'axes_h')
            axesH = varargin{i+1};
        elseif strcmp( varargin{i}, 'fig_h')
            figH = varargin{i+1};
        elseif strcmp( varargin{i}, 'num_pts')
            numPtsInPolygon = varargin{i+1};
        end
    end
end

% get top figure
figure(gcf);
hold on

% x and y are coordinates selected by the pointer
indNearest = zeros(numPtsInPolygon,1);
x = zeros(numPtsInPolygon,1);
y = zeros(numPtsInPolygon,1);
% select the polygon of interest
for i=1:numPtsInPolygon
        % sel point
        [x(i), y(i)] = ginput(1);
        % find euclidian distance
        eucDist = pdist2([all_els.x' all_els.y'], [x(i) y(i)]);
        % get nearest pt
        [junk indNearest(i)] = min(eucDist);
        % plot point
        plot(all_els.x(indNearest(i)), all_els.y(indNearest(i)), plotStyle);
end


% data to return
% electrode numbers selected
elsNumbersSel = all_els.el_idx(indNearest);
% indices for all_els
% indNearest




