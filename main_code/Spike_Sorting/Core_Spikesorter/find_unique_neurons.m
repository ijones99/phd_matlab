function uniqueNeurons = find_unique_neurons(tsMatrix, matchHeatMap, varargin)

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

 while ~isempty(remClusters)
    % select neuron
    iNeurons = remClusters(1);
        
    % find violations for each neuron
    violations = sort(unique([find(matchHeatMap(iNeurons,:)> matchingThresh)  ...
        find(matchHeatMap(:,iNeurons)'> matchingThresh)]))
    remClusters(ismember(remClusters,violations)) = [];
    
    % remove violations from list
    remClusters(find(ismember(remClusters,violations))) = [];
    
    % find max amp
    if ~isempty(violations)
        maxAmps = [];
        for i=1:length(violations)
            maxAmps(i) = max(tsMatrix{i}.el_avg_amp);
        end
        iNeurons
        savedClusters(end+1) = violations(find(maxAmps == max(maxAmps),1));
    end
end
uniqueNeurons = sort(unique(savedClusters))
% uniqueNeurons = allNeurons(~ismember(allNeurons, violatingNeurons));





end

