function y=plot_RGCs_bar_response(sorted_nnn,varargin)

do_interactive=0;
i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))  
        if strcmp(varargin{i}, 'interactive')
            do_interactive=varargin{i};
        end
    end
    i=i+1;
end


ch=18;
lcolor=lines(2000);
angles=[270,90,1,180,225,45,315,135];
angles_sorted=sort(angles);
angles_for_plots=[270,90,0,180,225,45,315,135];
angles_for_plots=sort(angles_for_plots);
sorted_DS=[];


for ii=1:length(sorted_nnn)
limit=max(sorted_nnn{ii}.idx_d)+5000;
ts=sorted_nnn{ii}.ts;
spike=[];

%% raster plot
for i=1:length(sorted_nnn{ii}.on)
spike(i).times=ts(ts>sorted_nnn{ii}.idx_diff(i) & ts<sorted_nnn{ii}.idx_diff(i+1));
spike(i).times=spike(i).times-(sorted_nnn{ii}.idx_diff(i));
end

scrsz = get(0,'ScreenSize');
figure('Position',[0.9 0.9 1500 1500])
subplot(3,3,[1,4,7]);


for i=1:length(sorted_nnn{ii}.on)

pos_angle=find(angles_sorted==angles(i));    
    
z=sorted_nnn{ii}.idx_d(i)-20000;
stimulus=[20000,z];
h=[pos_angle-0.1, pos_angle-0.1];
area(stimulus,h,'Facecolor',[0.8,0.8,0.8],'EdgeColor','w','basevalue',pos_angle-1');
hold on 
    
for j=1:length(spike(i).times);
t=spike(i).times;
line([t(j) t(j)],[pos_angle-0.9 pos_angle-0.7],'Color', lcolor(ii,:),'LineWidth',1);
end

hold on
text(0,pos_angle-0.4,[(int2str(angles_for_plots(pos_angle))) '°'],'FontSize',16,'fontweight','b')

end
%line([20000 20000],[-0.5 -0.05],'Color','y','LineWidth',2);
%z=idx(off(i))-idx(on(i))+20000;
%line([z z],[-0.5 -0.05],'Color','k','LineWidth',2);
xlim([0 limit])
ylim([-0.8 8.5])


%% psth
width=1000;
for i=1:length(sorted_nnn{ii}.on)
pos_angle=find(angles_sorted==angles(i));  
hold on
%b=((idx(off(i))+20000)-(idx(on(i))-20000)); %length spikke train;
edges=[0:width:limit]; %define window size, 2000 samples=100ms
psth=zeros(length(edges),1); 
psth = histc(spike(i).times, edges)';
psth=(psth)/(width/20000);%divide by windows size and number of trials
max_firing_rate=max(psth);

psth=(psth/300)+(pos_angle-0.7); %scale for plotting
if isvector(psth)
plot(edges,psth,'k','LineWidth',2,'Color', 'k');
end
end
line([10000 10000],[-0.3 -0.65],'Color','k','LineWidth',2);
text(11500,-0.55,'100 Hz','FontSize',16,'fontweight','b')
%set(gca,'YTickLabel',{''});
%q=idx(on(i)+2)-idx(on(i));
x_axis=0:40000:limit;
labels=0:length(x_axis)-1;
labels=labels*2;
set(gca,'XTick',x_axis);
set(gca,'XTickLabel',labels);
%y_axis=[0,0.25,0.5,0.75,1];
%labels=[0,200*0.25,200*0.5,200*0.75,200*1];
%set(gca,'YTick',y_axis);
%set(gca,'YTickLabel',labels);
xlabel('time [s]','Fontsize',ch)
title('Raster Plot and PSTH','Fontsize',ch);
set(gca,'FontSize',18);
%ylabel('Firing Rate [Hz]','Fontsize',ch)
set(gca,'YTickLabel',{});
%isi
sr=20000;
ts=sorted_nnn{ii}.ts/sr*1000;
isi=diff(sort(ts));
maxt=50;
isi=isi(isi<maxt);
x=0:1:50;
subplot(3,3,2);hist(isi,x)
h = findobj(gca,'Type','patch');
set(h,'FaceColor',lcolor(ii,:),'EdgeColor',lcolor(ii,:));
ylabel('Counts','Fontsize',ch);
xlabel('Interspike interval [ms]','Fontsize',ch)
title('Interspike Interval Histogram','Fontsize',ch);
xlim([0 50]);
%ylim([0 50]);
set(gca,'FontSize',18);

%% pkt2pk or polar plot
neuron=sorted_nnn{ii};
[v ind]=max(abs(max(neuron.template.data)-min(neuron.template.data)));
% ind = template index with highest pktpk
trcs=neuron.trace{ind}.data;
pktpks=max(trcs)-min(trcs);
%subplot(3,3,5); 
%simple_polar(sorted_nnn{ii})
% hist(pktpks,50)
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor',lcolor(ii,:),'EdgeColor',lcolor(ii,:));
% xlabel('Peak to peak amplitude [uV]','Fontsize',ch)
% ylabel('Counts','Fontsize',ch)
% title(['Peak-to-peak Histogram at electrode ',int2str(neuron.el_idx(ind))],'Fontsize',ch);
% set(gca,'FontSize',18);
% xlim([0 400]);
%ylim([0 10]);

neuron_pol=sorted_nnn{ii};
all_spike_pols=[];
%for ii=1:length(neuron_pol)
ts=neuron_pol.ts;
spike_pol=[];

for i=1:length(neuron_pol.on)
spike_pol(i).times=ts(ts>neuron_pol.idx_diff(i) & ts<neuron_pol.idx_diff(i+1));
spike_pol(i).times=spike_pol(i).times-(neuron_pol.idx_diff(i));
end
all_spike_pols(1).a=spike_pol;
%end

spike_pol_number=zeros(1); 
polar_values=[];
for i=1:length(neuron_pol.on)
    
for kk=1:length(all_spike_pols)
spike_pol_number = spike_pol_number + length(all_spike_pols(kk).a(i).times);
end

polar_values(1,i)=spike_pol_number/length(all_spike_pols);

spike_pol_number=zeros(1); 
end

angles_radiant_pol=[4.7124,1.5708,0,3.1416,3.9270,0.7854,5.4978,2.3562,6.2832];

idx=[7,3,1,5,6,2,8,4];
for g=1:length(idx)
pol(idx(g))=polar_values(g);
end
pol(9)=polar_values(3);
angles_radiant_pol=sort(angles_radiant_pol);

subplot(3,3,5); 

r_max=mean(pol)+15;

mypolar(angles_radiant_pol,pol,'ro');                                   
h_fake = mypolar(angles_radiant_pol,r_max*ones(size(angles_radiant_pol)));
hold on;
h = mypolar(angles_radiant_pol, pol,'--k.');
set(h_fake, 'Visible', 'Off');
set( findobj(h, 'Type', 'line'), 'LineWidth',2, 'MarkerEdgeColor','r', ...
'MarkerFaceColor',[0.5 0.5 0], 'MarkerSize',12);
title(neuron_pol.light_info{3},'Fontsize',ch); 


% vector sum
subplot(3,3,8); 
a=angles_radiant_pol;
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

% [bb aa]=max(pol);
% dd=a(aa);
% angleOut = rad2deg(dd);
%angleOut_negative= angleOut-360;


% %sector 2 and 3
% theta_1=atan(Ry/Rx)+pi;
% angleOut1 = rad2deg(theta_1);
% if angleOut1<0
%  angleOut1=360-angleOut1;
% end
% 
% %sector 1 and 4
% theta_2=atan(Ry/Rx);
% angleOut2 = rad2deg(theta_2);
% if angleOut2<0
%  angleOut2=360+angleOut2;
% end
% 
% if (angleOut>180 & angleOut<360)
%    angleOut=angleOut-360;
% end
% 
% if (angleOut1>180 & angleOut1<360)
%    angleOut1=angleOut1-360;
% end
% 
% if (angleOut2>180 & angleOut2<360);
%    angleOut2=angleOut2-360;
% end
% 
% condition(1)=abs((angleOut-angleOut1));
% condition(2)=abs((angleOut-angleOut2));
% [val_cond ind_cond]=min(condition);
% 
% 
% tttt=[theta_1 theta_2];
% theta=tttt(ind_cond);

if theta<0
angleOut3=360+rad2deg(theta);
theta=deg2rad(angleOut3);
end

[diff_max_pol, ind_max_pol] = min(abs(angles_radiant_pol(1:8) - theta));

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

[x,y] = pol2cart(theta,D_S_I);
[x1,y1] = pol2cart(theta,1);
compass(x1,y1,'ow')
hold on
h=compass(x,y,'k');
compass(x,y,'k')
set(findobj(h, 'Type', 'line'), 'LineWidth',2)
title(['D.I= ',num2str(D_S_I)],'Fontsize',ch);

%% traces
subplot(3,3,9); plot((1:size(get_aligned_traces(sorted_nnn{ii}, sorted_nnn{ii}.event_param.pre2, sorted_nnn{ii}.event_param.post2, ind)))/20,get_aligned_traces(sorted_nnn{ii}, sorted_nnn{ii}.event_param.pre2, sorted_nnn{ii}.event_param.post2, ind),'Color',lcolor(ii,:))
set(gca,'FontSize',18);
ylabel('Amplitude [\muV]','Fontsize',ch)
xlabel('time [ms]','Fontsize',ch)
ylim([min(min(sorted_nnn{ii}.trace{ind}.data))-10 max(max(sorted_nnn{ii}.trace{ind}.data))+10])
title(['Spikes at el. ',int2str(neuron.el_idx(ind))],'Fontsize',ch);
%legend(['ELECTRODE FOR SORTING: ',int2str(sorted_nnn{ii}.ELECTRODE)],'Location','SouthOutside')

ffff=sorted_nnn{ii}.el_idx(ind);
[val_ntk2 ind_ntk]=find(sorted_nnn{ii}.el_idx==ffff);
x_center=sorted_nnn{ii}.x(ind_ntk);
y_center=sorted_nnn{ii}.y(ind_ntk);
x_min=x_center-50;
x_max=x_center+50;
y_min=y_center-50;
y_max=y_center+50;


subplot(3,3,[3 6]);plot_neurons(sorted_nnn,'neurons',[ii],'nolegend','width',2,'elidx','color',lcolor(ii,:))%,'xmin',x_min,'xmax',x_max,'ymin',y_min,'ymax',y_max)
set(gca,'FontSize',18);
xlabel('X [\mum]','Fontsize',ch);
ylabel('Y [\mum]','Fontsize',ch);
title('RGCs Footprints','Fontsize',ch);

if do_interactive
quest=sprintf('IS THIS A DIRECTION SELECTIVE CELL?? Y/N [Y]: ');
            reply = input(quest, 's');
            if isempty(reply)
                reply = 'Y';
            end
            if upper(reply)=='Y'
               sorted_nnn{ii}.polar_info=[theta,D_S_I];
               sorted_DS{length(sorted_DS)+1}=sorted_nnn{ii};
            end
            close all
end


end

y=sorted_DS;