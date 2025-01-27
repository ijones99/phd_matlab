function [sortedRedundantClusterGroups redundantClusterGroups] = find_redundant_clusters(tsMatrix, matchHeatMap, varargin)

filesSelInDir = [];
neuronsIndSel = 0;
binWidthMs = 1;
matchingThresh = 0.1;
i=1;
redundantClusterGroups = {};
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

% set self-comparisons to zero
% selfComparisionInds = sub2ind(size(matchHeatMap),1:size(matchHeatMap,1),1:size(matchHeatMap,1));
% matchHeatMap( selfComparisionInds ) = 0;

% [rows,cols,vals] = find(matchHeatMap>matchingThresh);

% allNeurons = 1:size(matchHeatMap,1);
% violatingNeurons = sort(unique([rows cols]))';
discardedClusters = [];
savedClusters = [];
remClusters = 1:size(matchHeatMap,1);
isFinished = 0;
iNeurons = 1;

% go through all rows and columns in heat map and extract unique values of
% redundant clusters 
allClusterGroups = {};
for iClusterInHeatmap = remClusters
    allClusterGroups{iClusterInHeatmap} = sort(unique([find(matchHeatMap(iClusterInHeatmap,:)  >matchingThresh) ...
        find(matchHeatMap(:, iClusterInHeatmap)  >matchingThresh)']));
    
end
% empty vector to contain the found groups
redundantClusterGroups = {};
iRedundantClusterGroups = 1;

% while there are still unused cluster numbers
while ~isempty(remClusters)
    % set first group as reference
    redundantClusterGroups{iRedundantClusterGroups} = allClusterGroups{remClusters(1)};
    clustersNumbersToRemove = [];
    % go through all remaining groups
    for i= remClusters(2:end)

        if intersect(redundantClusterGroups{iRedundantClusterGroups}, allClusterGroups{i})  % compare cluster to all other clusters
            % add groups with intersections
            redundantClusterGroups{iRedundantClusterGroups}  = ...
                sort(unique([ redundantClusterGroups{iRedundantClusterGroups} allClusterGroups{i}]));
            % remove clusters from remClusters vector
            clustersNumbersToRemove(end+1) = find(remClusters ==  i);
        end
        
    end

    remClusters([1 clustersNumbersToRemove]) = [];
    iRedundantClusterGroups = iRedundantClusterGroups+1
end

% get the clusters with the highest amplitude
sortedRedundantClusterGroups = {};
% go through all groups
for iRedundantClusterGroups = 1:length(redundantClusterGroups)
    maxAmps = []; % max amplitudes on electrodes
    % go through elements of each group
    for i=1:length(redundantClusterGroups{iRedundantClusterGroups})
        clusterGroup = redundantClusterGroups{iRedundantClusterGroups}(i); % group number
        maxAmps(i) = max(tsMatrix{clusterGroup}.el_avg_amp);
      
    end
    [ampVals amplitudeInds] = sort(maxAmps,'descend');
	sortedRedundantClusterGroups{iRedundantClusterGroups} = redundantClusterGroups{iRedundantClusterGroups}(amplitudeInds);
end




end