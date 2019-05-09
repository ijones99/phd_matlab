function plot_traces_with_dist(SponWfMeanCtr, d, chNum, varargin)
% PLOT_TRACES_WITH_DIST(SponWfMeanCtr, chNum)
% size SponWfMeanCtr: [40x1024x15]
%
%

SPACING = 2;
scaleFactor = 1;
doPlotReverseOrder = 0;
SponWfMeanCtr = mea1kadd.center_traces(SponWfMeanCtr);
lineCol = 'k';
lineW = 1;
delIdx = [];

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
            lineW = varargin{i+1};
        elseif strcmp( varargin{i}, 'del_idx')
            delIdx = varargin{i+1};
        end 
    end
end

if doPlotReverseOrder
    chNum = chNum(end:-1:1);
end

iVals = 1:length(chNum);
if ~isempty(delIdx)
   iVals(delIdx) = [];
end

hold on
for i=iVals
    for j=1:size(SponWfMeanCtr,3);
        currTrace = squeeze(SponWfMeanCtr(:,chNum(i),j));
        plot( scaleFactor*currTrace+d(i),'LineWidth',lineW,'Color', lineCol);
    end
end


end
