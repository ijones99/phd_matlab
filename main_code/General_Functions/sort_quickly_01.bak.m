%% Essentially the same as the original, although a little modified for my
%% purposes. ijones

%% load data and plot channels

temp_neurons=cell(0,0)
flist={};

flist_example2; %flist
k=1; % file number
siz=20000*11; % number of frames to load
ntk=initialize_ntkstruct(flist{k},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1'); % images_v1 argument to load ts of image
%no filtering --> [ntk2 ntk]=ntk_load(ntk, siz, 'nofiltering');

ntk2=detect_valid_channels(ntk2,1); % remocmosmea_recordingsve bad channels and compute the noise levels

[B XI]=sort(ntk2.el_idx);
ch_idx=XI;

% plot all channels ordered from top to bottom of config
figure; signalplotter(ntk2,'elidx',[B(1:20)], 'samples', 1:length(ntk2.sig));
figure; signalplotter(ntk2,'elidx',[B(21:40)], 'samples', 1:length(ntk2.sig));
figure; signalplotter(ntk2,'elidx',[B(41:60)], 'samples', 1:length(ntk2.sig));
figure; signalplotter(ntk2,'elidx',[B(61:80)], 'samples', 1:length(ntk2.sig));
figure; signalplotter(ntk2,'elidx',[B(81:length(B))], 'samples', 1:length(ntk2.sig));


% hack, with this function "reextract_aligned_traces" crashes...to be fixed
ntk2.frame_no=[];
ntk2.frame_no=[1:length(ntk2.sig)];
%% FIND ELECTRODES
% here we compute the matrix with the n closest electrodes for every electrode in the list

number_els=4; %number of closest electrodes

x = ntk2.x(XI);
y = ntk2.y(XI);
xx=ntk2.x(XI);
yy=ntk2.y(XI);
electrodes=B;

min_dist =[+Inf];

close_electrodes=[];
electrode_list=zeros(length(ntk2.x),number_els+1);

for i=1:length(ntk2.x)


    p1 = 1;
    for p2 = 2:length(ntk2.x)
        d = sqrt((x(p1)-x(p2))^2+(y(p1)-y(p2))^2);
        min_dist = [min_dist d];
     end

close_electrodes=[electrodes(p1)];
for j=1:number_els
[val ind]=min(min_dist);
close_electrodes=[close_electrodes   electrodes(ind)];
min_dist(ind)=+Inf;
end

electrode_list(i,:)=close_electrodes;
close_electrodes=[];
min_dist=[];
min_dist =[+Inf];
x=xx([ i+1:end 1:i ]);
y=yy([ i+1:end 1:i ]);
electrodes=B([ i+1:end 1:i ]);
end


%% Cut THE CHANNEL

electrode_of_interest=4448 ;

iii=find(electrode_list(:,1)==electrode_of_interest);

% info about the recording
info=cell(1,8);
info{1,1}='ND:10';
info{1,2}='CONFIG: 6x17';
info{1,3}='SPEED:800 um/s';  
info{1,4}='BAR WIDTH: 400 um';
info{1,5}='COLOR BAR: BLU+GREEN LED AT 255';
info{1,6}='CONTRAST: 100%';
info{1,7}=[270,90,0,180,225,45,315,135];  
info{1,8}='5 S BETWEEN REPETITIONS';  
ntk2.light_info=info %stimulus info

% parameters to cut traces
p.pretime=13; % how much to cut before thr is passed
p.posttime=22; % how much to cut after thr is passed
thr_f=3; % threshold to cut
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


electrode_for_sorting1=[];
electrode_for_sorting2=[];
electrode_for_sorting3=[];
electrode_for_sorting4=[];
electrode_for_sorting5=[];

elettrodi=[electrode_list(iii,1)];
electrode_for_sorting1=find(ntk2.el_idx==electrode_list(iii,2)) ;
electrode_for_sorting2=find(ntk2.el_idx==electrode_list(iii,3)) ;
electrode_for_sorting3=find(ntk2.el_idx==electrode_list(iii,4)) ;
% electrode_for_sorting4=find(ntk2.el_idx==electrode_list(iii,5)) ;
working.sig=ntk2.sig;

for z=1:length(elettrodi);
   
electrode=find(B==elettrodi(z));
i=electrode;
electrode_for_sorting=find(ntk2.el_idx==elettrodi(z));

% cut and align
temp_neur=cut_events_create_nnn(ntk2,i,thr_f,event_param.pre2,event_param.post2,1);
temp_neur=realign_traces(temp_neur,'best_n',1);
temp_neur=reextract_aligned_traces(temp_neur,working);

% pca
if  ~isempty(electrode_for_sorting1) & isempty(electrode_for_sorting2) & isempty(electrode_for_sorting3) & isempty(electrode_for_sorting4) & isempty(electrode_for_sorting5) 
[spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1]);
elseif ~isempty(electrode_for_sorting1) & ~isempty(electrode_for_sorting2) & isempty(electrode_for_sorting3) & isempty(electrode_for_sorting4) & isempty(electrode_for_sorting5) 
[spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1,electrode_for_sorting2]);
elseif ~isempty(electrode_for_sorting1) & ~isempty(electrode_for_sorting2) & ~isempty(electrode_for_sorting3) & isempty(electrode_for_sorting4) & isempty(electrode_for_sorting5) 
[spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1,electrode_for_sorting2,electrode_for_sorting3]);
elseif ~isempty(electrode_for_sorting1) & ~isempty(electrode_for_sorting2) & ~isempty(electrode_for_sorting3) & ~isempty(electrode_for_sorting4) & isempty(electrode_for_sorting5) 
[spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1,electrode_for_sorting2,electrode_for_sorting3,electrode_for_sorting4]);
elseif ~isempty(electrode_for_sorting1) & ~isempty(electrode_for_sorting2) & ~isempty(electrode_for_sorting3) & ~isempty(electrode_for_sorting4) & ~isempty(electrode_for_sorting5) 
[spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1,electrode_for_sorting2,electrode_for_sorting3,electrode_for_sorting4,electrode_for_sorting5]);
else
[spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting]);
end

% remove clusters with less than 5 spikes
splitted2=spl_neurs;
indici_deleted=[];
for i=1:length(spl_neurs)
    if length(spl_neurs{i}.ts)<5
       splitted2{i}=[];
       fprintf('deleted cluster number')
       i;
       indici_deleted=[indici_deleted i];
    end
     if length(spl_neurs{i}.ts)>=5
     splitted2{i}.id_cl=i;
     end
end
splitted2(indici_deleted)=[];
splitted2=analyze_and_correct_clusters(splitted2,'interactive',1);
% merge neurons
splitted2=merge_neurons(splitted2,'interactive',1,'no_isi'); 

end

%% PLOT 
% close all

sorted_nnn=splitted2;

%raster plot
for jjj=1:length(sorted_nnn);

scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)])
subplot(3,3,[1,2,3])
t=(sorted_nnn{jjj}.ts)/20000;
for j=1:length(t)
line([t(j) t(j)],[0.9 0.7],'Color', 'k','LineWidth',1);
end
ylim([0 1.5])
%xlim([(min(t))-0.5 (max(t))+0.5])
xlim([0 length(ntk2.sig)/20000])
xlabel('time [s]','Fontsize',18)
title('Raster Plot','Fontsize',18);
set(gca,'FontSize',18);
set(gca,'YTickLabel',{})
hold on
width=0.5;
limit=length(ntk2.sig)/20000;
edges=[0:width:limit];
psth=zeros(length(edges),1); 
psth = histc(t, edges)';
psth=(psth/width);
max_firing_rate=max(psth);
psth=((psth/max_firing_rate)/10)+1;
plot(edges,psth,'k','LineWidth',2,'Color', 'k');
line([1 1],[1.15 1.25],'Color','k','LineWidth',2);
text(1.2,1.15,[int2str(max_firing_rate) ,' Hz'],'FontSize',16,'fontweight','b')



subplot(3,3,[4 7]);
%isi
sr=20000;
ts=sorted_nnn{jjj}.ts/sr*1000;
isi=diff(sort(ts));
maxt=50;
isi=isi(isi<maxt);
x=0:0.1:50;
hist(isi,x)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','k');
ylabel('Counts','Fontsize',18);
xlabel('Interspike interval [ms]','Fontsize',18)
title('Interspike Interval Histogram','Fontsize',18);
xlim([0 50]);
%ylim([0 50]);
set(gca,'FontSize',18);

subplot(3,3,[5 8]);
%plot traces
neuron=sorted_nnn{jjj};
[v ind]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
plot((1:size(get_aligned_traces(sorted_nnn{jjj}, sorted_nnn{jjj}.event_param.pre2, sorted_nnn{jjj}.event_param.post2, ind)))/20,get_aligned_traces(sorted_nnn{jjj}, sorted_nnn{jjj}.event_param.pre2, sorted_nnn{jjj}.event_param.post2, ind),'Color','k')
set(gca,'FontSize',18);
ylabel('Amplitude [\muV]','Fontsize',18)
xlabel('time [ms]','Fontsize',18)
ylim([min(min(sorted_nnn{jjj}.trace{ind}.data))-10 max(max(sorted_nnn{jjj}.trace{ind}.data))+10])
title(['Spikes at el. ',int2str(neuron.el_idx(ind))],'Fontsize',18);


subplot(3,3,[6,9]);plot_neurons(sorted_nnn,'neurons',[jjj],'nolegend','width',2,'elidx','color','k','allactive');
set(gca,'FontSize',18);
xlabel('X [\mum]','Fontsize',18);
ylabel('Y [\mum]','Fontsize',18);
title('RGCs Footprints','Fontsize',18);



end