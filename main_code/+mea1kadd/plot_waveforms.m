function plot_waveforms(SponWfTraces, elIdx, varargin)
% PLOT_MEAN_WAVEFORMS(SponWfTraces, elIdx)

SPACING = 2;
scaleFactor = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'spacing')
            SPACING = varargin{i+1};
        elseif strcmp( varargin{i}, 'scale')
            scaleFactor  = varargin{i+1};
        end
    end
end


for i=1:length(elIdx)
  
    currTraces = permute(SponWfTraces(:,elIdx(i),:),[1 3 2]);
    meanTr = mean(currTraces,1);
    meanTrRep = repmat(meanTr',1,size(currTraces,1))';
    currTraces = currTraces - meanTrRep;
    plot( scaleFactor*currTraces+i*SPACING,'LineWidth',1)
end




end
