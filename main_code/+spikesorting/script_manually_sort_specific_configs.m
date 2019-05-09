%% paths
clear
defs = dirdefs();

%% load wn_checkerboard waveform
mainElidx = input('Enter main elidx>> ');
wnClusNo = input('wn cluster no>> ');
wnNeurName = [num2str(mainElidx) 'n' num2str(wnClusNo)];
flist = {};flist_wn_checkerboard_n_01;flist{end+1} = flist;
suffixName = '_wn_checkerboard_n_01';
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
wnCluster = file.load_single_var(dirNameCl,['cl_',num2str(mainElidx)]);
splitmerge_tool_mod(wnCluster)

wnNeurName = [num2str(mainElidx), 'n',num2str(wnClusNo)];
wn_checkerbrd.tsMatrix = load_spiketrains(flistFileNameID,'neur_name',wnNeurName);
wn_checkerbrd.frameno = file.load_single_var(dirNameFFile,sprintf('frameno_%s',flistFileNameID ));
%% spikesort bars
clear flist
suffixName = '_moving_bars_n_01';
flist = {}; flist_moving_bars_n_01;
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');

doSpikesort = input('spikesort bars? >> ','s');
if strcmp(doSpikesort,'y')
    [flistFileNameID flist flistName] = wrapper.proc_and_spikesort_save_data('main_elidx',mainElidx )
    % extract time stamps from sorted files
else
    barsCluster = file.load_single_var(dirNameCl,['cl_',num2str(mainElidx)]);
    wnCluster = file.load_single_var(dirNameCl,['cl_',num2str(mainElidx)]);
    splitmerge_tool_mod(wnCluster)
end
suffixName = '_moving_bars_n_01'
mbClusNo = input('mb cluster no>> ');

extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName );
% load spiketrains

flistFileNameID = get_flist_file_id(flist{1}, suffixName);
spotsNeurName = [num2str(mainElidx) 'n' num2str(mbClusNo)];
mb.tsMatrix = load_spiketrains(flistFileNameID,'neur_name',spotsNeurName);
mb.frameno = get_framenos(flist{1});
mb.flist = flist;

%% spikesort spots

spt.rfRelCtr = input('RF ctr>> ');
runNo = input('run number>> ');
clear flist

% [flistFileNameID flist flistName] = wrapper.proc_and_spikesort_save_data('main_elidx',mainElidx )

doSpikesort = input('spikesort spots? >> ','s');
if strcmp(doSpikesort,'y')
    [flistFileNameID flist flistName] = wrapper.proc_and_spikesort_save_data('main_elidx',mainElidx )
    % extract time stamps from sorted files
else
    suffixName = '_spots_n_01'
    flistFileNameID = get_flist_file_id(flist{1}, suffixName);
    dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
    dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
    dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
    dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
    
    
    barsCluster = file.load_single_var(dirNameCl,['cl_',num2str(mainElidx)]);
    wnCluster = file.load_single_var(dirNameCl,['cl_',num2str(mainElidx)]);
    splitmerge_tool_mod(wnCluster)
end

% extract time stamps from sorted files

% splitmerge_tool_mod(wnCluster)


sptClusNo = input('spt cluster no>> ');
% extract time stamps from sorted files 
suffixName = '_spots_n_01'

extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName );
% load spiketrains
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
spotsNeurName = [num2str(mainElidx) 'n' num2str(sptClusNo)];
spt.tsMatrix = load_spiketrains(flistFileNameID,'neur_name',spotsNeurName);
spt.frameno = get_framenos(flist{1});
spt.flist = flist;


%% create neur struct
expName = get_dir_date;
neur = neur_struct.put_data_into_neur_struct(wn_checkerbrd, spt, mb, runNo, expName)

%% 
doSavePlot = input('save plot? ','s')
spotsSettings = file.load_single_var('settings/', 'stimFrameInfo_spots.mat')
barsSettings = file.load_single_var('settings/', 'stimFrameInfo_movingBar_2Reps.mat')
if strcmp(doSavePlot,'y' )
    neur = response_params_calc.compute_vis_stim_parameters2(neur,...
        spotsSettings, barsSettings,'bar_offset', 300,'plot','save_plot');%,
else
    neur = response_params_calc.compute_vis_stim_parameters2(neur,...
        spotsSettings, barsSettings,'bar_offset', 300,'plot');%,
    
end
%% save
fileName = sprintf('run_%02d_ums%s.mat',runNo, wnNeurName )
save(fullfile(defs.neuronsSaved,expName,fileName ), 'neur')
