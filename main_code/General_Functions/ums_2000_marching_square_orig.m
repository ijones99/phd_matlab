% % indices that will be used to go through spike soritng
% clear all;close all
% electrodes_group=1:5;
% for z=2:20
%     electrodes_group(z,:)=electrodes_group(z-1,:)+5;
% end
% electrodes_group(21,:)=98:102;
clear all;close all
rgcs_coordinates=[]; % structure with final coordinates

%% LOAD DATA

%

% cd
% /home/michelef/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/17Aug2011_DSGCs/Matlab

% create flist
flist={};

flist{end+1}='data/Trace_id735_2011-08-15T09_28_53_16.stream.ntk';
% flist_search;
% load data
index_recordings=1;
siz=4000000;
ntk=initialize_ntkstruct(flist{index_recordings},'hpf', 500, 'lpf', 3000);
[high_density_data ntk]=ntk_load(ntk, siz, 'images_v1');
% remove noisy channels and flat channels
high_density_data=detect_valid_channels(high_density_data,1);
% get indices of spatially arranged electrodes
[electrodes indices]=sort(high_density_data.el_idx);
ntk2 = high_density_data;

%% EXTRACT DATA FOR SPIKE SORTING

% voltage traces
channels=high_density_data.sig(:,indices);
% spatial coordinates
x=high_density_data.x(indices);
y=high_density_data.y(indices);
el_idx=high_density_data.el_idx(indices);
% trace name
trace_name=high_density_data.fname;
% frequency sampling
Fs=high_density_data.sr;
% light time stamps
light_ts=(find(diff(double(high_density_data.images.frameno))==1)+860);
%directions of the bar in degrees

clear('high_density_data','ntk','siz','light','k','flist','electrodes','indices','index_recordings','i')

%% GROUPING ELECTRODES THAT WILL GO THROUGH SPIKE SORTING

centers=sort(unique(x));
[val1 ind1]=find(x==centers(2)); % Take the second-to-left and second-to-right electrode (in a 18x6 configuration)
[val2 ind2]=find(x==centers(5));
index_centers=[ind1(1:2:length(ind1)) ind2(1:2:length(ind2))];

x_t = x;
y_t = y;
xx=x;
yy=y;
electrodes=el_idx(index_centers);

number_els=6;
close_electrodes=[];
electrodes_group=zeros(length(electrodes),number_els+1);

for i=1:length(electrodes)
    min_dist=[];
    close_electrodes=[];
    p1 = index_centers(i);
    for p2 = 1:length(x_t)
        d = sqrt((x_t(p1)-x_t(p2))^2+(y_t(p1)-y_t(p2))^2);
        min_dist = [min_dist d];
    end
    min_dist(p1)=[+inf];
    
    
    close_electrodes=[p1];
    for j=1:number_els
        [val ind]=min(min_dist);
        close_electrodes=[close_electrodes ind];
        min_dist(ind)=+Inf;
    end
    
    electrodes_group(i,:)=close_electrodes;
    
end
[val ind]=sort(electrodes_group(:,1));
electrodes_group=electrodes_group(ind,:);

%for i=1:length(electrodes_group);figure;plot(x(electrodes_group(i,:)),y(electrodes_group(i,:)),'.r');ylim([1250 1600]);xlim([1130 1220]);hold on;end
clear('centers','val1','val2','ind1','ind2','index_centers','x_t','y_t','xx','yy','close_electrodes','ind','min_dist','d','p1','p2','i','j','number_els','electrodes')


%% SPIKE SORTING

for i=3%:length(electrodes_group)
    
    close all
    % channels to be analyzed
    data={channels(:,electrodes_group(i,:))};
    % create parameters
    spikes = [];
    spikes = ss_default_params(Fs);
    spikes.clus_of_interest=[];
    spikes.template_of_interest=[];
    spikes.x=x;
    spikes.y=y;
    % detect spikes
    spikes = ss_detect(data,spikes);
    % align spikes
    spikes = ss_align(spikes);
    % cluster spikes
    spikes = ss_kmeans(spikes);
    spikes = ss_energy(spikes);
    spikes = ss_aggregate(spikes);
    
    % a hack to get the indices of the channels
    [Y spikes.ntk2Ind ] = ismember(channels(1,electrodes_group(i,:)), ntk2.sig(1,:)    );
    if length(spikes.ntk2Ind) ~= length(ntk2.sig(1,:))
        [Y spikes.ntk2Ind ] = ismember(channels(10,electrodes_group(i,:)), ntk2.sig(10,:)    );
    end
    
    % shows clustered spikes
    splitmerge_tool(spikes)
    
    
    quest=sprintf('Do you want to continue?');
    reply = input(quest, 's');
    
    
    % PLOT AND SELECT
    clus=unique(spikes.assigns);
    for j=1:length(clus)
        
        % plot
        figure('Position',[0.9 0.9 1050 1050],'Color','w')
        subplot(2,3,1);plot_waveforms(spikes, clus(j));
        subplot(2,3,2);plot_residuals(spikes,clus(j));
        subplot(2,3,3);plot_stability(spikes, clus(j));
        subplot(2,3,4);plot_isi(spikes, clus(j));
        subplot(2,3,5);plot_detection_criterion(spikes, clus(j));
        subplot(2,3,6); plot_march_square(spikes,clus(j),light_ts)
        
        % select
        quest=sprintf('Do you want to store coordinates of this RGC?');
        reply = input(quest, 's');
        if isempty(reply)
            reply = 'Y';
        end
        if  upper(reply)=='Y'
            select = get_spike_indices(spikes, clus(j));
            spiketimes = sort(spikes.unwrapped_times(select))*Fs;
            rgcs_traces=[];
            for n=1:size(channels,2)
                cut_waveforms=[];
                for m=1:length(spiketimes)
                    cut_waveforms=[cut_waveforms channels(round(spiketimes(m)-10):round(spiketimes(m)+15),n)];
                end
                rgcs_traces{n}=cut_waveforms;
            end
            
            rgcs_templates=[];
            for v=1:length(rgcs_traces)
                rgcs_templates(:,v)=mean(rgcs_traces{v}')';
            end
            spikes.clus_of_interest=[spikes.clus_of_interest clus(j)];
            spikes.template_of_interest{clus(j)}=rgcs_templates;
            % plot_footprint(spikes,clus(j))
            
        end
        close all
    end
    clear('select','spiketimes','rgcs_traces','cut_waveforms','rgcs_templates','m','n','v','quest','reply','clus','j')
    
    % select electrodes
    for h=1:length(spikes.clus_of_interest)
        rgc_of_interest.pktk=range(spikes.template_of_interest{spikes.clus_of_interest(h)});
        rgc_of_interest.x=spikes.x;
        rgc_of_interest.y=spikes.y;
        rgc_of_interest.clustered_source=electrodes_group(i,:);
        rgc_of_interest.trace_name=trace_name;
        rgc_of_interest.el_idx=el_idx;
        rgc_of_interest.spikes=spikes;
        rgc_of_interest.clus_of_interest=spikes.clus_of_interest(h);  
        rgc_of_interest.light_ts=light_ts;
        rgcs_coordinates{length(rgcs_coordinates)+1}=rgc_of_interest;
    end
    
    % save spike structure
    current_directory=pwd;
    cd([current_directory,'/computed_results'])
    save(['spikes',num2str(i),'_',trace_name(end-12-10:end-11)],'trace_name','spikes');
    cd(current_directory)
end