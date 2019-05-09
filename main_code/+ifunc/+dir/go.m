function go(selNum)


dirName{1} = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';
dirName{2} = '/net/bs-filesvr01/export/group/hierlemann/recordings/HiDens/Roska';
dirName{3} = '/net/bs-filesvr01/export/group/hierlemann/recordings/HiDens/SpikeSorting/Roska';

if strcmp(selNum,'m') || selNum == 1
    cd(dirName{1});
    fprintf('%s\n', dirName{1});
elseif strcmp(selNum,'n') || selNum == 2
    cd(dirName{2});
    fprintf('%s\n', dirName{2});
elseif strcmp(selNum,'h') || selNum == 3
    cd(dirName{3});
    fprintf('%s\n', dirName{3});
end


end