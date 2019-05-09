function process_white_noise2(flistName, stimName)

acqFreq = 2e4;
% WHITE NOISE
%stimulus name
% flistName{1} = 'flist_white_noise_checkerboard';stimName{1} = 'white_noise_checkerboard';
% set up directories
[dirName suffixName flist flistFileNameID streamName tName]= ...
    ifunc.data_proc.set_dirs_for_init_processing(flistName,stimName);
% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
[selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);
mkdir(dirName.gp)
frameno = load_frameno(dirName.gp);
save(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])), 'frameno');
% save shifted version of frameno
shift_and_save_frameno_info(flistFileNameID); 
% extract spike times
% extract_spiketimes_from_auto_cluster_files( flistFileNameID, dirName.auto_sorter_gps)
%>> Calculate STA info
neurNames = extract_neur_names_from_files(dirName.st,'*_00*.mat');
% do init processing
neurIdx = 1:length(neurNames);
ifunc.auto_run.initial_neuron_processing(flistName,stimName, [], [], ...
    get_dir_date,'neurIdx', neurIdx)

end