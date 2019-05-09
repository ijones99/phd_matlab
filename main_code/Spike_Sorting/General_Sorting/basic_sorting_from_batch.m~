
% author: ijones.

clear all;close all
rgcs_coordinates=[]; % structure with final coordinates
inputDir = '../analysed_data/T11_27_53_5/01_Pre_Spikesorting/test/';
!chmod a-w ../proc/* 

%% LOAD SELECTED DATA
% create flist

% load data
index_recordings=1;
flistNo = 1;
TIME_TO_LOAD =120; %minutes
flist={};
% flist{end+1}= strcat('../proc/Trace_id843_2011-12-06', flistFileNameID ,'.stream.ntk');
flist_for_analysis
flistFileNameID = flist{flistNo}(end-21:end-11);

siz=1;
ntk_init=initialize_ntkstruct(flist{flistNo},'hpf', 500, 'lpf', 3000);
[ntk2_init ntk_init]=ntk_load(ntk_init, siz, 'images_v1');

clear indsInPatch_full

% indsInPatch_full{1}=[13 28 27 26 29 20]; 
indsInPatch_full{1}=[5 4 15 1 31 28]; 

siz=TIME_TO_LOAD*60*2e4;
ntk=initialize_ntkstruct(flist{index_recordings},'hpf', 500, 'lpf', 3000);
[elsInPatch chsInPatch ] = get_electrodes_manual_sorting_patches(ntk2_init,indsInPatch_full ,0);
clear ntk2

[ntk2 ntk]=ntk_load(ntk, siz, 'keep_only',  unique([chsInPatch{1:length(chsInPatch)}]), 'images_v1');
% remove noisy channels and flat channels
ntk2=detect_valid_channels(ntk2,1);

% trace name
trace_name=ntk2.fname;
% frequency sampling
Fs=ntk2.sr;
% light time stamps
light_ts=(find(diff(double(ntk2.images.frameno))==1)+860);

%% RECALC INDICES FOR SELECTED CHANNELS
clear indsInPatch
indsInPatch{:} = 0;
for i=1:length(chsInPatch)
   for j=1:length(chsInPatch{i})
    indsInPatch{i}(j) = find(ntk2.channel_nr == chsInPatch{i}(j));
   end
end

%% LOAD AGREGATED DATA & SPIKE SORTING
neuronList = 1%[5:15]
for neuronToSortNo = neuronList
    
    eval(['load ',inputDir,'agg_spikes_', num2str(neuronToSortNo),'_', flistFileNameID(1:end),'.mat']);
    
    for i=neuronToSortNo%1:length(indsInPatch)
        
        % shows clustered spikes
%         fprintf('%.f percent completed\n', i/length(indsInPatch)*100);
        
        splitmerge_tool(spikes)
        quest=sprintf('Do you want to continue?');
        reply = input(quest, 's');
        
        %     eval(['spikes',num2str(i),'=spikes']);
        save(strcat(inputDir,'spikes',num2str(i),'_', ntk2.fname(end-21:end-11),'.mat'), 'spikes' )
    end
    fprintf('%.f percent of regions completed\n', neuronToSortNo/length(neuronList)*100);
end
%% CONVERT TO BEL FORMAT NEURON MATRICES

Fs = 2e4;
% Get file names
procDirName = inputDir;

% get file names of files containing sorted spikes
spikesFileNames = dir(fullfile(procDirName,strcat('spikes*',ntk2.fname(end-21:end-11),'*.mat')));

for i=1:length(spikesFileNames)
    try
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
        save(strcat(inputDir,'neurons_',spikesFileNames(i).name(7:namingInfo),'_', ntk2.fname(end-21:end-11),'.mat'), 'neurons' )
    end
    catch
       disp('Error: no neurons saved?') 
        
    end
end
%% Merge neurons
neuronsCollected = batch_merge_neurons(ntk2.fname, 0);
%

%% Put neurons in one cell
neuronsCollected = save_neurons_to_cell(ntk2.fname,inputDir);
%% plot data
mark_neurons_with_circles(neuronsCollected)
plot_neurons(neuronsCollected,'chidx','allactive')
 title(strcat('File: ', strrep(ntk2.fname(namingInfo+9:end-11),'_','-') ,'Footprints for neurons # 8 11 13'));
save_fp_plot_to_file(neuronsCollected, 3,[10 7])

%% plot selected neurons
namingInfo = strfind(ntk2.fname,'2011');
figure
%  plot_neurons({neuronsCollected{1} neuronsCollected{2} neuronsCollected{3}}, 'chidx');
plot_neurons(neuronsCollected, 'chidx');
title(strcat('File: ', strrep(ntk2.fname(namingInfo+9:end-11),'_','-') ,'Footprints for neurons # 8 11 13'));

% plot_neurons(neuronsCollected{8}, 'chidx')
% this plots the index number for ntk2 channels and electrodes
%% plot all neurons from neuronsCollected
namingInfo = strfind(ntk2.fname,'2011');

for i=1:length(neuronsCollected)
    figure
    plot_neurons(neuronsCollected{i}, 'chidx')
    title(strcat('File: ', strrep(ntk2.fname(namingInfo+9:end-11),'_','-') ,'Footprints for neurons # ',num2str(i)));
    save_fp_plot_to_file(neuronsCollected, 1,i)
end

%% remove bad neurons
neursToRemove = [3 4 5 6 7 8 30 32 33 34 35 36 37 38 39 40:45 47 48 49 50 51 52];
neursToRemove = sort(neursToRemove,'descend');
for i=neursToRemove
    %     shift positions left
    neuronsCollected(i:end-1) = neuronsCollected(i+1:end);
    neuronsCollected{end} = 0;
end
neuronsCollected = neuronsCollected(1:end-length(neursToRemove));

%% Save info
namingInfo = strfind(ntk2.fname,'2011');
inputDir = '../analysed_data/' 

% load data from one channel for stim framenumbers
siz=120*60*2e4;
ntk_frameNo=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2_frameNo ntk_frameNo]=ntk_load(ntk_frameNo, siz, 'keep_only',  ntk2.channel_nr(1), 'images_v1');

% stimulus frames
stimFrames = ntk2_frameNo.images.frameno;
stimFrames(end+1:860)=0;
stimFrames(860+1:end)=stimFrames(1:end-860);

% save data
startPos = strfind(ntk2.fname,'T');startPos = startPos(2);
endPos = strfind(ntk2.fname,'stream')-2;

% obtain dir name
fileIdInfo = ntk2.fname(startPos:endPos);
%%
% save to dir
save(strcat(inputDir,'Stim_Frames_',fileIdInfo,'.mat'), 'stimFrames' )



% create timestamp file
for k = 1:length(neuronsCollected)
%     neuronTs = neuronsCollected{k}.ts;
%     neuronFname = neuronsCollected{k}.fname;
%     save(strcat(inputDir,'neuronsCollectedTs_', num2str(k),'_',ntk2.fname(namingInfo+9:end-11),'.mat'), '-v7.3', 'neuronFname', 'neuronTs' );
save_final_neur_data(k, ntk2, neuronsCollected{k}, inputDir)
end

% save(strcat(inputDir,'neuronsCollected_', ntk2.fname(namingInfo+9:end-11),'.mat'), '-v7.3', 'neuronsCollected' )



%% Remove neuron files
% eval(['!rm ../proc/neurons_*', ntk2.fname(namingInfo+10:end-11),'.mat'])
%

