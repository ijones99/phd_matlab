function p2pAmp = plot_mean_wfs_with_dist(SponWfMeanCtr, d, chNum, varargin)
% p2pAmp = PLOT_MEAN_WAVEFORMS(SponWfMeanCtr, chNum)

SPACING = 2;
scaleFactor = 1;
doPlotReverseOrder = 0;
SponWfMeanCtr = mea1kadd.center_wfs(SponWfMeanCtr);
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

p2pAmp = [];
hold on
for i=iVals
    currTrace = SponWfMeanCtr(chNum(i),:);
    p2pAmp(i) = max(currTrace)-min(currTrace);
    plot( scaleFactor*currTrace+d(i),'LineWidth',lineW,'Color', lineCol);
end


end
