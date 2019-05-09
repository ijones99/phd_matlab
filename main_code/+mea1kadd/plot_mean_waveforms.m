function p2pAmp = plot_mean_waveforms(SponWfMeanCtr, chNum, varargin)
% p2pAmp = PLOT_MEAN_WAVEFORMS(SponWfMeanCtr, chNum)

SPACING = 2;
scaleFactor = 1;
doPlotReverseOrder = 0;
SponWfMeanCtr = mea1kadd.center_wfs(SponWfMeanCtr);

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'spacing')
            SPACING = varargin{i+1};
        elseif strcmp( varargin{i}, 'scale')
            scaleFactor  = varargin{i+1};
        elseif strcmp( varargin{i}, 'reverse')
            doPlotReverseOrder = 1;
        end
    end
end

if doPlotReverseOrder
    chNum = chNum(end:-1:1);
end

p2pAmp = [];
hold on
for i=1:length(chNum)
    currTrace = SponWfMeanCtr(chNum(i),:);
    p2pAmp(i) = max(currTrace)-min(currTrace);
    plot( scaleFactor*currTrace+i*SPACING,'LineWidth',2,'Color', 'k')
end




end
