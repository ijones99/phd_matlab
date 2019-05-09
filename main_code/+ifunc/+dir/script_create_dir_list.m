% create directory structure

dirBase.belsvn = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';
dirBase.net = '/net/bs-filesvr01/export/group/hierlemann/recordings/HiDens/Roska';

% dir names
dirNameShort{1} = '20Dec2012/';
dirNameShort{end+1} = '13Dec2012_2/';
dirNameShort{end+1} = '13Dec2012/';
dirNameShort{end+1} = '27Nov2012/';
dirNameShort{end+1} = '30Oct2012/';
dirNameShort{end+1} = '21Aug2012/';

% init
dirList.belsvn = {}; dirList.net = {};

for i=1:length(dirNameShort)
    dirList.belsvn{i} = fullfile(dirBase.belsvn,'20Dec2012/');
    dirList.net{i} = fullfile(dirBase.belsvn,'20Dec2012/');
end