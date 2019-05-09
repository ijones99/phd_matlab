function selIdxNos = find_patches_containing_els(selectedPatches, elidx)
% selIdxNos = FIND_PATCHES_CONTAINING_ELS(selectedPatches, elidx)
%
% purpose: to find patch numbers (groups of electrode numbers) that contain
% the inputted electrode numbers
%
% args
%   selectedPatches: (e.g. selectedPatches =
%   select_patches_exclusive(numEls, elConfigInfo,'xy_pos' );)
%
%   elidx = electrodes to find in patches

numPatches = length(selectedPatches);

% init output
elidxPatchesMat = zeros(numPatches, length(selectedPatches{1}.selElNos));


%create matrix of elidx's in patches
for j=1:numPatches

    elidxPatchesMat(j,1:length(selectedPatches{j}.selElNos)) = ...
        selectedPatches{j}.selElNos;

end

% search matrix for els
rows= {};
for i=1:length(elidx)
    [currRow,junk,vals] = find(elidxPatchesMat==elidx(i));
    if ~isempty(currRow)
       rows{i} = currRow; 
    else 
        rows{i} = -1; 
    end
end

selIdxNos = (cell2mat(rows));


end