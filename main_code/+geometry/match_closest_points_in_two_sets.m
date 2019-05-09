function [matchList allCombos] = ...
    match_closest_points_in_two_sets(pts1, pts2, thresholdDist, varargin)
% function [matchList allCombos] = ...
% match_closest_points_in_two_sets(pts1, pts2, thresholdDist)
%
% Purpose: compare distances between two sets of coordinate points
% and determine points that are closest to one another. 
%
% Arguments:
%   pts1: [nx2] array with n points: this is the baseline set of points
%   pts2: second set of points
%   thresholdDist: maximal distance allowed for matching
%
% Varargin
%   lim_to_closest_match: only show results for closest matching point from
%   second list.
% Output:
%   matchList: 
%       col of idx for first set of points (sorted); 
%       col of idx for second set of pts; (equivalent to the R idx + 3, 
%       since the first 3 idx's are the general stimuli)
%       col of distances between the matched points
%   allCombos: cross correlation of all point comparisons

doFindClosestMatchOnly = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'lim_to_closest_match')
            doFindClosestMatchOnly = 1;
         end
    end
end






numPts1 = size(pts1,1);
numPts2 = size(pts2,1);

allCombos = zeros(numPts1, numPts2);

% cross-comparison of all distances.
for i=1:numPts1 
    for j=1:numPts2
        
        allCombos(i,j) =...
            geometry.get_distance_between_2_points(...
            pts1(i,1),pts1(i,2),...
            pts2(j,1),pts2(j,2));
    end
end

% apply threshold
[idxPts1,idxPts2,vals] = find(allCombos<thresholdDist);

% get distances
linearInd = sub2ind([numPts1, numPts2], idxPts1, idxPts2);
distOut =allCombos(linearInd);

% create match list
matchList = zeros(length(idxPts1),3);
matchList=[ idxPts1 idxPts2 distOut];

keepIdx = [];

if doFindClosestMatchOnly
    uniquePts1Idx = unique(idxPts1); % unique list 1 values
    for iFoundIdx=1:length(uniquePts1Idx)
       currPtsIdx = find( idxPts1 == uniquePts1Idx(iFoundIdx));
        if length(currPtsIdx)>1 % duplicate values
            [Y,I] = sort(distOut(currPtsIdx));
            keepIdx(end+1) = currPtsIdx(I(1));
        else
            keepIdx(end+1) = currPtsIdx; 
        end
    end
    
    % apply to matchList
    matchList = matchList(keepIdx,:);
    
end


% sort
[B I] = sort(matchList(:,1));
matchList = matchList(I,:);



end