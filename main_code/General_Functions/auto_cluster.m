function auto_cluster(electrode_list, number_els,minutesToLoad)
% auto_cluster(electrode_list, number_els,minutesToLoad)
% number_els=1; %surrounding%
% ---------------- set constants ---------------- %

temp_neurons=cell(0,0);
flist={};
flist_for_analysis; %flist
k=1; % file number
siz=20000*60*minutesToLoad; % frames to load
loadAllChannels = 0 ;
doPlot          = 0 ;
global mainDirPath
global  analyzedDataDirPath
global electrodeOfInterest


load(fullfile(analyzedDataDirPath,strcat('ntk2ChannelLookup.mat')));

sizAllData=2e4*60*2;
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2_all ntk]=ntk_load(ntk, sizAllData , 'images_v1'); % images_v1 argument to load ts of image
    clear ntk

% channelOfInterest = find(electrode_list(:,1)==4656);
fprintf('path = %s \n',analyzedDataDirPath);
% r = input('Correct path?');




% ---------------- load data ---------------- %


for i = 1:size(electrode_list,1)
    tic
        try
            electrodeOfInterest = electrode_list(i,1);
        surroundingElectrodes = convertelectrodestochannels(electrodeOfInterest, electrode_list, ntk2ChannelLookup, number_els)
    %save ntk2 struct
    load(fullfile(analyzedDataDirPath,strcat('ntkLoadedDataElectrode',num2str(electrodeOfInterest),'.mat')));
    
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
    siz=20000*60*2;
    
    temp_neur=cut_events_create_nnn(ntk2,1,thr_f,event_param.pre2,event_param.post2,1);
    
    electrodeListIndex=find(electrode_list(:,1)==electrodeOfInterest);
    
    %load all ntk2 data
    
    temp_neur=realign_traces(temp_neur,'best_n','max_lags',4);
   
    
    % init electrode index variables
    if number_els > 0
        for ii = 1:number_els+1
            eval(['electrodeIndex',num2str(ii),'=[];']);
        end
        
        % electrode index values
        for ii = 1:number_els+1
            eval(['electrodeIndex',num2str(ii),'=find(ntk2.el_idx==electrode_list(electrodeListIndex,',num2str(ii), ')) ;']);
        end
    end
    electrodeIndex=find(ntk2.el_idx==electrodeOfInterest);
    
    [initialCluster T SCORE]=pca_cluster_neuron(temp_neur);
    %         [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'sel_els',[electrodeIndex, electrodeIndex1, electrodeIndex2, electrodeIndex3],'cluster_method','kmeans','n_clust',2);
    
    %         [initialCluster T SCORE]=pca_cluster_neuron(temp_neur,'do_plot','sel_els',[electrodeIndex,electrodeIndex1,electrodeIndex2,electrodeIndex3,electrodeIndex4,electrodeIndex5]);
    sufficientlyActiveClusters=initialCluster;
    
    sufficientlyActiveClusters=analyze_and_correct_clusters_single_el(sufficientlyActiveClusters,'interactive',0 );
    for o=1:size(sufficientlyActiveClusters,2)
        sufficientlyActiveClusters{o}=get_all_spike_traces_all_el(sufficientlyActiveClusters{o},ntk2_all)
    end
    save(fullfile(analyzedDataDirPath,strcat('clustDataElectrode',num2str(electrodeOfInterest),'.mat')),'sufficientlyActiveClusters');
    close all
    fprintf('-----------------loop # %d------------',i);
        catch
            fprintf('Error with electrode %d\n',electrode_list(i,1))
            beep()
        end
    toc
end

end