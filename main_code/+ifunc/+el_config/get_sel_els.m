function [selElInds unselElInds] = get_sel_els(elConfigInfo, unselElNos)
% [selElInds unselElInds] = get_sel_els(elConfigInfo, unselElNos)
% get the selected electrode from elConfigInfo

unselElInds = find(ismember(elConfigInfo.selElNos, unselElNos));
selElInds = find(~ismember(elConfigInfo.selElNos, unselElNos));

end