function format(varargin)
% FORMAT(varargin)
%
% varargin
%   'dist_to_edge_of_plot'
%   'plot_dims'
%   'units'
%   'corner_onscreen'
%

edgeDist = [4 4];
plotDims = [10 10];
paperUnits = 'centimeters';
cornerEdgeXYOnscreen = [0 0];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'dist_to_edge_of_plot')
            edgeDist = varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_dims')
            plotDims = varargin{i+1};
        elseif strcmp( varargin{i}, 'units')
            paperUnits = varargin{i+1};
        elseif strcmp( varargin{i}, 'corner_onscreen')
            cornerEdgeXYOnscreen = varargin{i+1};
        end
    end
end

set(gcf, 'PaperUnits', paperUnits);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [edgeDist plotDims]);

widthOnscreen = edgeDist(1) + plotDims(1);
heightOnscreen = edgeDist(2) + plotDims(2);

%# set size of figure's "drawing" area on screen
set(gcf, 'Units','centimeters', 'Position',...
    [cornerEdgeXYOnscreen widthOnscreen heightOnscreen])

end

