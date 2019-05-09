function plot_waveforms_mean(SponWfMean, elIdx, elNo, varargin)
% PLOT_WAVEFORMS_MEAN(SponWfMean, elIdx)

SPACING = 2;
doNormalize = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'spacing')
            SPACING = varargin{i+1};
        elseif strcmp( varargin{i}, 'normalize')
            doNormalize = 1;
        end
    end
end

plotSymbols = {'--d', '--<','o--', 's--', '+--', '>--', '--^', 'v--', '*--'};

h=figure, hold on
figs.scale(h,30,100);

elIdxLabel = num2str(elNo);

cMap = plot.colormap_optimal_colors(length(elNo));

for i=1:length(elIdx)
    iSym = randi(length(plotSymbols));
    currTraces = diff(SponWfMean(:,elIdx(i)));
    
    if doNormalize
       currTraces  = normalize_values(currTraces ,[0 1]); 
    end
    
    plot( currTraces+i*SPACING,plotSymbols{iSym}, 'LineWidth',1,'Color', cMap(i,:),...
        'LineWidth', 3)
end



legend(elIdxLabel);
end
