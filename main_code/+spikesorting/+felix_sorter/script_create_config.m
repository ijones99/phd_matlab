configsNew.flistidx = [1:15];

%%
configsNew.info{1} = 'wn_checkerboard';
configsNew.info{2} = 'marching_sqr';
configsNew.info{3} = 'moving_bars';
for i=4:15
    configsNew.info{i} = sprintf('spots_%02d',i-3);
end

%%
for i=1:15
    configsNew.name{i} = sprintf('config %d',i);
end

%%
flistNew(end+1:end+10) = flist
%%
configsNew(2).flistidx = [16:25];
%%
configsNew(2).info{1} = 'wn_checkerboard';
configsNew(2).info{2} = 'marching_sqr';
configsNew(2).info{3} = 'moving_bars';
for i=13:19
    configsNew(2).info{i-9} = sprintf('spots_%02d',i);
end

%%
for i=16:25
    configsNew(2).name{i-15} = sprintf('config %d',i);
end
