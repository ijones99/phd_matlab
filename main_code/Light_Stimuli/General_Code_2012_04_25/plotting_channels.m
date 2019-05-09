%% tuitorial

open_tutorial

%% load data

flist = {};
flist_for_analysis;
timeToLoad = 2; %seconds

ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, timeToLoad*20000); 
 signalplotter(ntk2,'chidx',1:20)
 
 
 
 %% plot recording blocks
 plot_recording_blocks(flist,'Experiment 1', 'nolegend')
 
 
 %% activity map
 
 % generate event data
thr_f=4;                    % threshold factor what to detect as event
event_data=hidens_load_events(flist, thr_f);

% plot simple map
hidens_generate_event_map(event_data,'imagesc','legend');
colorbar