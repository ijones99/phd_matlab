function patchIdxSelAssigned = choose_configs_for_spikesorting_for_patches( selectedPatches, neurCtrs   )
% patchIdxSelAssigned = CHOOSE_CONFIGS_FOR_SPIKESORTING_FOR_PATCHES( selectedPatches, neurCtrs   )
%
% purpose: assign a config to a cell based on the cell's xy location.
% 
% arguments:
%   selectedPatches [structure] (see below)
%       elConfigInfo = flists.get_elconfiginfo_from_flist(flist);
%       selectedPatches = select_patches_overlapping(7, elConfigInfo );
%   neurCtrs: struct with x and y for coords of cell centers
%
%

minInterConfigDist = 40; %microns

patchCtr = {};
for i=1:length(selectedPatches)
    elPosPatch = configs.el2pos(selectedPatches{i}.selElNos);
    patchCtr.x(i) = mean(elPosPatch.x);
    patchCtr.y(i) = mean(elPosPatch.y);
end


%find distances from cells to closest config center
for i=1:length(neurCtrs.x)
    [patchIdx(i) distCellToConfigCtr(i)] = ...
        geometry.get_closest_point_to_matrix(patchCtr.x, patchCtr.y,[neurCtrs.x(i) neurCtrs.y(i)]);
end

selPatchCtr.x = patchCtr.x(patchIdx);
selPatchCtr.y = patchCtr.y(patchIdx);

% check distances between selected configs
[selPatchDistances  patchIdxCombos ] = geometry.get_distance_between_points(selPatchCtr);

% eliminate close patches
idxSelPatch =find(selPatchDistances < minInterConfigDist);

% patches to remove
remPatch = patchIdx(patchIdxCombos(idxSelPatch,1));

% selected patches
patchIdxKeepIdx = find(~ismember(patchIdx,remPatch));
patchIdxSel = patchIdx(patchIdxKeepIdx);

% assign cell ctrs to configs
%find distances from cells to closest config center
for i=1:length(neurCtrs.x)
    [patchIdxReassIdxselPatch(i) distCellToConfigCtrReassIdxselPatch(i)] = ...
        geometry.get_closest_point_to_matrix(patchCtr.x(patchIdxSel), patchCtr.y(patchIdxSel),[neurCtrs.x(i) neurCtrs.y(i)]);
end

patchIdxSelAssigned = patchIdxSel(patchIdxReassIdxselPatch)';

end