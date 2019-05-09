function raster_from_cells(tsCell, varargin)
% RASTER_FROM_CELLS(tsCell, varargin)


lineHeight = 0.5;
lineWidth=1;
lineOffset = 0;
yLimSizeTimesLineHt = 2;
doYlim= 0;
plotColor = 'k';
boldIdx = 0;
yLim =[];xLim =[];
offsetIdx = 0;
xScaleFactor = 1;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'offset')
            lineOffset = varargin{i+1};
             elseif strcmp( varargin{i}, 'offset_idx')
            offsetIdx  = varargin{i+1};
        elseif strcmp( varargin{i}, 'height')
            lineHeight = varargin{i+1};
        elseif strcmp( varargin{i}, 'ylim_times_height')
            yLimSizeTimesLineHt = varargin{i+1};
            doYlim = 1;
        elseif strcmp( varargin{i}, 'line_y_range')
            lineRange = varargin{i+1};
            lineHeight = abs(diff(lineRange));
            lineOffset = min(lineRange)+0.5*lineHeight;
        elseif strcmp( varargin{i}, 'do_ylim')
            doYlim = 1;
        elseif strcmp( varargin{i}, 'color')
            plotColor  = varargin{i+1};
        elseif strcmp( varargin{i}, 'bold_idx')
            boldIdx  = varargin{i+1};
        elseif strcmp( varargin{i}, 'x_axis_scale_factor')
            xScaleFactor  = varargin{i+1};
        elseif strcmp( varargin{i}, 'linewidth')
            lineWidth= varargin{i+1};
        end
    end
end

for i=1:length(tsCell)
    plot.raster2(tsCell{i}*xScaleFactor,'height',lineHeight,...
        'offset', (i+offsetIdx-1)+lineOffset, 'color', plotColor, 'linewidth', lineWidth);
end



end