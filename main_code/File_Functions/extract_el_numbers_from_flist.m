function [el_numbers chNumbers ] = extract_el_numbers_from_flist(flist)

samplesToLoad = 5;
elNumbers = {};

for i=1:length(flist)
    ntk=initialize_ntkstruct(flist{i});
    [ntk2 ntk]=ntk_load(ntk, samplesToLoad,  'images_v1');
    el_numbers{i} = ntk2.el_idx;
    chNumbers{i} = ntk2.channel_nr;
end



end