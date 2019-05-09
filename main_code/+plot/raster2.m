function raster2(t, varargin)
% RASTER2(t, varargin)
%
% 'offset'
% 'height'
% 'color'

if iscolumn(t);
    t = t';
end
lineWidth = 1;
lineHeight = 2;
lineOffset = 0;
yLimSizeTimesLineHt = 2;
doYlim= 0;
plotColor = 'k';
boldIdx = 0;
yLim =[];xLim =[];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'offset')
            lineOffset = varargin{i+1};
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
        elseif strcmp( varargin{i}, 'linewidth')
            lineWidth = varargin{i+1};
        end
    end
end


linePos = [-0.5; 0.5]*lineHeight+lineOffset;
line(repmat(t,2,1) , repmat(linePos,1,length(t)) ,'Color',plotColor,'LineWidth', lineWidth); 

% yLim
if doYlim
    yLim = yLimSizeTimesLineHt*[-lineHeight/2 lineHeight/2]+lineOffset;
    ylim(yLim);
end

if ~isempty(yLim) 
   ylim(yLim); 
end

if ~isempty(xLim) 
   xlim(xLim); 
end


end