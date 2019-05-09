% % indices that will be used to go through spike soritng
% clear all;close all
% electrodes_group=1:5;
% for z=2:20
%     electrodes_group(z,:)=electrodes_group(z-1,:)+5;
% ends
% electrodes_group(21,:)=98:102;

% author: ijones.

clear all;close all
rgcs_coordinates=[]; % structure with final coordinates

%% LOAD ALL DATA

% create flist
flist={};
% flist{end+1}= '../proc/Trace_id843_2011-12-06T11_27_53_1.stream.ntk';
flist_for_analysis
% flist_search;
% load data
index_recordings=1;
% 232 seconds
siz=1*60*2e4;
ntk=initialize_ntkstruct(flist{index_recordings},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');
% remove noisy channels and flat channels
ntk2=detect_valid_channels(ntk2,1);

%% PLOT ELECTRODES
% create flist
flist={};
% flist{end+1}= '../proc/Trace_id843_2011-12-06T11_27_53_2.stream.ntk';
flist_for_analysis
siz=1;
ntk_init=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2_init ntk_init]=ntk_load(ntk_init, siz, 'images_v1');
figure, plot_electrode_map(ntk2,'plot_ch')

%% LOAD SELECTED DATA
% 
% indsInPatch_full{1}=[39 40 32 45 29];
% indsInPatch_full{2}=[9 5 34 47 8];
% indsInPatch_full{3}=[41 23 26 16 47];
% indsInPatch_full{4}=[20 46 10];
clear indsInPatch_full
% indsInPatch_full{1}=[39 40 32 45 ]; %#11
% indsInPatch_full{2}=[9 5 34 47 8]; %#8
% % indsInPatch_full{3}=[14 13 25 3 2];%#7
% indsInPatch_full{3}=[20 46 10];%#13
flist={};
% flist{end+1}= '../proc/Trace_id843_2011-12-06T11_27_53_1.stream.ntk';
flist_for_analysis
% load data
index_recordings=1;
% 232 seconds
siz=15*60*2e4;
ntk=initialize_ntkstruct(flist{index_recordings},'hpf', 500, 'lpf', 3000);




useChs = 1;
if ~useChs
     
    [elsInPatch chsInPatch ] = get_electrodes_manual_sorting_patches(ntk2_init,indsInPatch_full,0 );
    clear ntk2
%     [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only',  unique([chsInPatch{1:length(chsInPatch)}]), 'images_v1');
[ntk2 ntk]=ntk_load(ntk, siz, 'keep_only', chsInPatch , 'images_v1');
elseif useChs
    chsInPatch=[114 115 31 55 20 21 116 ...
            68 81 92 79 3 67 ...
            123 124 98 97 33 125 ...
            62 7 102 100 61 96 ...
            18 2 104 57 106 107 ...
            19 110 54 80 52 111 78] 
        
    
    [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only', chsInPatch, 'images_v1');

    
end

% remove noisy channels and flat channels
ntk2=detect_valid_channels(ntk2,1);

% trace name
trace_name=ntk2.fname;
% frequency sampling
Fs=ntk2.sr;
% light time stamps
light_ts=(find(diff(double(ntk2.images.frameno))==1)+860);

%% EXTRACT DATA FOR SPIKE SORTING ***ALL*** CHANNELS

% trace name
trace_name=ntk2.fname;
% frequency sampling
Fs=ntk2.sr;
% light time stamps
light_ts=(find(diff(double(ntk2.images.frameno))==1)+860);
%directions of the bar in degrees

% GET GROUPINGS OF ELECTRODES
[elsInPatch chsInPatch  indsInPatch] = get_electrodes_sorting_patches(ntk2, 6);

%% OPTIONAL! CUSTOM-SELECTED CHANNELS FOR SPECIFIC NEURONS
% % trace name
% trace_name=ntk2.fname;
% % frequency sampling
% Fs=ntk2.sr;
% % light time stamps
% light_ts=(find(diff(double(ntk2.images.frameno))==1)+860); %40ms delay for monitor instruction execution
% %directions of the bar in degrees
% 
% % GET GROUPINGS OF ELECTRODES
% % these indices (not channel numbers!) are obtained from the plot of the circles over the
% % footprints
% 
% [elsInPatch chsInPatch ] = get_electrodes_manual_sorting_patches(ntk2,indsInPatch );

%% RECALC INDICES FOR SELECTED CHANNELS
clear indsInPatch
indsInPatch{1} = 0;
for i=1:length(chsInPatch)
   for j=1:length(chsInPatch{i})
    indsInPatch{i}(j) = find(ntk2.channel_nr == chsInPatch{i}(j));
       
       
   end
end


%% SPIKE SORTING
for i=1:length(indsInPatch)
    
    close all
    clear data spikes
    % channels to be analyzed
    data={ntk2.sig(:,indsInPatch{i})};
    % create parameters
    spikes = [];
    spikes = ss_default_params(Fs);
    spikes.clus_of_interest=[];
    spikes.template_of_interest=[];
    
    % detect spikes
    spikes = ss_detect(data,spikes);
    % align spikes
    spikes = ss_align(spikes);
    % cluster spikes
    spikes = ss_kmeans(spikes);
    spikes = ss_energy(spikes);
    spikes = ss_aggregate(spikes);
    
    % shows clustered spikes
    fprintf('%.f percent completed\n', i/length(indsInPatch)*100);
    
    splitmerge_tool(spikes)
    quest=sprintf('Do you want to continue?');
    reply = input(quest, 's');
    
    %     eval(['spikes',num2str(i),'=spikes']);
    save(strcat('../proc/spikes',num2str(i),'_', ntk2.fname(end-21:end-11),'.mat'), 'spikes' )
end

%% CONVERT TO BEL FORMAT NEURON MATRICES

Fs = 2e4;
% Get file names
procDirName = '../proc/';

% get file names of files containing sorted spikes
spikesFileNames = dir(fullfile(procDirName,strcat('spikes*',ntk2.fname(end-21:end-11),'*.mat')));

for i=1:length(spikesFileNames)
    
    clear spikes neurons
    
    % load spikes data (ums_2000 format)
    load(fullfile(procDirName,spikesFileNames(i).name));
    
    % go through clusters
    k=1;
    clusterNumbers = unique(spikes.assigns);
    badClusters =  find(spikes.labels(:,2)== 4);
    clusterNumbers(badClusters) = [];
    if ~isempty(clusterNumbers)
        for j=clusterNumbers
            % found spike times (in frame numbers = 1/2e4 seconds)
            foundTimes = ceil(spikes.spiketimes(find(spikes.assigns==j))*Fs);
            
            % ensure that ts are within the data range of the file
            maxLoc = find(foundTimes>length(ntk2.sig),1);
            if ~isempty(maxLoc)
                foundTimes = foundTimes(1,1:maxLoc-1);
            end
            foundTimes = ceil(foundTimes);
            
            load('/home/ijones/Matlab/Data_Analysis/myFunctions/blank_neuron.mat')
            
            blank_neuron{1}.ts_fidx  = ones(size(foundTimes))
            
            blank_neuron{1}.ts = double(ntk2.frame_no(foundTimes)); % blank neuron fra
            blank_neuron{1}.fname = ntk2.fname;
            blank_neuron{1}.ts_pos = ones(size(blank_neuron{1}.ts));
            
            badClustersLabels = find(spikes.labels(:,2)==4  );
            badClusters = spikes.labels(badClustersLabels,1);
            
            %         for i = 1:length(badClusters)
            %
            %             if length(badClusters) > 1
            %                 spikesIndToRemove = find(spikes.assigns==badClusters(i));
            %             else
            %                 spikesIndToRemove = spikes.spiketimes(find(spikes.assigns==badClusters));
            %             end
            %             blank_neuron{1}.ts_fidx(spikesIndToRemove) = [];
            %             blank_neuron{1}.ts(spikesIndToRemove) = [];
            %             blank_neuron{1}.ts_pos(spikesIndToRemove) = [];
            %         end
            
            
            % extract traces
            %     y = hidens_extract_traces(blank_neuron)
            y = hidens_extract_traces_noload(blank_neuron,ntk2)
            neurons{k} = y{1}
            
            % this is required for globalize_ts()
            neurons{k}.finfo{1}.timestamp = ntk2.timestamp;
            clear y;
            
            if ~isempty(neurons{k})
                neurons{k}.finfo{1}.timestamp = ntk2.timestamp;
                if ~isfield(neurons{k},'assigns')
                    neurons{k}.assigns = j;
                else
                    neurons{k}.assigns(end+1) = j;
                end
                k=k+1;
            end
            progress_bar((i)/length(spikesFileNames), 1, strcat(num2str(i),'/', num2str(length(spikesFileNames)),'files processed)'));
        end
        
        namingInfo = strfind(spikesFileNames(1).name,'_')-1;
        save(strcat('../proc/neurons_',spikesFileNames(i).name(7:namingInfo),'_', ntk2.fname(end-21:end-11),'.mat'), 'neurons' )
    end
end
%% Merge neurons
neuronsCollected = batch_merge_neurons(ntk2.fname, 0);
%

%% Put neurons in one cell
neuronsCollected = save_neurons_to_cell(ntk2.fname);
%% plot data
mark_neurons_with_circles(neuronsCollected)
plot_neurons(neuronsCollected,'chidx')
save_fp_plot_to_file(neuronsCollected, 3)

%% plot selected neurons
namingInfo = strfind(ntk2.fname,'2011');
figure
 plot_neurons({neuronsCollected{1} neuronsCollected{2} neuronsCollected{3}}, 'chidx');
 title(strcat('File: ', strrep(ntk2.fname(namingInfo+9:end-11),'_','-') ,'Footprints for neurons # 11 8 13'));
 
%   plot_neurons(neuronsCollected{3}, 'chidx')
% this plots the index number for ntk2 channels and electrodes

%% Save info
namingInfo = strfind(ntk2.fname,'2011');
if isempty(namingInfo)
    %
    a = input('Error saving to file');
    clear a;
end
save(strcat('../proc/neuronsCollected_', ntk2.fname(namingInfo+9:end-11),'.mat'), '-v7.3', 'neuronsCollected' )


%% find channels of interest
% load ../proc/neuronsCollected2.mat
figure, plot_neurons(neuronsCollected{19},'el_idx')
elsSel = [5662 5559 5764 5867 5866];
[  chsInPatch] = convert_elidx_to_chs(ntk2,elsSel, 1 )


