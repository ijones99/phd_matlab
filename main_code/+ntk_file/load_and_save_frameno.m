function frameno = load_and_save_frameno()
% frameno = load_and_save_frameno()

runNo = input('Enter run no >> ');
stimNames = { ...
    'wn_checkerboard';...
    'marching_sqr_and_moving_bars'; ...
    'spots'; ...
    };

for i=1:length(stimNames)
    fprintf('(%d) %s\n', i, stimNames{i});
end
selStimName = input('Select stimulus name from above >> ');
suffixName = sprintf('%s_n_%02d',stimNames{selStimName},runNo);
% make flist
flistName = sprintf('flist_%s',suffixName);
[flist stimName ] = make_flist_select([flistName,'.m']);
flistFileNameID = get_flist_file_id(flist{1});
dirNameFFile = strcat('../analysed_data/',   [flistFileNameID,'_',stimName]);
framenoName = strcat('frameno_', flistFileNameID,'_', suffixName, '.mat');
if ~exist(fullfile(dirNameFFile,framenoName))
    frameno = get_framenos(flist);
    save(fullfile(dirNameFFile,framenoName),'frameno');
else
    load(fullfile(dirNameFFile,framenoName)); frameInd = single(frameno);
end

end