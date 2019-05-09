function [loadedData ] = ...
    load_timestamps_no_split( tDirName, neurNames )
% [loadedData ] = ...
%     load_timestamps_no_split( tDirName, neurNames )
% Output in 2e4 Hz

flistFileNameID = tDirName; 

% dir names
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);

% frameno file name
framenoFileName = strcat('frameno_', flistFileNameID, '.mat');


% shift timestamps for stimulus frames
% loadedFrameNumbers = shiftframets(frameno);
load(fullfile(dirNameSt, strcat('st_',neurNames,'.mat')));
eval(['loadedData = ',strcat('st_',neurNames,'.ts;')]);

end