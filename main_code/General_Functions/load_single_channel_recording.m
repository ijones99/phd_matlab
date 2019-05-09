clear all
close all

flist={};
flist_white_noise;

i=1;



ntk=initialize_ntkstruct(flist{i});
[ntk2 ntk]=ntk_load(ntk, 60*60*20000, 'keep_only', [1 2 3 4 5 6 7 8], 'images_v1');


