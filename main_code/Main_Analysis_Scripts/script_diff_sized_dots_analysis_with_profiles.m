%% Initial setup to run analysis
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
acqFreq = 2e4;
flistName = 'flist_diff_size_dots';
stimName = 'Flashing_Dots';
dirName.figs = '../Figs/';
dirName.sta = strcat('../analysed_data/responses/sta/'); mkdir(dirName.sta);
dirName.prof = '../analysed_data/profiles';
suffixName = strrep(flistName ,'flist','');
[ suffixName flist flistFileNameID dirName.gp  dirName.st ...
    dirName.el dirName.cl ] = setup_for_ntk_data_loading(flistName, suffixName);
tName = strrep(flistFileNameID,suffixName,'');
mkdir(dirName.gp), mkdir(dirName.st)

elConfigClusterType = 'overlapping'; elConfigInfo = get_el_pos_from_nrk2_file;
elConfigInfo = add_ntk2_el_list_order_to_elconfiginfo(flist, elConfigInfo);
save('elConfigInfo.mat', 'elConfigInfo');
stimNames = {'White_Noise', 'Orig_Movie', 'Static_Median_Surround', ...
    'Dynamic_Median_Surround',  'Dynamic_Median_Surround_Shuffled', ...
    'Pixelated_Surround_10_Percent', 'Pixelated_Surround_50_Percent', ...
    'Pixelated_Surround_90_Percent', 'Dots_of_Different_Sizes',...
    'Moving_Bars'};
dirName.base_net = strcat('/net/bs-filesvr01/export/group/hierlemann/recordings/', ...
    'HiDens/SpikeSorting/Roska/',get_dir_date,'/');
streamName = dir(fullfile(dirName.base_net, strcat('*',tName,'*stream')));   
dirName.auto_sorter_gps = fullfile(dirName.base_net,streamName(1).name,'sortings/')
dirName.prof = '../analysed_data/profiles';
dirName.prof_wn = strcat(dirName.prof,stimName);
dirName.qds = strcat(dirName.figs, stimName,'/quality_datasheets/');mkdir(dirName.qds)

%% create frameno file
frameno = get_framenos(flist, acqFreq*60*60);
save(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])), 'frameno');
% save shifted version of frameno
shift_and_save_frameno_info(flistFileNameID); 
%% Prepare H5 File Access and save data
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
%% save basic data
shift_and_save_frameno_info(flistFileNameID);
% extract spike times
extract_spiketimes_from_auto_cluster_files( flistFileNameID, dirName.auto_sorter_gps)
%>> Calculate STA info
load ../../27Nov2012/Matlab/MainFunctions/StimParams_SpotsIncrSize.mat
ifunc.auto_run.initial_neuron_processing('flist_diff_size_dots','Flashing_Dots',...
    Settings, StimMats)
