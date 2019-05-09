function overnight_preprocessing(flistGroupsFileName,elInds)
% function:     overnight_preprocessing(flistGroups,elInds)
% Description:  This function is meant to be run as a non gui function. For
%               example:
%                   matlab -nodisplay -r "overnight_preprocessing(flistGroupsFileName,elInds)"
% Arguments
%               flistGroupsFileName: flist names as a vector of cells
%               elInds: range of inds (e.g.[1:20])
% Run Location:
%               must be in Matlab directory of experimental directory
%               structure
% Author:
%               ijones


eval(['load ', flistGroupsFileName]);

numEls = 7; %num els per patch

for iFlistGroup = 1:length(flistGroups) % go through all groups of flists
    flistName = flistGroups{iFlistGroup}; % flist name for current flist group
    suffixName = strrep(flistName,'flist',''); % suffix name for directory labeling
    
    % execute flist file
    flist ={}; eval(flistName);
    flistFileNameID = get_flist_file_id(flist{1}, suffixName);
    
    dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
    dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
    dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
    dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
    elConfigClusterType = 'overlapping';
    
    %% Process Data 
    pre_process_data(suffixName, flistName, 'config_type',elConfigClusterType,'sel_by_inds', elInds)
    
    exit
end