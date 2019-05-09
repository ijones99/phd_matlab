function [elDist,idxEls] = find_closest_els_to_ctr_el(pts1, pts2, numEls, varargin)
% function[elDist,idxEls] = FIND_CLOSEST_ELS_TO_CTR_EL(pts1, pts2, numEls, varargin)

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


[Y,I] = sort(allCombos,'ascend');

elDist = Y(1:numEls+1);
idxEls = I(1:numEls+1);
end