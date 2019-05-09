function neurNameMat = extract_selected_neur_name_matrix(neurNames,selNeurNameInds, listMatches, selMatch)
% NEURNAMES: 2 cells
% SELNEURNAMEINDS: selected indices 
% LISTMATCHES: first col has the indices of the first group; sequential
% columns have the indices for the matches to the other group. The values
% in each sequential column to the right are in order of decreasing percent
% match.
% SELMATCH: a vector with 1's to select column 2 of the listMatches, 2's to
% select column 3 of the listMatches, etc.

% init output cell
neurNameMat = cell(length(selNeurNameInds),1);

% index to use on selListMatches
indsWithinThisFunction = find(ismember(listMatches(:,1), selNeurNameInds));

% reduce matrix to rows of interest
listMatches = listMatches(indsWithinThisFunction,:);

subsToAccessListMatchesGp2 = zeros(size( listMatches,1),2);
subsToAccessListMatchesGp2(:,1) = 1:size( listMatches,1);
subsToAccessListMatchesGp2(:,2) =  selMatch+1;
indsToAccessListMatchesGp2 = sub2ind([size(listMatches,1) size(listMatches,2) ],...
    subsToAccessListMatchesGp2(:,1),subsToAccessListMatchesGp2(:,2));

numNeurs = length(selNeurNameInds);
neurNameMat(1:numNeurs,1) = neurNames{2}(listMatches( indsToAccessListMatchesGp2));






end