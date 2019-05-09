function [ suffixName flist flistFileNameID dirNameFFile  dirNameSt ...
    dirNameEl dirNameCl ] = setup_for_ntk_data_loading(flistName, suffixName)

% function [ suffixName flist flistFileNameID dirNameFFile  dirNameSt 
... dirNameEl dirNameCl ] = setup_for_ntk_data_loading(flistName, suffixName)
% initially called before loading data

    flist ={}; eval(flistName);
    


flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');

end