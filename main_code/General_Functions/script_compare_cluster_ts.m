% file path = /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/5Mar2011_DSGCs_ij/analysed_data/rec12_21_7/
% This script groups clusters based solely on ts
%
global mainDirPath analyzedDataDirPath

%% ------------------------ load files ------------------------
load(fullfile(mainDirPath,'Matlab',strcat('electrode_list'))); %electrode list

% patchCluster contains all neurons
fprintf('path = %s \n',analyzedDataDirPath);
r = input('Correct path?');
load(fullfile(analyzedDataDirPath,'patchClust.mat'));

%% ------------------------ Realign traces ------------------------
patchCluster_real = realign_traces(patchCluster);
save(fullfile(analyzedDataDirPath,'patchCluster_real.mat'),'patchCluster_real');
fprintf('patchCluster_real saved to \n %s\n',fullfile(analyzedDataDirPath,'patchCluster_real.mat'))

%% ------------------------ align to neg peak  ------------------------
for i=1:length(patchCluster_real)
    patchCluster_real{i} = align_to_negative_peak(patchCluster_real{i});
end

%% ------------------------ globalize ts ------------------------

patchCluster_real = globalize_ts(patchCluster_real);

%% ------------------------ compare glob_ts for all neurons ------------------------
% neurons = patchCluster_real;
neurons = patchCluster_real;
db_ts_tol = 20;

% Get all pairs to be compared
pairs=[];
pairs = combntns(1:length(neurons),2)
pairs = [pairs;flipdim(pairs,2)];
n_pairs=size(pairs,1);

percentMatchingPairs = zeros(n_pairs,1);

% Go through pairs and merge them due to double ts

outputMatrix = zeros(n_pairs);

for p=1:n_pairs
    
    i=pairs(p,1);
    j=pairs(p,2);
    if ~isempty(neurons{i}) && ~isempty(neurons{j})
        
        % TODO: replace this (time consuming?) method by get_template_shift if
        % necessary and TEST!!!
%         [dist out]=get_neurons_distance(neurons{i},neurons{j}, 'method', 'ttestNorm',...     % CHECK: change to ttestNorm??
%             'norm_noise_ps',norm_noise_ps, 'param', param);
%         shift_ind=out.shift_ind;    % shift_ind seems to be always zero...!!! DEBUG soon!!!
%         
        %         t1=neurons{i}.template.data;  % alternative way...
        %         t2=neurons{j}.template.data;
        %         pre=neurons{1}.event_param.pre2;
        %         post=neurons{1}.event_param.post2;
        %         shift=get_template_shift(t1,t2,pre,post,'mean');
        
        
        %  detect double ts
        %         a=neurons{i}.ts+neurons{i}.ts_pos+shift_ind;
        a=neurons{i}.ts+neurons{i}.ts_pos;
        b=neurons{j}.ts+neurons{j}.ts_pos;
        
        ind_to_erase_j=[];
        for ii=1:length(b)
            if(find(a<(b(ii)+db_ts_tol) & a>(b(ii)-db_ts_tol)))
                ind_to_erase_j(end+1)=ii; 
            end
        end
        %if length(ind_to_erase_j)>max([10 db_ts_min_ratio*min([length(a) length(b)])])    % merge_due_to_double_ts
        %         if length(ind_to_erase_j)>db_ts_min_ratio*min([length(a) length(b)])
        %             if~(silent),fprintf('%.1f%% double_ts detected between neuron %d(n=%d) and %d(n=%d), ->merge\n',...
        %                     100*length(ind_to_erase_j)/min([length(a) length(b)]), i, length(a), j,length(b));
        %             end
        %             neurons=merge_two_neurons(neurons,i,j,shift_ind,param,active_channel_lim_ps);
        %         end
        % get percentage of matching
        if isempty(ind_to_erase_j)
            ind_to_erase_j = 0;
        end
        
        percentMatchingPairs(p) = length(ind_to_erase_j)/(length(a)+length(b));
        outputMatrix(i,j) = percentMatchingPairs(p);%length(ind_to_erase_j)/(min([length(a)+length(b)]));
        
        
        if p/200 == round(p/200)
            p/n_pairs
      end
        
    end
    
end

% save data
save(fullfile(analyzedDataDirPath,'percentMatchingPairs.mat'),'percentMatchingPairs');
save(fullfile(analyzedDataDirPath,'outputMatrix.mat'),'outputMatrix');

%% Plot charts of data
figure, 
h = axes('FontSize',12), xlabel('unique pairs','fontsize',12),ylabel('% matching spikes','fontsize',12)
plot(percentMatchingPairs) %percent of spikes matching for pairs
figure,
h = axes('FontSize',12),
hist(percentMatchingPairs,20)
xlabel('Fraction Matching Spikes','fontsize',12),ylabel('Number of Cluster Pairs','fontsize',12)

figure, imagesc(outputMatrix)
 
%% Get pairs with matches
MatchingCutoff = 0.15;
indicesOfMatchingPairs = find(percentMatchingPairs > MatchingCutoff );
matchingPairs = pairs(indicesOfMatchingPairs,:);

numberClusters = max(max(matchingPairs)); % number of clusters in matching pairs
% clusterGroups = NaN(numberClusters);
clustersUsed = [];
groupCounter = 1;
%put matching clusters into groups
clear clusterGroups
for i=1:numberClusters
        i
    [I J ] = find(matchingPairs==i); %find rows where cluster number i is found
    if ~sum(find(clustersUsed == i)) & I > 0 % only proceed if the cluster has not been assigned to a group
        
        selectedGroups = unique(matchingPairs(I,:)); %group of clusters
        if size(clustersUsed,1)>1  %ensure that data is in row format
            clustersUsed = clustersUsed'
        end
        if size(selectedGroups,1)>1
            selectedGroups = selectedGroups'
        end
        
        clustersUsed = [clustersUsed selectedGroups]; %keep record of clusters used
        clusterGroups{groupCounter}=selectedGroups; %put groups into a cell
        groupCounter = groupCounter+1;%augment counter of groups by 1
    else
        disp('no data');
    end
    
end

% "clusterGroups" is a cell containing the segregated cluster numbers

%% Plot data from groups of clusters

new_neur = [];
% for i=1:length(clusterGroups{1})
%     
%     new_neur{i} = reextract_aligned_traces
%     patchCluster_real{clusterGroups{1}}
% 
% end
% plot stuff
for i=1:length(clusterGroups)
figure,  plot_neuron_events(patchCluster_real(clusterGroups{i}), 20000, [1:length(clusterGroups{i})])
 plot_neurons(patchCluster_real(clusterGroups{i}),'separate_subplots')
end

%% all clusters are in "patchCluster_real"

%% Cluster data in groups
patchCluster_clust1 = [];

for i=1:length(clusterGroups)
    patchCluster_clust1{i} = merge_neurons(patchCluster_real(clusterGroups{i}),'interactive',1);

end
%% load cluster

load(fullfile(analyzedDataDirPath,'patchCluster_clust1'));

%% convert to struct
iCounter = 1
for i=1:length(patchCluster_clust1)
    i
    if(length(patchCluster_clust1{i})>0)
        patchCluster_clust2( iCounter:iCounter-1+length( patchCluster_clust1{i})) = patchCluster_clust1{i};
    else
        patchCluster_clust2(iCounter) = patchCluster_clust1{i};%convert to struct
        
        
    end
    iCounter = length(patchCluster_clust2)+1;
end

%% plot waveforms
for  i=1:length(patchCluster_clust2)

    plot_neurons(patchCluster_clust2{i},'separate_subplots','dotraces_gray','elidx');
%     plot_neurons(patchCluster_clust1{i},'elidx');
    title(num2str(i));
    screen=get(0,'screensize');


 set(gcf,'Units','normalized','Position',[0.00 0.032 1.00 0.905])
end

%% plot features
% for  i=1:length(patchCluster_clust1)
 plot_neuron_events(patchCluster_real, 20000, [1:15])
% end

%% get 45 minute data
% These electrodes were found manually
load electrode_list
elecWithLargestPeak = [4656        4656        4762        4967        4967        4967        5064        5169        5272        5372        5374        5474        5778        5778        6089        6393        6495];
elecWithLargestPeakUnique = unique(elecWithLargestPeak);
electrode_listPos = [];
%find electrode list positions
iCounter = 1;

%get position in electrode list where electrodes of interest are
for i=1:length(electrode_list) 

    if ~isempty(find(electrode_list(i,1)==elecWithLargestPeakUnique) )
        electrode_listPos(iCounter) = i;
        iCounter=iCounter+1;
    end
    
end

%reduce electrode list to electrodes of interest
electrode_list = electrode_list(electrode_listPos,1:2);

%Now run "auto_load_ntk2.m"

%% reduce size of neuron structure

temp_neur.ts
temp_neur.ts_pos
temp_neur.ts_fidx
temp_neur.trace{1}.ts_idx
temp_neur.trace{1}.data
temp_neur.template.nr_evs %just change numbers [nr_events nr_events ]

