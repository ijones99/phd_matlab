% script run electrical stimulation scripts

% STEP) pairing -> get stim electrode & readout electrode

% STEP) make movie
% - run script_create_axon_propagation_movie_3.m

%% STEP) open NeuroRouter ON OUR SERVERS
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)

%% STEP) plot image in NeuroRouter ON OUR SERVERS
imX = [ 0.1674    1.9170]*1000;
imY = [ 0.0932    2.1010 ]*1000;
imagesc(imX, imY, maxZDiff);

%% STEP) select electrodes under the footprint ON OUR SERVERS
% 1) route electrodes
% 2) copy config files, nrconfig.mat file to local computer

configInfo = load('../Configs/test2.nrconfig.mat'); % this file can be reloaded 
% to see channel numbers
stimChannels = configInfo.configList.routedReadOutChannels(find(ismember(...
    configInfo.configList.routedIdx,configInfo.configList.stimElIdx)));
%% STEP) stimulate electrodes along cell 
% script_stimulation_at_diff_electrodes.m











