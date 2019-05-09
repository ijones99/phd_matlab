clear all 
close all
cd /nas/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/4Aug2010_DSGCs/Matlab
flist={};
flist_white_noise;

kk=1;
siz=1200000;
ntk=initialize_ntkstruct(flist{kk},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');
ntk2=detect_valid_channels(ntk2,1)
[B XI]=sort(ntk2.el_idx);
ch_idx=XI;
%%
p.pretime=10;
p.posttime=13;
event_param=[];
event_param.pre2=p.pretime;
event_param.post2=p.posttime;
event_param.tlen2=event_param.pre2+event_param.post2;
event_param.pre1=floor(event_param.pre2*3/4);
event_param.post1=floor(event_param.post2*2/3);
event_param.tlen1=event_param.pre1+event_param.post1;
event_param.margin=30;
event_param.t_min_isi=20;
event_param.realign_pre=8;
event_param.realign_post=8; %2;
event_param.cut_tshift=6;

elettrodi=[4871];
thr_f=3;
working.sig=ntk2.sig;
temp_neurons=cell(0,0)
%%
for z=1:length(elettrodi);
    
    
electrode=find(B==elettrodi(z));
i=electrode;
electrode_for_sorting=find(ntk2.el_idx==elettrodi(z));
temp_neur=cut_events_create_nnn(ntk2,i,thr_f,event_param.pre2,event_param.post2,1);

temp_neur=realign_traces(temp_neur,'best_n',1);
%temp_neur=reextract_aligned_traces(temp_neur,working);

[spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting])%,find(ntk2.el_idx==5078)]);
splitted2=analyze_and_correct_clusters(spl_neurs,'interactive',1);
splitted2=merge_neurons(splitted2,'interactive',1,'no_isi');   


for i=1:length(splitted2)
temp_neurons{length(temp_neurons)+1}=splitted2{i};
end


close all
end       