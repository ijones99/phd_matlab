dirList = ifunc.dir.create_dir_list
cd(dirList.belsvn{6})


[flistNames stimNames]=ifunc.name.get_standard_stimulus_names
for i=[4 5 7], 
    fileStat = exist(sprintf('%s.m',flistNames{i}));
    fprintf('%s.m = %d\n',flistNames{i},i>0)

end

