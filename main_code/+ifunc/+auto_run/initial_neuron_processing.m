function initial_neuron_processing(flistFileName, stimName, Settings, StimMats, dateVal, varargin)

P.neurIdx = [];
P = mysort.util.parseInputs(P, varargin, 'error');


flist = {};
eval(flistFileName);
if nargin < 5
    dateVal = get_dir_date;
end

% dir names
dirName.net_base = strcat('/net/bs-filesvr01/export/group/hierlemann/recordings/', ...
    'HiDens/SpikeSorting/Roska/',dateVal,'/');
dirName.noise_movie_frames = '/net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Light_Stimuli/Noise_Movies/Noise_Movie';

streamName = ifunc.flists.flist2stream(flist);
dirName.stream = strcat(dirName.net_base,streamName,'/');
suffixName = strrep(flistFileName ,'flist','');
[ suffixName flist flistFileNameID dirName.gp  dirName.st ...
    dirName.el dirName.cl ] = setup_for_ntk_data_loading(flistFileName, suffixName);

% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);

neurNames = extract_neur_names_from_files(dirName.st , '*.mat',...
    'remove_string', '.mat');
if ~isempty(P.neurIdx )
    neurNames = neurNames(P.neurIdx);
end

if strcmp(stimName,'White_Noise')
    [frameno] = load_frameno(flistFileNameID );
    ifunc.sta.calc_and_save_sta(dirName, neurNames , flistFileNameID, hdmea, frameno, ...
        'use_sep_dir', stimName,'structure_name', stimName, 'restrict_spike_number',6000,...
        'restrict_spike_number_lower_res', 1);
elseif strcmp(stimName,'Noise_Movie')
        [frameno] = load_frameno(flistFileNameID );
        ifunc.sta.calc_and_save_sta_noise_movie(dirName, neurNames , flistFileNameID, hdmea, frameno, ...
            'use_sep_dir', stimName,'structure_name', stimName, 'restrict_spike_number',6000,...
            'restrict_spike_number_lower_res', 1);
else
    ifunc.profiles.save_basic_profile(dirName, neurNames,stimName, flistFileNameID, ...
        Settings, StimMats, hdmea,'stimulus_type', stimName);
end
end
