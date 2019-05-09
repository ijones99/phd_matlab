function [matchingGps uniqueClusters]= find_similar_groups(inputMatrix, threshOperator, selThreshold)

% violatingNeurons = sort(unique([rows cols]))';
discardedClusters = [];
savedClusters = [];
isFinished = 0;
iCluster = 1;

clusterList = 1:size(inputMatrix,1); % cluster list contains all clusters
eval(['heatMapHits = inputMatrix',threshOperator, num2str(selThreshold),';']); %all matching pairs are assigned a 1
fprintf('\n');
savedClusteredSpiketrains = {};
i=1;
figure, imagesc(heatMapHits)
while ~isempty(clusterList) % cycle through until there are no more clusters left
    clusterIndAndAmp = []; % set amplitude to empty for each loop
    % find pool of all matching for a given neuron
    mainClusterNo = clusterList(1); % take first cluster in list
    [rowMatches1 colMatches1] = find(heatMapHits(mainClusterNo,:)==1); % look along row for matches;
    [rowMatches2 colMatches2] = find(heatMapHits(:,mainClusterNo)==1); % look along column for matches;
    currMatchingSpiketrains = sort(unique([ mainClusterNo  colMatches1 rowMatches2' ]));%combine the matching neuron numbers (inds)
    savedClusteredSpiketrains{end+1} = currMatchingSpiketrains; % save the matches
    
    %     clusterNeurNoAndAmp = []; % rows: electrode number, max amplitude
    %     for iCurrMatchST = 1:length(currMatchingSpiketrains) % go through all matches and get amplitudes
    %         clusterNeurNoAndAmp(iCurrMatchST,1) = currMatchingSpiketrains(iCurrMatchST); % number of neuron
    %         clusterNeurNoAndAmp(iCurrMatchST,2) = max(tsMatrix{iCurrMatchST}.el_avg_amp);
    %     end
    %     [Y,maxAmpInd] = max(clusterNeurNoAndAmp(:,2)); % find max amp
    %     savedClusters(end+1) = clusterNeurNoAndAmp(maxAmpInd,1); % saved cluster based on the groups of
    %     ... electrodes that has the largest amplitude.
    clusterList(find(ismember(clusterList,currMatchingSpiketrains)))=[]; % remove matching indices
    
    % remove the matches from the heatmap hits, since they've already been
    % grouped
    for k=1:length(currMatchingSpiketrains)
        heatMapHits(currMatchingSpiketrains(k),:) = 0;
        heatMapHits(:,currMatchingSpiketrains(k)) = 0;
    end
    
    
    ...from main list
%         clusterListr
% clusterList
%    
%      i=i+1;
%     i
end
matchingGps = {};
uniqueClusters = [];
numUniqueClusters = 0;
for j=1:length(savedClusteredSpiketrains)
    
    if size(savedClusteredSpiketrains{j},2) > 1
        matchingGps{end+1} = savedClusteredSpiketrains{j};
    else
        numUniqueClusters = numUniqueClusters+1;
        uniqueClusters(end+1) = savedClusteredSpiketrains{j};
    end
    
end

fprintf('%d groups with duplicates found.\n', length(matchingGps));
fprintf('%d independent clusters found.\n', numUniqueClusters);
end