clear all
close all
cd /nas/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/26Nov2010_test/Matlab

flist={};
flist_repetitions; 

thr_f=3;

%% load and cut data from 

concatenated_infos=cell(0,0);

for kk=1:length(flist);
siz=3600000;
ntk=initialize_ntkstruct(flist{kk},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');
ntk2=detect_valid_channels(ntk2,1)
ntk2=cut_ntk2_bars(ntk2,length(ntk2.sig));

info=cell(1,8);
info{1,1}='ND:1';
info{1,2}='CONFIG: 6x17';
info{1,3}='SPEED:250um/s';    % 'MARCHING BLOCKS U->D'
info{1,4}='BAR WIDTH: 300 um'; % 'BAR WIDTH: 200 um'
info{1,5}='COLOR BAR: BLU+GREEN LED AT 255';
info{1,6}='CONTRAST: 50%';
info{1,7}=[270,90,0,180,225,45,315,135];  % 'OVERLAP: 100 um'
info{1,8}='6 S BETWEEN REPETITIONS';   % '10 S BETWEEN EACH MARCHING BAR'
ntk2.light_info=info; %stimulus info

[B XI]=sort(ntk2.el_idx);
ch_idx=XI;

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


% FIND ELS

x = ntk2.x(XI);
y = ntk2.y(XI);
xx=ntk2.x(XI);
yy=ntk2.y(XI);
electrodes=B;

min_dist =[+Inf];

number_els=4;
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
%

concateneted_spikes=[];
concatenated_ts=[];
concatenated_idx_light=[];
electrodes_to_sort=[];
electrode_for_threshold=[];
x_y_c=[];


for jjj=48%1:length(B);


electrode_for_sorting1=[];
electrode_for_sorting2=[];
electrode_for_sorting3=[];
electrode_for_sorting4=[];
electrode_for_sorting5=[];

elettrodi=electrode_list(jjj,1);

if length(electrode_list(jjj,:))>=2
electrode_for_sorting1=find(ntk2.el_idx==electrode_list(jjj,2));    
end
if length(electrode_list(jjj,:))>=3
electrode_for_sorting2=find(ntk2.el_idx==electrode_list(jjj,3));
end
if length(electrode_list(jjj,:))>=4
electrode_for_sorting3=find(ntk2.el_idx==electrode_list(jjj,4));
end
if length(electrode_list(jjj,:))>=5
electrode_for_sorting4=find(ntk2.el_idx==electrode_list(jjj,5));
end
if length(electrode_list(jjj,:))>=6
electrode_for_sorting5=find(ntk2.el_idx==electrode_list(jjj,6));
end
working.sig=ntk2.sig;

electrode=find(B==elettrodi);
electrode_for_sorting=find(ntk2.el_idx==elettrodi);

temp_neur=cut_events_create_nnn(ntk2,electrode,thr_f,event_param.pre2,event_param.post2,0,'bars');
temp_neur=realign_traces(temp_neur,'best_n',1);
temp_neur=reextract_aligned_traces(temp_neur,working);

n1=trim_electrodes(temp_neur, 'include', temp_neur.el_idx([electrode_for_sorting,electrode_for_sorting1,electrode_for_sorting2,electrode_for_sorting3,electrode_for_sorting4,electrode_for_sorting5]));
n1=get_traces_per_ts(n1,'do_crop','crop_output','do_traces_align');

concateneted_spikes(jjj).sp=[n1.tr_per_ts]; 
concatenated_ts(jjj).ts=[n1.ts];
concatenated_idx_light(jjj).idl=[n1.idx_diff];
electrodes_to_sort(jjj).coo=[n1.el_idx];
electrode_for_threshold(jjj).th=[n1.ELECTRODE];
x_y_c(jjj).xy=[n1.x;n1.y];



end

concatenated_infos{kk}={{concateneted_spikes},{concatenated_ts},{concatenated_idx_light},{electrodes_to_sort},{electrode_for_threshold},{x_y_c}}; % important structure with all infos

end

%% concatenation of sorted data and clustering

for jjjj=48%1:length(B)


close all
concateneted_spikes=[];
concatenated_ts=[];
concatenated_idx_light=[];
electrodes_to_sort=[];
electrode_for_threshold=[];
x_y_c=[];

for i=1:length(concatenated_infos)
    
temp_struct=concatenated_infos{i};

temp_struct1=temp_struct{1};
temp_struct1=temp_struct1{1};

temp_struct2=temp_struct{2};
temp_struct2=temp_struct2{1};

temp_struct3=temp_struct{3};
temp_struct3=temp_struct3{1};

temp_struct4=temp_struct{4};
temp_struct4=temp_struct4{1};

temp_struct5=temp_struct{5};
temp_struct5=temp_struct5{1};

temp_struct6=temp_struct{6};
temp_struct6=temp_struct6{1};


concateneted_spikes=[concateneted_spikes; temp_struct1(jjjj).sp];
concatenated_ts=[concatenated_ts  temp_struct2(jjjj).ts];
concatenated_idx_light=[concatenated_idx_light; temp_struct3(jjjj).idl];
electrodes_to_sort=[electrodes_to_sort; temp_struct4(jjjj).coo];
electrode_for_threshold=[electrode_for_threshold; temp_struct5(jjjj).th];
x_y_c=[x_y_c; temp_struct6(jjjj).xy];


end


% cluster

[COEFF SCORE] = princomp(concateneted_spikes,'econ');
T=runKlustaKwik(SCORE(:,1:min([size(SCORE,2) 20])),'klustakwik_tmp','1110000000000000000000000');    % TODO: why?!?!
all_T{jjjj}=T;
all_SCORE{jjjj}=SCORE;
end

%% plot clusters
T=all_T{jjjj};
SCORE=all_SCORE{jjjj};

lcolor=lines(100);

scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4) scrsz(3)/3 scrsz(4)/2.5]);
subplot(131)
hold on;
IND=min(T):max(T);
for i=min(T):max(T)
    plot(SCORE(T==i,1),SCORE(T==i,2),'.','color',lcolor(i,:));
end
box on;
title('Principal Components 1 and 2','Fontsize',18)
set(gca,'FontSize',18);

subplot(1,3,[2 3])
hold on;
for i=min(T):max(T)
    
    plot((concateneted_spikes(T==i,:)')+(i*200),'color',lcolor(i,:));
    text(2,(i*200),int2str(i),'FontSize',18)
end
els_labels=mean(electrodes_to_sort);
for i=1:size(electrodes_to_sort,2)
    text(((size(concateneted_spikes,2)/size(electrodes_to_sort,2))*i)-9,max(max(concateneted_spikes(T==max(T),:)')+(max(T)*200))+20,int2str(els_labels(i)),'FontSize',18)   
    if els_labels(i)==mean(electrode_for_threshold)
    text(((size(concateneted_spikes,2)/size(electrodes_to_sort,2))*i)-9,max(max(concateneted_spikes(T==max(T),:)')+(max(T)*200))+20,int2str(els_labels(i)),'FontSize',18,'Color','r')      
    end
    hold on
end
box on;
title('Data used for clustering','Fontsize',18)
set(gca,'FontSize',18);
ylim([min(min(concateneted_spikes(T==min(T),:)')+(min(T)*200))-50 max(max(concateneted_spikes(T==max(T),:)')+(max(T)*200))+50])

%% 

iii=3; %number of cluster to plot6
plot_PCA=1;

retinal_ganglion_cell=[];
for i=min(T):max(T)
retinal_ganglion_cell{i}.ts=concatenated_ts(T==i);
retinal_ganglion_cell{i}.traces=concateneted_spikes(T==i,:);
end

diff_ts=diff(retinal_ganglion_cell{iii}.ts);
idx_to_sort=find(diff_ts<0)+1;
idx_to_sort=[1 idx_to_sort length(retinal_ganglion_cell{iii}.ts)+1];

for i=1:length(flist)
time_stamps=retinal_ganglion_cell{iii}.ts;    
DS_ts(i).ts=time_stamps(idx_to_sort(i):(idx_to_sort(i+1)-1));
end


%
offset_d=[1,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1];
offset_u=[0.95,0.85,0.75,0.65,0.55,0.45,0.35,0.25,0.15,0.05]; 
offset_d=(offset_d/2)+0.5;
offset_u=(offset_u/2)+0.5;
ch=18;
lcolor=lines(40);
angles=[270,90,1,180,225,45,315,135];
angles_sorted=sort(angles);
angles_for_plots=[270,90,0,180,225,45,315,135];
angles_for_plots=sort(angles_for_plots);
zv=7;
psth_shift=0.8;
concatenated_idx_d=diff(concatenated_idx_light');
limit=max(max(diff(concatenated_idx_light')))+5000;

scrsz = get(0,'ScreenSize');
figure('Position',[0.9 0.9 1500 1500])
subplot(3,3,[1,4,7]);

for i=1:8

pos_angle=find(angles_sorted==angles(i));    
    
z=mean(concatenated_idx_d(i,:))-20000;
stimulus=[20000,z];
h=[pos_angle-0.1, pos_angle-0.1];
area(stimulus,h,'Facecolor',[0.8,0.8,0.8],'EdgeColor','w','basevalue',pos_angle-1');
hold on
end

for ii=1:length(DS_ts)

ts=DS_ts(ii).ts;
spike=[];

idx_diff=concatenated_idx_light(ii,:);
for i=1:8
spike(i).times=ts(ts>idx_diff(i) & ts<idx_diff(i+1));
spike(i).times=spike(i).times-(idx_diff(i));
end

for i=1:8
pos_angle=find(angles_sorted==angles(i)); 

for j=1:length(spike(i).times);
t=spike(i).times;
line([t(j) t(j)],[pos_angle-offset_d(ii) pos_angle-offset_u(ii)],'Color', 'k','LineWidth',1);
end

hold on
text(0,pos_angle-0.35,[(int2str(angles_for_plots(pos_angle))) '°'],'FontSize',16,'fontweight','b')

hold on
end
end
xlim([0 limit])
ylim([-0.8 8.5])


% psth
all_spikes=[];
for ii=1:length(DS_ts)

ts=DS_ts(ii).ts;
spike=[];

idx_diff=concatenated_idx_light(ii,:);
for i=1:8
spike(i).times=ts(ts>idx_diff(i) & ts<idx_diff(i+1));
spike(i).times=spike(i).times-(idx_diff(i));
end

all_spikes(ii).a=spike;

end
    

width=2000;
for i=1:8
pos_angle=find(angles_sorted==angles(i));  

edges=[0:width:limit]; %define window size, 2000 samples=100ms
psth=zeros(length(edges),1); 

for kk=1:length(all_spikes)
psth = psth + histc(all_spikes(kk).a(i).times, edges)';
end

psth=(psth/length(all_spikes))/(width/20000);%divide by windows size and number of trials
max_firing_rate=max(psth);
psth=(psth/300)+(pos_angle-psth_shift); %scale for plotting
plot(edges,psth,'k','LineWidth',2,'Color', 'k');
hold on

end

line([10000 10000],[-0.3 -0.65],'Color','k','LineWidth',2);
text(11500,-0.55,'100 Hz','FontSize',16,'fontweight','b')
x_axis=0:40000:limit;
labels=0:length(x_axis)-1;
labels=labels*2;
set(gca,'XTick',x_axis);
set(gca,'XTickLabel',labels);
xlabel('time [s]','Fontsize',ch)
title('Raster Plot and PSTH','Fontsize',ch);
set(gca,'FontSize',18);
set(gca,'YTickLabel',{});


%isi
all_isi=[];
for ii=1:length(DS_ts)
sr=20000;
ts=DS_ts(ii).ts;
ts=ts/sr*1000;
isi_n=diff(sort(ts));
all_isi=[all_isi isi_n];
end
maxt=50;
isi=all_isi(all_isi<maxt);
x=0:0.1:50;
subplot(3,3,2);hist(isi,x)
h = findobj(gca,'Type','patch');
set(h,'FaceColor',lcolor(zv,:),'EdgeColor',lcolor(zv,:));
ylabel('Counts','Fontsize',ch);
xlabel('Interspike interval [ms]','Fontsize',ch)
title('Interspike Interval Histogram','Fontsize',ch);
xlim([0 50]);
set(gca,'FontSize',18);

%polar plot
spike_number=zeros(1); 
polar_values=[];
for i=1:8
    
for kk=1:length(all_spikes)
spike_number = spike_number + length(all_spikes(kk).a(i).times);
end

polar_values(1,i)=spike_number/length(all_spikes);

spike_number=zeros(1); 
end

angles_rad=[4.7124,1.5708,0,3.1416,3.9270,0.7854,5.4978,2.3562,6.2832];

idx=[7,3,1,5,6,2,8,4];
for g=1:length(idx)
pol(idx(g))=polar_values(g);
end
pol(9)=polar_values(3);
angles_rad=sort(angles_rad);

r_max=ceil(max(pol)+5);
subplot(3,3,5);
mypolar(angles_rad,pol,'ro');  
h_fake = mypolar(angles_rad,r_max*ones(size(angles_rad)));
hold on;
h = mypolar(angles_rad, pol,'--k.');
set(h_fake, 'Visible', 'Off');
set( findobj(h, 'Type', 'line'), 'LineWidth',2, 'MarkerEdgeColor','r', ...
'MarkerFaceColor',[0.5 0.5 0], 'MarkerSize',28);
title('Polar Plot','Fontsize',ch); 

a=angles_rad;
b=pol;
a(9)=[];
b(9)=[];
Ax=b.*cos(a);
Ay=b.*sin(a);
Rx=sum(Ax);
Ry=sum(Ay);
R=sqrt((Rx)^2+(Ry)^2);
theta=atan(Ry/Rx);
if Rx<0
    theta=theta+pi;
end
if theta<0
angleOut3=360+rad2deg(theta);
theta=deg2rad(angleOut3);
end

[diff_max_pol, ind_max_pol] = min(abs(angles_rad(1:8) - theta));

if ind_max_pol==1;
   ind_min_pol=5;
end
if ind_max_pol==5;
   ind_min_pol=1;
end
if ind_max_pol==2;
   ind_min_pol=6;
end
if ind_max_pol==6;
   ind_min_pol=2;
end
if ind_max_pol==3;
   ind_min_pol=7;
end
if ind_max_pol==7;
   ind_min_pol=3;
end
if ind_max_pol==4;
   ind_min_pol=8;
end
if ind_max_pol==8;
   ind_min_pol=4;
end
min_pol=pol(ind_min_pol);
max_pol=pol(ind_max_pol);

D_S_I=(max_pol-min_pol)/(max_pol+min_pol);

subplot(3,3,8);
[x,y] = pol2cart(theta,D_S_I);
[x1,y1] = pol2cart(theta,1);
compass(x1,y1,'ow')
hold on
h=compass(x,y,'k');
compass(x,y,'k')
set(findobj(h, 'Type', 'line'), 'LineWidth',2)
title(['D.I= ',num2str(D_S_I)],'Fontsize',ch);

%PCA
if plot_PCA
subplot(3,3,[3]);

IND=min(T):max(T);
for i=min(T):max(T)
    plot(SCORE(T==i,1),SCORE(T==i,2),'.','color',lcolor(zv,:)+i/25);
    hold on
    if i==iii
    plot(SCORE(T==i,1),SCORE(T==i,2),'.','color','r');
    hold on
    end
end

box on;
title('Principal Components 1 and 2','Fontsize',ch)
set(gca,'FontSize',18);

subplot(3,3,[6,9]);
for i=min(T):max(T)
    hold on
    plot((concateneted_spikes(T==i,:)')+(i*200),'color',lcolor(zv,:)+i/25);
    text(2,(i*200),int2str(i),'FontSize',ch)
    if i==iii
    plot((concateneted_spikes(T==i,:)')+(i*200),'color','r');
    text(2,(i*200),int2str(i),'FontSize',ch)
    hold on
    end
   
end
els_labels=mean(electrodes_to_sort);
for i=1:size(electrodes_to_sort,2)
    text(((size(concateneted_spikes,2)/size(electrodes_to_sort,2))*i)-9,max(max(concateneted_spikes(T==max(T),:)')+(max(T)*200))+20,int2str(els_labels(i)),'FontSize',ch)   
    if els_labels(i)==mean(electrode_for_threshold)
    text(((size(concateneted_spikes,2)/size(electrodes_to_sort,2))*i)-9,max(max(concateneted_spikes(T==max(T),:)')+(max(T)*200))+20,int2str(els_labels(i)),'FontSize',ch,'Color','r')      
    end
    hold on
end
box on;
title('Data used for clustering','Fontsize',ch)
xlabel('samples','Fontsize',ch)
ylabel('uV','Fontsize',ch)
set(gca,'FontSize',ch);
end
