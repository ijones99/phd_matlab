function selEls = get_elidx_from_flist(flist)
%  selEls = get_elidx_from_flist(flist)
ntkData = load_ntk2_data(flist,2);
selEls = ntkData.el_idx;

end