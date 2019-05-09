function plot_mean_traces_with_dist(SponWfMeanCtr, d, chNum, varargin)
% PLOT_MEAN_TRACES_WITH_DIST(SponWfMeanCtr, chNum)
% size SponWfMeanCtr: [40x1024x15]
%
%

SPACING = 2;
scaleFactor = 1;
doPlotReverseOrder = 0;
% SponWfMeanCtr = mea1kadd.center_wfs(SponWfMeanCtr);
lineCol = 'k';
lineW = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'spacing')
            SPACING = varargin{i+1};
        elseif strcmp( varargin{i}, 'scale')
            scaleFactor  = varargin{i+1};
        elseif strcmp( varargin{i}, 'reverse')
            doPlotReverseOrder = 1;
        elseif strcmp( varargin{i}, 'color')
            lineCol = varargin{i+1};
        elseif strcmp( varargin{i}, 'width')
            lineCol = varargin{i+1};
        end 
    end
end

if doPlotReverseOrder
    chNum = chNum(end:-1:1);
end

hold on
for i=1:length(chNum)
    for j=1:size(SponWfMeanCtr,3);
        currTrace = squeeze(SponWfMeanCtr(:,chNum(i),j));
        plot( scaleFactor*currTrace+d(i),'LineWidth',2,'Color', lineCol);
    end
end


end
