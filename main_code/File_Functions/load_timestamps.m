function [loadedData ] = ...
    load_timestamps( suffixName, neurNames )

flistName = strcat('flist',suffixName);
flist ={}; eval(flistName);
flistFileNameID = get_flist_file_id(flist{1}, suffixName);

% dir names
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);

% frameno file name
framenoFileName = strcat('frameno_', flistFileNameID, '.mat');


% shift timestamps for stimulus frames
% loadedFrameNumbers = shiftframets(frameno);

% get timestamps
selNeuronInds = get_file_inds_from_neur_names(dirNameSt, '*.mat', neurNames);
loadedData  = get_tsmatrix(flistFileNameID, 'sel_by_ind', selNeuronInds);
selNeuronInds
end