function clusterdata(varargin)
%% Cluster and merge data
tic
% ----------------- Argument settings ----------------- %
load electrode_list.mat
enableSaveData = 0;
electrodeOfInterest = [];
i = 1;
if ~isempty(varargin)
    while i<=length(varargin)
        if strcmp('enable_save_data',varargin{i})
            enableSaveData = 1;
            fprintf('clusterdata: save data enabled\n');
        elseif strcmp('electrode',varargin{i})
            i = i+1;
            electrodeOfInterest = varargin{i};
            fprintf('clusterdata: electrode %d selected\n',electrodeOfInterest );
        else
            fprintf('clusterdata: unknown argument\n');
        end
        i=i+1;
    end
end

if isempty(electrodeOfInterest)
    electrodeOfInterest = 5358;
    fprintf('clusterdata: electrode %d selected\n',electrodeOfInterest );
end


%%load data
eval(['load ntkLoadedDataElectrode',num2str(electrodeOfInterest)])

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
ntk2.thr_base = thr_f;
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

number_els = size(electrode_list(:,1),2)-1;
% init electrode index variables
for ii = 1:number_els+1
    eval(['electrodeIndex',num2str(ii),'=[];']);
end

% electrode index values
for ii = 1:number_els
    
    eval(['electrodeIndex',num2str(ii),'=find(ntk2.el_idx==electrode_list(electrodeListIndex,',num2str(ii), ')) ;']);
end

working.sig=ntk2.sig;
[B XI]=sort(ntk2.el_idx);
ch_idx=XI;


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
    fprintf('clusterdata: enter pca_cluster\');
    if number_els == 4
        if  ~isempty(electrodeIndex1) && isempty(electrodeIndex2) && isempty(electrodeIndex3) && isempty(electrodeIndex4) && isempty(electrodeIndex5)
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex,electrodeIndex1],'save_plot_data');
        elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && isempty(electrodeIndex3) && isempty(electrodeIndex4) && isempty(electrodeIndex5)
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2],'save_plot_data');
        elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && ~isempty(electrodeIndex3) && isempty(electrodeIndex4) && isempty(electrodeIndex5)
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2,electrodeIndex3],'save_plot_data');
        elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && ~isempty(electrodeIndex3) && ~isempty(electrodeIndex4) && isempty(electrodeIndex5)
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2,electrodeIndex3,electrodeIndex4],'save_plot_data');
        elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && ~isempty(electrodeIndex3) && ~isempty(electrodeIndex4) && ~isempty(electrodeIndex5)
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2,electrodeIndex3,electrodeIndex4,electrodeIndex5],'save_plot_data');
        else
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex],'save_plot_data');
        end
        
    elseif number_els == 2
        if  ~isempty(electrodeIndex1) && isempty(electrodeIndex2) && isempty(electrodeIndex3)
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex,electrodeIndex1],'save_plot_data');
        elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && isempty(electrodeIndex3)
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2],'save_plot_data');
        elseif ~isempty(electrodeIndex1) && ~isempty(electrodeIndex2) && ~isempty(electrodeIndex3)
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2,electrodeIndex3],'save_plot_data');
        else
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex],'save_plot_data');
        end
    elseif number_els == 1
        if  ~isempty(electrodeIndex1)
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex,electrodeIndex1],'save_plot_data');
        else
            [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex],'save_plot_data');
        end
        
    else
        disp('Error with number of electrodes specified')
    end
    fprintf('clusterdata: exit pca_cluster\');
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
    % sufficientlyActiveClusters=analyze_and_correct_clusters(sufficientlyActiveClusters,'interactive',1);
    % % merge neurons
    % sufficientlyActiveClusters=merge_neurons(sufficientlyActiveClusters,'interactive',1,'no_isi');
    
end
toc

clear initialCluster ntk2 traceTimeStamps working eventTimeStamps
% save neuron data
eval(['save clusteredEventsDataElectrode',num2str(electrodeOfInterest)])


end