function plot_space_time_plot(neur, clusNo, directionSel, varargin)
% PLOT_SPACE_TIME_PLOT(R_, clusNo, stimChangeTs_, stimFrameInfo, directionSel)

doSavePlot = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'save_plot')
            doSavePlot = 1;

        end
    end
end

% get positions
uniquePos = {};

totalNumPos = size( neur.ms.settings.pos,1);

if directionSel == 1
    selRange = [1 totalNumPos/2];
else
    selRange = [totalNumPos/2+1 totalNumPos ];
end

uniquePos = unique(neur.ms.settings.pos(selRange(1):selRange(2),:),'rows','stable');

stimDurSec = 4;

% go through each position
for iStep = 1:size(uniquePos,1)
    % get idx
    currIdx = find(ismember(neur.ms.settings.pos(selRange(1):selRange(2),:),uniquePos(iStep,:),'rows'));
    idxRaster = [(currIdx*2)-1 (currIdx*2)+1]+selRange(1)-1;
    % extract all current spiketrain segments
    spiketrainCell = spiketrains.extract_multiple_epochs(neur.ms.st, neur.ms.stim_change_ts, idxRaster);
    % get mean firing rate per position
    [firingRate(iStep,:) edges] = ifunc.analysis.firing_rate.est_firing_rate_from_psth(spiketrainCell,[0 stimDurSec*2e4]);
    
end

imagesc(firingRate)
axis square
colorbar
% relabel
colNo = find(sum(abs(uniquePos),1)>0);

yticklabels = uniquePos(:,colNo); 
yticks = 1:length(yticklabels);
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels)

xticks = 1:length(edges);
xticklabels = linspace(1/stimDurSec,stimDurSec,length(edges))';
xticklabelsTxt = num2str(round2(xticklabels,0.1));
xticklabelsLowRes = repmat('   ',size(xticklabelsTxt,1),1);
xticklabelsLowRes(1:10:end,:) = xticklabelsTxt(1:10:end,:);
set(gca, 'XTick', xticks, 'XTickLabel', xticklabelsLowRes)

if doSavePlot
  warning('Not implemented\n')
end


end