
%% gen flist

cd ~/bel.svn/hima_internal/cmosmea_recordings/trunk/jaeckeld/2013_05_22_scan_before_patch_lipo/Matlab
clear all
flist_scan;

% addpath /net/bs-sw/sw-repo/hierlemann/hidens/14154/matlab/mex_ntkparser/20120820R2012a/

% plot recording blocks
figure
plot_recording_blocks(flist,'Experiment 1', 'nolegend', 'dontsave')

% rmpath /net/bs-sw/sw-repo/hierlemann/hidens/14154/matlab/mex_ntkparser/20120820R2012a/

%%
%

addpath /net/bs-sw/sw-repo/hierlemann/hidens/14154/matlab/mex_ntkparser/20120820R2012a/

CHUNKSIZ=90*20000; % 30s
thr_f=5.5; % threshold factor what to detect as event
event_data_all=hidens_load_events(flist, thr_f,'chunk',CHUNKSIZ,'maxtime',120);

save computed_results/event_data_all event_data_all
rmpath /net/bs-sw/sw-repo/hierlemann/hidens/14154/matlab/mex_ntkparser/20120820R2012a/

% load computed_results/event_data_all

%% error in block 48

for i=1:length(flist)
        
        siz = 10000; % how many samples of data to load (5 s)
        ntk=initialize_ntkstruct(flist{i}, 'hpf', 500, 'lpf', 3000);
        [ntk2 ntk]=ntk_load(ntk, siz);
        if size(ntk2.sig,1)==10000
                errored(i)=0;
            else
                errored(i)=1;
            end
end
%%

%% event map

figure;
% hidens_generate_amplitude_map(event_data_all,'do_use_max')
hidens_generate_amplitude_map(event_data_all)
colormap hot
hold on
hidens_generate_event_map(event_data_all,'no_new_fig', 'freqthr', 0.1, 'markerplot',...
        'MarkerSize',4, 'border', 15,'markerplotfreq', 'legend' );
%
hold on
plot_recording_blocks(flist,'Experiment 1', 'nolegend', 'dontsave')


%%
siz = 200000; % how many samples of data to load (5 s)
ntk=initialize_ntkstruct(flist{37}, 'hpf', 500, 'lpf', 3000,'use_local_filters');
[ntk2 ntk]=ntk_load(ntk, siz);
ntk2=detect_valid_channels(ntk2,1);

%%

figure;
hidens_generate_amplitude_map(event_data_all,'do_use_max')
hold on
hidens_generate_event_map(event_data_all,'no_new_fig', 'freqthr', 0.1, 'markerplot',...
    'MarkerSize',4, 'border', 15,'markerplotfreq', 'legend' );
plot_electrode_map(ntk2)

%%

SAMPL=1:length(ntk2.sig(:,1));
figure;
signalplotter(ntk2, 'samples', SAMPL, 'separate','chidx',[23 17 14 21 20 84 64 19]);

pretime=32;
posttime=30;
pca_neurs=PCA_sorter(ntk2, [12], 6, pretime, posttime, 1)

plot_neurons(pca_neurs,'separate_subplots','allactive','chidx')

%% display neuron in NR

nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
plot_neurons(pca_neurs,'chidx','nolegend','xmin',0, 'ymin',0)


%%

SAMPL=1:length(ntk2.sig(:,1));
figure;
signalplotter(ntk2, 'samples', SAMPL, 'separate');

%%

SAMPL=1:length(ntk2.sig(:,1));
figure;
signalplotter(ntk2, 'samples', SAMPL, 'separate','chidx',[36]);

pretime=32;
posttime=30;
pca_neurs=PCA_sorter(ntk2, [69], 6, pretime, posttime, 1)


%%
figure;
% hidens_generate_amplitude_map(event_data_all,'do_use_max')
% hidens_generate_amplitude_map(event_data_all)
colormap hot
hold on
hidens_generate_event_map(event_data_all,'no_new_fig', 'freqthr', 0.1, 'markerplot',...
        'MarkerSize',4, 'border', 15,'markerplotfreq', 'legend' );
plot_electrode_map(ntk2)

%%

v_thr=100;
min_spikes=5;
axonal_el=zeros(size(event_data_all.event_map.max));

for i=1:length(event_data_all.event_map.max)
        if length(find(event_data_all.event_map.max{i}>v_thr))>min_spikes
               axonal_el(i)=1;
            end
end