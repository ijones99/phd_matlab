function y=check_neurons_by_PCA(sorted_nnn_DS,length_recording,ntk2)


% check_neurons_by_PCA
% sorted_nnn_DS=input neuron
% length_recording=how long is the recording in samples
% ntk2=raw data


%at the moment the funcitons is adapted for light spikes with moving bars.
%it needs to be adapted to sort other different types of recording



neuron=sorted_nnn_DS{1};
fname=neuron.fname;
[v ind]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
max_electrode=neuron.el_idx(ind);

if isempty(ntk2)
siz=length_recording;
ntk=initialize_ntkstruct(fname{1},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');
ntk2=detect_valid_channels(ntk2,1)
ntk2=cut_ntk2_bars(ntk2,length(ntk2.sig)); 
%figure;plot(ntk2.images.frameno)
%figure;plot_recording_blocks(flist(k));
else
ntk2=ntk2
end

% INFO
info=cell(1,8);
info{1,1}='ND:1';
info{1,2}='CONFIG:6x17sp0';
info{1,3}='SPEED:800um/s';    % 'MARCHING BLOCKS U->D'
info{1,4}='BAR WIDTH: 800 um'; % 'BAR WIDTH: 200 um'
info{1,5}='COLOR BAR: BLU+GREEN LED AT 255';
info{1,6}='CONTRAST: 100%';
info{1,7}=[270,90,0,180,225,45,315,135];  % 'OVERLAP: 100 um'
info{1,8}='10 S BETWEEN REPETITIONS';   % '10 S BETWEEN EACH MARCHING BAR'
ntk2.light_info=info %stimulus info

% SELECT ALL ELECTRODES WITH INCREASING IDX

[B XI]=sort(ntk2.el_idx);
ch_idx=XI;

p.pretime=18;
p.posttime=22;
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


%%
electrode=find(B==max_electrode);
i=electrode;
thr_f=4;
working.sig=ntk2.sig;
temp_neurons=cell(0,0); 

temp_neur=cut_events_create_nnn(ntk2,i,thr_f,event_param.pre2,event_param.post2,1);
temp_neur=realign_traces(temp_neur,'best_n',1);
temp_neur=reextract_aligned_traces(temp_neur,working);
[spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'active_only','do_plot','best_n',5);    
splitted2=spl_neurs;
indici_deleted=[];
for i=1:length(spl_neurs)
    if length(spl_neurs{i}.ts)<5
       splitted2{i}=[];
       fprintf('deleted cluster number')
       i
       indici_deleted=[indici_deleted i];
    end
     if length(spl_neurs{i}.ts)>=5
     splitted2{i}.id_cl=i;
     end
end
splitted2(indici_deleted)=[];
splitted2=analyze_and_correct_clusters(splitted2,'interactive',1);
splitted2=merge_neurons(splitted2,'interactive',1,'no_isi');   
sorted_nnn_PCA=plot_RGCs_bar_response(splitted2,'interactive'); 

% for i=1:length(splitted2)
% temp_neurons{length(temp_neurons)+1}=splitted2{i};
% end

close all
y=sorted_nnn_PCA;