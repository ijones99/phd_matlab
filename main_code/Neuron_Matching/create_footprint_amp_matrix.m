function outputMatrix = create_footprint_amp_matrix(footprint)
% function outputMatrix = create_footprint_amp_matrix(footprint)
% ian.jones@bsse.ethz.ch

outputMatrix = max(footprint,[],2)-min(footprint,[],2);
outputMatrix = permute(outputMatrix ,[3 2 1]);

end