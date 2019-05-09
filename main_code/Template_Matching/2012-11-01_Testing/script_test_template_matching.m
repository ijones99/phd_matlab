% Orig/Stat Surr	
% neuron 4638n175           

%% go to directory
cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/21Aug2012/Matlab

%% load settings
numEls = 7; 
% suffixName = '_orig_stat_surr';
suffixName = '_orig_stat_surr';
flistName = 'flist_orig_stat_surr'
flist ={}; eval(flistName);
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
elConfigClusterType = 'overlapping';
% if exist('GenFiles/elConfigInfo.mat','file')
%     load GenFiles/elConfigInfo.mat
% end
elConfigInfo = get_el_pos_from_nrk2_file;

%% load timestamps
load ../analysed_data/T13_40_28_0_orig_stat_surr/03_Neuron_Selection/st_4638n175.mat
timestamps = st_4638n175.ts;

%% plot waveform
load ../analysed_data/T13_40_28_0_orig_stat_surr/02_Post_Spikesorting/cl_4638.mat
splitmerge_tool(cl_4638)

%% load raw data
minsToLoad = 1;
siz=minsToLoad*60*2e4;
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');

chIndsToKeep = el_4638.channel_nr;
[ntk2 ntk]=ntk_load(ntk, siz, 'keep_only', chIndsToKeep,  'images_v1');