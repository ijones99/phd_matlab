%% load data and plot channels
tic


temp_neurons=cell(0,0);
flist={};
flist_for_analysis; %flist
k=1; % file number
%minutes to load
minutesToLoad =2/6;
siz=20000*60*minutesToLoad; % frames to load
loadAllChannels = 1 ;
doPlot          = 1;
number_els=1 %surrounding

if loadAllChannels
    if minutesToLoad > 5
        disp('It will take some time to load this data. Cancel now if necessary')
        pause
    end
    ntk=initialize_ntkstruct(flist{k},'hpf', 500, 'lpf', 3000);
    [ntk2 ntk]=ntk_load(ntk, siz, 'images_v1'); % images_v1 argument to load ts of image
    ntk2=detect_valid_channels(ntk2,1); % remocmosmea_recordingsve bad channels and compute the noise levels
    %no filtering --> [ntk2 ntk]=ntk_load(ntk, siz, 'nofiltering');
    ntk2ChannelLookup.el_idx = ntk2.el_idx;
    ntk2ChannelLookup.channel_nr = ntk2.channel_nr;
    save ntk2ChannelLookup ntk2ChannelLookup
else
    electrodeOfInterest = 6895;
    load electrode_list;
    load ntk2ChannelLookup;
    ntk=initialize_ntkstruct(flist{k},'hpf', 500, 'lpf', 3000);
    %use convertelectrodestochannels to determine which elecrodes to enter,
    %given one electrode of interest.

    
    surroundingElectrodes = convertelectrodestochannels(electrodeOfInterest, electrode_list, ntk2ChannelLookup, number_els)
    [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only', surroundingElectrodes, 'images_v1');
    ntk2=detect_valid_channels(ntk2,1); % remocmosmea_recordingsve bad channels and compute the noise levels
end


[B XI]=sort(ntk2.el_idx);
ch_idx=XI;

% plot all channels ordered from top to bottom of config
if doPlot
    figure; signalplotter(ntk2,'elidx',[B(1:20)], 'samples', 1:length(ntk2.sig));
    figure; signalplotter(ntk2,'elidx',[B(21:40)], 'samples', 1:length(ntk2.sig));
    figure; signalplotter(ntk2,'elidx',[B(41:60)], 'samples', 1:length(ntk2.sig));
    figure; signalplotter(ntk2,'elidx',[B(61:80)], 'samples', 1:length(ntk2.sig));
    figure; signalplotter(ntk2,'elidx',[B(81:length(B))], 'samples', 1:length(ntk2.sig));
end

% hack, with this function "reextract_aligned_traces" crashes...to be fixed
ntk2.frame_no=[];
ntk2.frame_no=[1:length(ntk2.sig)];
toc
%% FIND ELECTRODES
% here we compute the matrix with the n closest electrodes for every electrode in the list

x = ntk2.x(XI);
y = ntk2.y(XI);
xx=ntk2.x(XI);
yy=ntk2.y(XI);
electrodes=B;

min_dist =[+Inf];
number_els = 4;
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

save electrode_list electrode_list
%% Cluster and merge data
tic
electrodeListIndex=find(electrode_list(:,1)==electrodeOfInterest);

% ---------------- info about the recording ---------------- %
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

% ---------------- Parameters for cutting traces ---------------- %

p.pretime=13; % how much to cut before thr is passed
p.posttime=22; % how much to cut after thr is passed
thr_f=3; % threshold to cut
% ntk2.thr_base = thr_f;
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

% init electrode index variables
for ii = 1:number_els+1
    eval(['electrodeIndex',num2str(ii),'=[];']);
end

% electrode index values
for ii = 1:number_els+1
    eval(['electrodeIndex',num2str(ii),'=find(ntk2.el_idx==electrode_list(electrodeListIndex,',num2str(ii), ')) ;']);
end

working.sig=ntk2.sig;

for z=1:length(electrodeOfInterest);
    fprintf('................ z loop: # %d / %d ................ \n', z , length(electrodeOfInterest));
    electrode=find(B==electrodeOfInterest(z));
    i=electrode;

% find electrode index (for ntk2 file structure)
electrodeIndex=find(ntk2.el_idx==electrodeOfInterest(z));

% ----------------- Cut events and create cluster structure ----------------- %
disp('enter cut_events_create_nnn.m')
temp_neur=cut_events_create_nnn(ntk2,i,thr_f,event_param.pre2,event_param.post2,1);

% ----------------- realign traces using cross-covariance ----------------- %
disp('enter realign_traces.m')
temp_neur=realign_traces(temp_neur,'best_n',1);

% ----------------- PCA ----------------- %
% (number_els refers to # neighboring els)
if number_els == 4
    if  ~isempty(electrodeIndex1) && isempty(electrodeIndex2) && isempty(electrodeIndex3) && isempty(electrodeIndex4) && isempty(electrodeIndex5) 
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex,electrodeIndex1]);
    elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && isempty(electrodeIndex3) && isempty(electrodeIndex4) && isempty(electrodeIndex5) 
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2]);
    elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && ~isempty(electrodeIndex3) && isempty(electrodeIndex4) && isempty(electrodeIndex5) 
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2,electrodeIndex3]);
    elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && ~isempty(electrodeIndex3) && ~isempty(electrodeIndex4) && isempty(electrodeIndex5) 
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2,electrodeIndex3,electrodeIndex4]);
    elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && ~isempty(electrodeIndex3) && ~isempty(electrodeIndex4) && ~isempty(electrodeIndex5) 
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2,electrodeIndex3,electrodeIndex4,electrodeIndex5]);
    else
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex]);
    end

elseif number_els == 2
    if  ~isempty(electrodeIndex1) && isempty(electrodeIndex2) && isempty(electrodeIndex3) 
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex,electrodeIndex1]);
    elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && isempty(electrodeIndex3) 
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2]);
    elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && ~isempty(electrodeIndex3)  
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2,electrodeIndex3]);
    else
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex]);
    end

else
    Disp('Error with number of electrodes specified')
end

% remove clusters with less than 5 spikes
sufficientlyActiveClusters=initialCluster;
indici_deleted=[];
for i=1:length(initialCluster)
    if length(initialCluster{i}.ts)<5
       sufficientlyActiveClusters{i}=[];
       fprintf('deleted cluster number')
       i;
       indici_deleted=[indici_deleted i];
    end
     if length(initialCluster{i}.ts)>=5
     sufficientlyActiveClusters{i}.id_cl=i;
     end
end
sufficientlyActiveClusters(indici_deleted)=[];
sufficientlyActiveClusters=analyze_and_correct_clusters(sufficientlyActiveClusters,'interactive',1);
% merge neurons
sufficientlyActiveClusters=merge_neurons(sufficientlyActiveClusters,'interactive',1,'no_isi'); 

end
toc

%% Plot data 
% close all

sorted_nnn=sufficientlyActiveClusters;

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