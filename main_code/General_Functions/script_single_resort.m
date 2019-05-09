%% PLOT

% clear all;close all
k=4; % patch number

cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/13Oct2010_DSGCs/Matlab
flist={};
flist_search;
siz=20; %000000;
ntk=initialize_ntkstruct(flist{k},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');
ntk2=detect_valid_channels(ntk2,1);
% ntk2=cut_ntk2_bars(ntk2,length(ntk2.sig));
[B XI]=sort(ntk2.el_idx);
ch_idx=XI;
% figure('Position',[0.9 0.9 1500 1500],'Color','w'); signalplotter(ntk2,'elidx',[B(1:20)], 'samples', 1:length(ntk2.sig));
% figure('Position',[0.9 0.9 1500 1500],'Color','w'); signalplotter(ntk2,'elidx',[B(21:40)], 'samples', 1:length(ntk2.sig));
% figure('Position',[0.9 0.9 1500 1500],'Color','w'); signalplotter(ntk2,'elidx',[B(41:60)], 'samples', 1:length(ntk2.sig));
% figure('Position',[0.9 0.9 1500 1500],'Color','w'); signalplotter(ntk2,'elidx',[B(61:80)], 'samples', 1:length(ntk2.sig));
% figure('Position',[0.9 0.9 1500 1500],'Color','w'); signalplotter(ntk2,'elidx',[B(81:length(B))], 'samples', 1:length(ntk2.sig));

%figure('Position',[0.9 0.9 1500 1500],'Color','w'); plot(ntk2.images.frameno)
%figure('Position',[0.9 0.9 1500 1500],'Color','w');hist(ntk2.thr_base);
% temp_neurons=cell(0,0)

%% FIND ELS
x = ntk2.x(XI);
y = ntk2.y(XI);
xx=ntk2.x(XI);
yy=ntk2.y(XI);
electrodes=B;

min_dist =[+Inf];

number_els=6;
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

%% sort
% x_neur = {}

for iiii=badCells

       

temp_neur = temp_neurons{iiii};
    [Imax,Ymax] = max(temp_neur.template.data,[],1);
    [Imin,Ymin] = min(temp_neur.template.data,[],1);
    peak2PeakValues = (Imax-Imin);
        
    [I,Y] = max(peak2PeakValues);
%  figure, plot_neurons(temp_neurons{i},'elidx','dotraces_gray','electrodes', [temp_neurons{i}.el_idx(Y),temp_neurons{i}.el_idx(Y2)])
%         
%             title(strcat(num2str(i),'//',num2str(i),'/',num2str(percentSu
%             bThreshold),'/',num2str(stdTrace),'/',temp_neurons{i}.rgc_type))
            
iii=find(electrode_list(:,1)==temp_neur.el_idx(Y));



    


    
    % info about the recording
    info=cell(1,8);
    info{1,1}='ND:10';
    info{1,2}='CONFIG: sparse els';
    info{1,3}='SPEED:800 um/s';    % 'MARCHING BLOCKS U->D'
    info{1,4}='BAR WIDTH: 400 um'; % 'BAR WIDTH: 200 um'
    info{1,5}='COLOR BAR: BLU+GREEN LED AT 255';
    info{1,6}='CONTRAST: 100%';
    info{1,7}=[270,90,0,180,225,45,315,135];  % 'OVERLAP: 1n00 um'
    info{1,8}='5 S BETWEEN REPETITIONS';   % '10 S BETWEEN EACH MARCHING BAR'
    ntk2.light_info=info %stimulus info
    
    % parameters to cut traces
    p.pretime=12; % how much to cut before thr is passed
    p.posttime=16; % how much to cut after thr is passed
    
    event_param=[];
    event_param.pre2=p.pretime;
    event_param.post2=p.posttime;
    event_param.tlen2=event_param.pre2+event_param.post2;
    event_param.pre1=floor(event_param.pre2*3/4);
    event_param.post1=floor(event_param.post2*2/3);
    event_param.tlen1=event_param.pre1+event_param.post1;
    event_param.margin=10;
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
    
     z=1
        
        thr_f=6;
        
        electrode=find(B==elettrodi(z));
        i=electrode;
        electrode_for_sorting=find(ntk2.el_idx==elettrodi(z));
        
        % cut and align
        
        %temp_neur=cut_events_create_nnn(ntk2,i,thr_f,event_param.pre2,event_param.post2,1);
        temp_neur=realign_traces(temp_neur,'sel_els',electrode_for_sorting,'max_lags',6);
        %temp_neur=reextract_aligned_traces(temp_neur,working);
        
        % pca %% 'KK',cluster_method
        n_clust=6;
        cluster_method='KK';  %'kmeans'  'KK' 'fuzzy'  'clusterdata' 'gmm'
        if  ~isempty(electrode_for_sorting1) & isempty(electrode_for_sorting2) & isempty(electrode_for_sorting3) & isempty(electrode_for_sorting4) & isempty(electrode_for_sorting5)
            [spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1],'cluster_method',cluster_method,'n_clust',n_clust);
        elseif ~isempty(electrode_for_sorting1) & ~isempty(electrode_for_sorting2) & isempty(electrode_for_sorting3) & isempty(electrode_for_sorting4) & isempty(electrode_for_sorting5)
            [spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1,electrode_for_sorting2],'cluster_method',cluster_method,'n_clust',n_clust);
        elseif ~isempty(electrode_for_sorting1) & ~isempty(electrode_for_sorting2) & ~isempty(electrode_for_sorting3) & isempty(electrode_for_sorting4) & isempty(electrode_for_sorting5)
            [spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1,electrode_for_sorting2,electrode_for_sorting3],'cluster_method',cluster_method,'n_clust',n_clust);
        elseif ~isempty(electrode_for_sorting1) & ~isempty(electrode_for_sorting2) & ~isempty(electrode_for_sorting3) & ~isempty(electrode_for_sorting4) & isempty(electrode_for_sorting5)
            [spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1,electrode_for_sorting2,electrode_for_sorting3,electrode_for_sorting4],'cluster_method',cluster_method,'n_clust',n_clust);
        elseif ~isempty(electrode_for_sorting1) & ~isempty(electrode_for_sorting2) & ~isempty(electrode_for_sorting3) & ~isempty(electrode_for_sorting4) & ~isempty(electrode_for_sorting5)
            [spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting,electrode_for_sorting1,electrode_for_sorting2,electrode_for_sorting3,electrode_for_sorting4,electrode_for_sorting5],'cluster_method',cluster_method,'n_clust',n_clust);
        else
            [spl_neurs T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrode_for_sorting],'cluster_method',cluster_method);
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
        splitted2=merge_neurons(splitted2,'interactive',1,'no_isi');
        fprintf('Loop # %d\n',iii)
        sorted_nnn_PCA=plot_RGCs_bar_response(splitted2,'interactive','electrode',electrode_for_sorting);
        
        fprintf('Loop # %d\n',iii)
        for i=1:length(sorted_nnn_PCA)
            temp_neur(i)=sorted_nnn_PCA{i};
        end
        
        
        close all
    
        for m = length(temp_neur)
           x_neur{end+1} = temp_neur(m)
           
        end
        temp_neurons{iiii} = 1;
end
