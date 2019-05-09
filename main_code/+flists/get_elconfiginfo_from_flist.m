function elConfigInfo = get_elconfiginfo_from_flist(flist) 
% function elConfigInfo = get_elconfiginfo_from_flist(flist)
% 
%      selElNos: []
%           elX: []
%           elY: []
%      allElNos: [1x11016 double]
%        allElX: [1x11016 single]
%        allElY: [1x11016 single]
%     channelNr: []
verNo = 2;
all_els=hidens_get_all_electrodes(verNo);



ntkData = load_ntk2_data(flist,2);

elConfigInfo = {};

elConfigInfo.selElNos=ntkData.el_idx;
elConfigInfo.elX=ntkData.x;
elConfigInfo.elY=ntkData.y;
elConfigInfo.allElNos=all_els.el_idx;
elConfigInfo.allElX =all_els.x;
elConfigInfo.allElY =all_els.y;
elConfigInfo.selChNos= ntkData.channel_nr;


end