function ntkData = get_ntk_data(flist, size)

ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, size);

ntkData.sig = single(ntk2.sig);
ntkData.chNos = ntk2.channel_nr;
ntkData.elNos = ntk2.el_idx;

end