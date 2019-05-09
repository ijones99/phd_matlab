function spikeMat = cell2nanmat(repeats)
% function spikeMat = cell2nanmat(repeats)
% PURPOSE: convert a cell (rows of repeats of a spike response)
%    to a matrix that has as many columns as the longest cell
%    element. The rows of the other repeats contain NaNs;

% get number of repeats
numReps = length(repeats)   ;

% get max num spikes
maxNumSpikes = max(cellfun(@length, repeats));

% init spike mat
spikeMat = nan(numReps,maxNumSpikes);

for i=1:numReps   
    spikeMat(i,1:length(repeats{i})) = repeats{i};
end




end