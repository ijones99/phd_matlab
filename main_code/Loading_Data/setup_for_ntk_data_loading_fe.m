function [ suffixName flist flistFileNameID dirNameFFile  dirNameSt ...
    dirNameEl dirNameCl ] = setup_for_ntk_data_loading_fe(flistName, suffixName, expDate)

% function [ suffixName flist flistFileNameID dirNameFFile  dirNameSt 
... dirNameEl dirNameCl ] = setup_for_ntk_data_loading(flistName, suffixName)
% initially called before loading data

flist ={}; eval(flistName);
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
baseRoskaDir = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/';
dirNameFFile = strcat(baseRoskaDir, expDate,'/analysed_data/',   flistFileNameID);
dirNameSt = strcat(baseRoskaDir, expDate,'/analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat(baseRoskaDir, expDate,'/analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat(baseRoskaDir, expDate,'/analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');

end