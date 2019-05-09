function [ntk2 ntk] = init_and_load_ntk(flist, chunkSize)

if iscell(flist)
    ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
else
     ntk=initialize_ntkstruct(flist,'hpf', 500, 'lpf', 3000);
end

[ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'digibits');

end