function idx = el2idx(elNum, allIdx)
% idx = EL2IDX(elNum, allIdx)
%
% allIdx = m_stim.elNo
%

idx = find(ismember(allIdx, elNum))-1;


end