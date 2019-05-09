function listMatches = find_closest_matching_footprints_from_sim_mat(similarityMat,numMatches,varargin)
P.sort_direction = 'descend';
P = mysort.util.parseInputs(P, varargin, 'error');

% initialize matrix
listMatches = zeros(size(similarityMat,1),numMatches+1);
listMatches(:,1) = 1:size(similarityMat,1);

if strcmp(P.sort_direction,'ascend')
    [Y,I]=sort(similarityMat,2,'ascend');
else
    [Y,I]=sort(similarityMat,2,'descend');
end
listMatches(:,2:numMatches+1) = I(:,1:numMatches);



end