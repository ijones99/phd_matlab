function [elNoNear idxEls elDist] = get_neighboring_el(ctrElNo, m, numEls ) 
% [elNoNear idxEls elDist] = GET_NEIGHBORING_EL(ctrElNo, m, numEls) 


% idx of ctr el
idxCtr = find(m.elNo==ctrElNo);

% xy location of ctr el
pts1 = [m.mposx(idxCtr) m.mposy(idxCtr)];

pts2 = [mats.set_orientation(m.mposx,'col')...
    mats.set_orientation(m.mposy,'col')];

[elDist,idxEls] = ...
    geometry.find_closest_els_to_ctr_el(...
    pts1, pts2, numEls);


elNoNear = m.elNo(idxEls)';







end
