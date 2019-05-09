function process_noise_movie(flistName, stimName, dateVal, dirNameStimFrames)

dirName.stim_frames = dirNameStimFrames;

flist ={}; eval(flistName);
suffixName = strrep(flistName ,'flist','');

[ suffixName flist flistFileNameID dirName.gp  dirName.st ...
    dirName.el dirName.cl ] = setup_for_ntk_data_loading(flistName, suffixName);


%%
% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);

%% create frameno file
% to do later: function create frameno file
shift_and_save_frameno_info(flistFileNameID);
% extract spike times
% extract_spiketimes_from_auto_cluster_files( flistFileNameID, dirName.felix_grouping)
%>> Calculate STA info

neurNames = get_neur_names_from_dir(dirName.st, 'st_','remove_prefix');
% selNeurNames = neurNames{1}; clear neurNames; neurNames = selNeurNames;
[framenoInfo] = get_frameno_info(flistFileNameID );
frameno = load_frameno(dirName.gp);
ifunc.sta.calc_and_save_sta_noise_movie(dirName, neurNames , flistFileNameID, hdmea, frameno, ...
    'save_footprint',1,'use_sep_dir', 'noise_Movie_Varying_Contrast', 'structure_name','Noise_Movie_Varying_Contrast');



end
