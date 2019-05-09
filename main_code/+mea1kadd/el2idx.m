function idx = el2idx(elNum, allIdx)
% idx = EL2IDX(elNum, allIdx)

idx = find(ismember(allIdx, elNum));


end