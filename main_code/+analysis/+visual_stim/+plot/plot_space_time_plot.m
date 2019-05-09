function plot_space_time_plot(R_, clusNo, stimChangeTs_, stimFrameInfo, directionSel, varargin)
% PLOT_SPACE_TIME_PLOT(R_, clusNo, stimChangeTs_, stimFrameInfo, directionSel)
%
% varargin:
%   'save_plot', 'subtract_pre_stim_fr'

doSavePlot = 0;
doSubtractPreStimFR = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'save_plot')
            doSavePlot = 1;
        elseif strcmp( varargin{i}, 'subtract_pre_stim_fr')
            doSubtractPreStimFR  = 1;
        end
    end
end

% get positions
uniquePos = {};

totalNumPos = size( stimFrameInfo.pos,1);

if directionSel == 1
    selRange = [1 totalNumPos/2];
else
    selRange = [totalNumPos/2+1 totalNumPos ];
end

uniquePos = unique(stimFrameInfo.pos(selRange(1):selRange(2),:),'rows','stable');

% get timestamps
stCurr = spiketrains.extract_st_from_R(R_, clusNo);       

% go through each position
for iStep = 1:size(uniquePos,1)
    % get idx
    currIdx = find(ismember(stimFrameInfo.pos(selRange(1):selRange(2),:),uniquePos(iStep,:),'rows'))+selRange(1)-1;
    idxRaster = [(currIdx*2)-1 (currIdx*2)+1];
    
    % extract all current spiketrain segments
    spiketrainCell = spiketrains.extract_multiple_epochs(stCurr, stimChangeTs_, idxRaster, 'pre_stim_time_sec',0.25);
    % get mean firing rate per position
    [firingRate(iStep,:) edges] = ifunc.analysis.firing_rate.est_firing_rate_from_psth(spiketrainCell,[-0.25 4]*2e4);

end

% subtract baseline
if doSubtractPreStimFR
    idxNeg = find(edges<0);
    meanFRBeforeStim = mean(mean(firingRate(:,idxNeg)));
    % subtract mean before stim
    firingRate = firingRate-meanFRBeforeStim;
end


imagesc(firingRate)

% relabel
colNo = find(sum(uniquePos,1)>0);

yticklabels = uniquePos(end:-1:1,colNo); 
yticks = 1:length(yticklabels);
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels)

% xticks = 1:4:51;
% xticklabels = linspace(2/51,2,length(xticks));
% set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)

if doSavePlot
  warning('Not implemented\n')
end


end