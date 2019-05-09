function elConfigInfo = add_ntk2_el_list_order_to_elconfiginfo(flist, elConfigInfo)
% function elConfigInfo = add_ntk2_el_list_order_to_elconfiginfo(flist, elConfigInfo)


% load data
timeToLoadSamples = 2;
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, timeToLoadSamples);

% get inds for electrode order
[junk loc]=ismember(ntk2.el_idx,elConfigInfo.selElNos);
% e.g. elConfigInfo.selElNos(loc) = ntk2.el_idx;
% add fields to elconfiginfo
elConfigInfo.nrk2_to_ntk2_conversion_inds = loc;
elConfigInfo.selElNosNtk2 = ntk2.el_idx;
elConfigInfo.elXNtk2 = elConfigInfo.elX(loc);
elConfigInfo.elYNtk2 = elConfigInfo.elY(loc);

% get reverse inds for electrode order
[junk loc2]=ismember( elConfigInfo.selElNos, ntk2.el_idx);
elConfigInfo.ntk2_to_nrk2_conversion_inds = loc2;


end