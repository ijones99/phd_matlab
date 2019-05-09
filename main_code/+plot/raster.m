function raster(t, varargin)
% RASTER(t, varargin)
%
% 'offset'
% 'height'
% 'ylim_times_height'
% linePos = [-lineHeight/2 lineHeight/2]+lineOffset ;


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
        elseif strcmp( varargin{i}, 'ylim')
            yLim  = varargin{i+1};
        elseif strcmp( varargin{i}, 'xlim')
            xLim  = varargin{i+1};
        end
    end
end



nspikes   = numel(t); % number of elemebts / spikes

linePos = [-lineHeight/2 lineHeight/2]+lineOffset ;    

if sum(boldIdx)>0
    for ii = 1:nspikes % for every spike
        lineWidth=1;
        if find(ismember(boldIdx,ii))
            lineWidth=2;
        end
        line([t(ii) t(ii)],linePos,'Color',plotColor,'LineWidth',lineWidth); % draw a black vertical line at time t (x) and at trial 180 (y)
    end 
else
    for ii = 1:nspikes % for every spike
        line([t(ii) t(ii)],linePos,'Color',plotColor); % draw a black vertical line at time t (x) and at trial 180 (y)
    end
end


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