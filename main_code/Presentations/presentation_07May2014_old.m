%% Presentation on 07 May, 2014
% open fig of sta from WN_CHECKERBOARD stim
open ../Figs/30Apr2014_sta_wn_checkerboard_n_02_clus_6387n54.fig

% open spike struct of s.sort data
load ../analysed_data/T14_29_11_34_wn_checkerboard_n_02/01_Pre_Spikesorting/el_6387.mat

% FOUND: 6387n54

%% s.sort MARCHING SQR, MOVING BARS, SPOTS
% [flistFileNameID flist flistName] = wrapper.proc_and_spikesort_save_data('sel_by_inds', [10 6] )
% 
[flistFileNameID flist flistName] = wrapper.proc_and_spikesort_save_data()
% FOUND: wn_chckrbrd = 6387n54; marching_sqr=n132; moving_bars=n60,
% spots=n22

%% spikesorting

runNo = input('Enter run no >> ');
flistName = sprintf('flist_marching_sqr_n_%02d',runNo);
flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')

sortChoice = input('spikesort? [y/n]','s')
if strcmp(sortChoice,'y')
    fileType = 'mat';
    elNumbers = compare_files_between_dirs(dirNameEl, dirNameCl, fileType, flist)
    selInds = input(sprintf('sel inds of el numbers to sort [1:%d]> ',length(elNumbers)));
    sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_els_in_dir', ...
        elNumbers(selInds))%elNumbers([1:10]+10*(segmentNo-1))); %'sel_els_in_dir',...
%     selEls(end));%'all_in_dir')%;% 'all_in_dir')%); %,
end

%% EXTRACT TIME STAMPS FROM SORTED FILES 
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )
%% LOAD & SAVE FRAMENO INFO
suffixName = input('suffixName = >> ','s');
flist = {}; eval(sprintf('flist%s',suffixName));
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
framenoName = strcat('frameno_', flistFileNameID,'.mat');
if ~exist(fullfile(dirNameFFile,framenoName))
    frameno = get_framenos(flist);
    save(fullfile(dirNameFFile,framenoName),'frameno');
else
    load(fullfile(dirNameFFile,framenoName)); frameInd = single(frameno);
end
%% get framenos & timestamps for marching square 
% 16 positions, 10 repeats, 2 directions (320 segments)
dirName.marchSqr = '../analysed_data/T14_29_11_35_marching_sqr_n_02/';
fileName.frameno = 'frameno_T14_29_11_35_marching_sqr_n_02.mat';
% load framenos
frameno.marchSqr = load(fullfile(dirName.marchSqr,fileName.frameno));
frameno.marchSqr  = frameno.marchSqr.frameno;
% load st_ file
fileName.marchSqr = 'st_6387n132';
load(fullfile(dirName.marchSqr,'03_Neuron_Selection',fileName.marchSqr));

% get switch times
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno.marchSqr,interStimTime); 
% get location data
stMatrix.ts = eval(sprintf('%s.ts;',fileName.marchSqr));
selectSegment = 1:320;
framenoSeparationTimeSec = 0.5;

eval(sprintf('spikeTrainsConcatenated = round(%s.ts*2e4);',fileName.marchSqr));
adjustToZero = 1;
spikeTrains = extract_spiketrain_repeats_to_cell(spikeTrainsConcatenated, ...
    stimChangeTs,adjustToZero)
%% analyze moving bars
% get framenos (144)
dirName.marchSqr = '../analysed_data/T14_29_11_36_moving_bars_n_02/';
fileName.frameno = 'frameno_T14_29_11_36_moving_bars_n_02.mat';
% load framenos
frameno.marchSqr = load(fullfile(dirName.marchSqr,fileName.frameno));
frameno.marchSqr  = frameno.marchSqr.frameno;
% load st_ file
fileName.marchSqr = 'st_6387n60';
load(fullfile(dirName.marchSqr,'03_Neuron_Selection',fileName.marchSqr));

% get switch times
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno.marchSqr,interStimTime); 
% get location data
stMatrix.ts = eval(sprintf('%s.ts;',fileName.marchSqr));
selectSegment = 1:320;
framenoSeparationTimeSec = 0.5;

eval(sprintf('spikeTrainsConcatenated = round(%s.ts*2e4);',fileName.marchSqr));
adjustToZero = 1;
spikeTrains = extract_spiketrain_repeats_to_cell(spikeTrainsConcatenated, ...
    stimChangeTs,adjustToZero)
% get switch times

% get location data

%% spots (60)
% get framenos
clusterNo = 22;
dirName.spots = '../analysed_data/T14_29_11_39_spots_n_02/';
fileName.frameno = 'frameno_T14_29_11_39_spots_n_02.mat';
% load framenos
frameno.spots = load(fullfile(dirName.spots,fileName.frameno));
frameno.spots  = frameno.spots.frameno;
% load st_ file
fileName.spots = sprintf('st_6387n%d',clusterNo);
load(fullfile(dirName.spots,'03_Neuron_Selection',fileName.spots));

% get switch times
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno.spots,interStimTime); 
% get location data
stMatrix.ts = eval(sprintf('%s.ts;',fileName.spots));
framenoSeparationTimeSec = 0.5;

eval(sprintf('spikeTrainsConcatenated = round(%s.ts*2e4);',fileName.spots));
adjustToZero = 1;
spikeTrains = extract_spiketrain_repeats_to_cell(spikeTrainsConcatenated, ...
    stimChangeTs,adjustToZero)





