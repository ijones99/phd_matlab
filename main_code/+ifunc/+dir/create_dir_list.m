function dirList = create_dir_list

dirBase.belsvn = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';
dirBase.net = '/net/bs-filesvr01/export/group/hierlemann/recordings/HiDens/Roska';


% dir names
dirNameShort = {};
dirNameShort{1} = '20Dec2012/';
dirNameShort{end+1} = '13Dec2012_2/';
dirNameShort{end+1} = '13Dec2012/';
dirNameShort{end+1} = '27Nov2012/';
dirNameShort{end+1} = '30Oct2012/';
dirNameShort{end+1} = '21Aug2012/';
dirNameShort{end+1} = '10Apr2013/';
% init
dirList.belsvn = {}; dirList.net = {};

for i=1:length(dirNameShort)
    dirList.belsvn{i} = fullfile(dirBase.belsvn,dirNameShort{i},'Matlab/');
    dirList.net{i} = fullfile(dirBase.net,dirNameShort{i},'Matlab/');
    dirList.profiles{i} = fullfile(dirBase.belsvn,dirNameShort{i},'analysed_data/profiles/');
end

end