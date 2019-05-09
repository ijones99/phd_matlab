function [patchIdx distToPatchCtr] = find_closest_patches_to_els(selectedPatches, elidx)
%  [patchIdx distToPatchCtr] = FIND_CLOSEST_PATCHES_TO_ELS(selectedPatches, elidx)
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

%get ctr loc for patches
ctrLocPatch = zeros(numPatches,2);
for j=1:numPatches
    ctrLocPatch(j,:)= [mean(selectedPatches{j}.x) mean(selectedPatches{j}.y)];
end

% get sel el pos
all_els=hidens_get_all_electrodes(2);
posInfoSelEls = el2pos(elidx, all_els);


% find closest patches to els
patchIdx = [];
for j=1:length(elidx)
    
    dist = sqrt((ctrLocPatch(:,1)-posInfoSelEls.x(j)).^2 +(ctrLocPatch(:,2)-posInfoSelEls.y(j)).^2 );
    
   [distToPatchCtr(j),patchIdx(j)] = min(dist);
    
end




end