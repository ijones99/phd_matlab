function format_hist_for_pub( varargin)
% FORMAT_HIST_FOR_PUB( varargin)
%
% varargin
%   'journal_name',  'frontiers'
%   'face_color'
%   'edge_color'
%   'line_width'
%

numBins=30;
faceColor= [];
edgeColor = '';
lineWidth = [];
journalName = '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'journal_name')
            journalName = varargin{i+1};
        elseif strcmp( varargin{i}, 'face_color')
            faceColor =  varargin{i+1};
        elseif strcmp( varargin{i}, 'edge_color')
            edgeColor =  varargin{i+1};
        elseif strcmp( varargin{i}, 'line_width')
            lineWidth =  varargin{i+1};
        end
    end
end



h = findobj(gca,'Type','patch');

if strcmp(journalName, 'frontiers')
    if isempty(faceColor)
        set(h,'FaceColor',ones(1,3)*0.5)
    end
    if isempty(edgeColor)
        set(h,'edgeColor','k')
    end
    if isempty(lineWidth)
        set(h,'LineWidth',1)
    end
else
    if ~isempty(faceColor)
        set(h,'FaceColor',faceColor)
    end
     if ~isempty(edgeColor)
        set(h,'edgeColor',edgeColor)
    end
    if ~isempty(lineWidth)
        set(h,'LineWidth',lineWidth)
    end
end

axis tight % Fit the axes box tightly around the data by ...
% setting the axis limits equal to the range of the data. 

end