for iDir =1:length(dirNames.dataDirLong) % loop through directories
    a = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska';
    b = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Roska'
    dirTo = strrep([dirNames.dataDirLong{iDir},'moving_bar_ds/' ],a,b);
    
    a = 'hierlemann';
    b=  'hierlemann/.zfs/snapshot/2015-06-03_2100';
    dirFrom = strrep([dirTo ],a,b);
    
    eval(sprintf('!rm %sdataOut.mat', dirTo));
    eval(sprintf('!cp %sdataOut.mat %s', dirFrom, dirTo));
end
