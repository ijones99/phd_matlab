function el_numbers = extract_ch_numbers_from_flist(flist)

samplesToLoad = 1;
elNumbers = {};

for i=1:length(flist)
    ntk=initialize_ntkstruct(flist{i});
    [ntk2 ntk]=ntk_load(ntk, samplesToLoad,  'images_v1');
    el_numbers{i} = ntk2.channel_nr;
    
end



end