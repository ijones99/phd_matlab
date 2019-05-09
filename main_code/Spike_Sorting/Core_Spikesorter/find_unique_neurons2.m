function [uniqueNeurons savedClusteredSpiketrains] = find_unique_neurons2(tsMatrix, HeatMapVals, varargin)

filesSelInDir = [];
neuronsIndSel = 0;
binWidthMs = 0.5;
matchingThresh = 0.1;
i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        
        if  strcmp(varargin{i},'bin_width')
            binWidthMs = varargin{i+1};
        elseif  strcmp(varargin{i},'matching_thresh')
            matchingThresh = varargin{i+1};
        elseif  strcmp(varargin{i},'sel_inds')
            matchingThresh = varargin{i+1};
        else
            fprintf('unknown argument at pos %d\n', 2+i);
        end
    end
    i=i+1;
end

% allNeurons = 1:size(matchHeatMap,1);
% violatingNeurons = sort(unique([rows cols]))';
discardedClusters = [];
savedClusters = [];
isFinished = 0;
iCluster = 1;

clusterList = 1:size(HeatMapVals,1); % cluster list contains all clusters
heatMapHits = HeatMapVals>matchingThresh; %all matching pairs are assigned a 1
fprintf('\n');
savedClusteredSpiketrains = {};
i=1;
while ~isempty(clusterList) % cycle through until there are no more clusters left
    clusterIndAndAmp = []; % set amplitude to empty for each loop
    % find pool of all matching for a given neuron
    mainClusterNo = clusterList(1); % take first cluster in list
    [rowMatches1 colMatches1] = find(heatMapHits(mainClusterNo,:)==1); % look along row for matches;
    [rowMatches2 colMatches2] = find(heatMapHits(:,mainClusterNo)==1); % look along column for matches;
    currMatchingSpiketrains = sort(unique([colMatches1 rowMatches2' ]));%combine the matching neuron numbers (inds)
    savedClusteredSpiketrains{end+1} = currMatchingSpiketrains; % save the matches
    
    clusterNeurNoAndAmp = []; % rows: electrode number, max amplitude
    for iCurrMatchST = 1:length(currMatchingSpiketrains) % go through all matches and get amplitudes
        clusterNeurNoAndAmp(iCurrMatchST,1) = currMatchingSpiketrains(iCurrMatchST); % number of neuron
        clusterNeurNoAndAmp(iCurrMatchST,2) = max(tsMatrix{iCurrMatchST}.el_avg_amp);
    end
    [Y,maxAmpInd] = max(clusterNeurNoAndAmp(:,2)); % find max amp
    savedClusters(end+1) = clusterNeurNoAndAmp(maxAmpInd,1); % saved cluster based on the groups of 
    ... electrodes that has the largest amplitude.
    clusterList(find(ismember(clusterList,currMatchingSpiketrains)))=[]; % remove matching indices
    ...from main list
    clusterList
    i=i+1
end
% alreadyUniqueRows = find(sum(heatMapHits,1)==1); 
% alreadyUniqueCols = find(sum(heatMapHits,2)==1);
% uniqueRowsAndCols = unique(union(alreadyUniqueRows, alreadyUniqueCols));
uniqueNeurons = sort(unique([savedClusters  ]));
% for j=1:length(uniqueRowsAndCols )
%     savedClusteredSpiketrains{end+1} = uniqueRowsAndCols(j);
%     
% end

end
