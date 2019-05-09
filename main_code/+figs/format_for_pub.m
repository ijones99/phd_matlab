function format_for_pub(varargin)
% function FORMAT_FOR_PUB(varargin)
%
% varargin
%   'plot_dims'
%   'dist_from_edge'
%   'font_name'
%   'font_size'
%   'line_width'
%   'x_label'
%   'y_label'
%   'title'
%   'journal_name', 'frontiers'
%   


edgeDist = [2 2];
plotDims = [18 18];
xLabel = '';
yLabel = '';
fontSize = [];
fontName = '';
lineWidth = 0.5;
xTicks = [];
yTicks = [];
figTitle = '';
journalName = '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot_dims')
            plotDims = varargin{i+1};
        elseif strcmp( varargin{i}, 'dist_from_edge')
            edgeDist = varargin{i+1};
        elseif strcmp( varargin{i}, 'font_name')
            fontName = varargin{i+1};
        elseif strcmp( varargin{i}, 'font_size')
            fontSize = varargin{i+1};
        elseif strcmp( varargin{i}, 'line_width')
            lineWidth = varargin{i+1};
        elseif strcmp( varargin{i}, 'x_label')
            xLabel = varargin{i+1};
        elseif strcmp( varargin{i}, 'y_label')
            yLabel = varargin{i+1};
        elseif strcmp( varargin{i}, 'title')
            figTitle = varargin{i+1};
        elseif strcmp( varargin{i}, 'journal_name')
            journalName = varargin{i+1};
        end
    end
end

if strcmp(journalName,'frontiers')
    if isempty(fontName),       fontName = 'Times'; end
    if isempty( fontSize ),     fontSize = 8; end
    if isempty(plotDims),       plotDims = [5 5]; end
end


set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [edgeDist plotDims]);

if lineWidth ~= 0.5
    figs.line_width(lineWidth )
end

%# set size of figure's "drawing" area on screen
% set(gcf, 'Units','centimeters', 'Position',[0 0 20 20])

% axis settings
if ~isempty(xLabel)
    xlabel(xLabel);
end
if ~isempty(yLabel)
    ylabel(yLabel);
end
if ~isempty(xTicks)
    figs.numticks(xTicks, []);
end
if ~isempty(yTicks)
    figs.numticks([], yTicks);
end
set(gca,'ticklength',2*get(gca,'ticklength'))

% figs.line_width(lineWidth);

if ~isempty(figTitle)
    title(figTitle);
end

% general settings
if ~isempty(fontSize)
    figs.font_size(fontSize)
end
if ~isempty(fontName)
    figs.font_name(fontName)
end


end