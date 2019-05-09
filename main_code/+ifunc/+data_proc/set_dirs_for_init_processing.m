function [dirName suffixName flist flistFileNameID streamName tName]= ...
    set_dirs_for_init_processing(flistName, stimName)

fprintf('Setting directories....\n');

%% Initial setup to run analysis
acqFreq = 2e4;
dirName.figs = '../Figs/';
dirName.sta = strcat('../analysed_data/responses/sta/'); mkdir(dirName.sta);
suffixName = strrep(flistName ,'flist','');
[ suffixName flist flistFileNameID dirName.gp  dirName.st ...
    dirName.el dirName.cl ] = setup_for_ntk_data_loading(flistName, suffixName);
tName = strrep(flistFileNameID,suffixName,'');
dirName.base_net = strcat('/net/bs-filesvr01/export/group/hierlemann/recordings/', ...
    'HiDens/SpikeSorting/Roska/',get_dir_date,'/');
streamName = dir(fullfile(dirName.base_net, strcat('*',tName,'*stream*')));   
dirName.auto_sorter_gps = fullfile(dirName.base_net,streamName(1).name,'sortings/');
dirName.prof = '../analysed_data/profiles';
dirName.prof_wn = strcat(dirName.prof,'/',stimName);
dirName.qds = strcat(dirName.figs, stimName,'/quality_datasheets/');mkdir(dirName.qds);





end