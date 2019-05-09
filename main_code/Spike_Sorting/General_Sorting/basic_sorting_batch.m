function basic_sorting_batch_all_permutations

clear all;close all

indSpec = 0;
chSpec = ~indSpec;

SORT_ALL = 1;

LOOP_OFFSET = 0; %use if the numbers do not start at 1. Default 0;
rgcs_coordinates=[]; % structure with final coordinates
%% settings
TIME_TO_LOAD = 120;%mins

% load flist with all file names

flist={};
flist_for_analysis

for flistFileNo = 1+LOOP_OFFSET:length(flist)+LOOP_OFFSET
%% LOAD SELECTED DATA

% get ntk2 data field values
siz=1;
ntk_init=initialize_ntkstruct(flist{flistFileNo},'hpf', 500, 'lpf', 3000);
[ntk2_init ntk_init]=ntk_load(ntk_init, siz, 'images_v1');
% 
% indsInPatch_full{3}=[41 23 26 16 47];
% indsInPatch_full{4}=[20 46 10];
clear indsInPatch_full indsInPatch


% indsInPatch_full{1}=[9 5 34 47 8]; %#8
% indsInPatch_full{2}=[39 40 32 45 29]; %#11
% % indsInPatch_full{3}=[14 13 25 3 2];%#7
% indsInPatch_full{3}=[20 46 10];%#13
% indsInPatch_full{1}=[]; %#8
% indsInPatch_full{2}=[]; %#8
% indsInPatch_full{3}=[]; %#8
% indsInPatch_full{1+LOOP_OFFSET}=[36 33 15 6 17]; %#8
% indsInPatch_full{2+LOOP_OFFSET}=[14 13 25 3 2]; %#11
% % indsInPatch_full{3}=[14 13 25 3 2];%#7
% indsInPatch_full{3+LOOP_OFFSET}=[25 15 14 17 2];%#13
% indsInPatch_full{4+LOOP_OFFSET}=[41 16 26 23 47]
% % flist_search;
% load data

% frames to load
siz=TIME_TO_LOAD*60*2e4;
ntk=initialize_ntkstruct(flist{flistFileNo},'hpf', 500, 'lpf', 3000);

if ~SORT_ALL
    if indSpec
        [elsInPatch chsInPatch ] = get_electrodes_manual_sorting_patches(ntk2_init,indsInPatch_full );
        clear ntk2
        [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only',  unique([chsInPatch{1:length(chsInPatch)}]), 'images_v1');
    elseif chSpec
        chsInPatch=[114 115 31 55 20 21 116 ...
            68 81 92 79 3 67 ...
            123 124 98 97 33 125 ...
            62 7 102 100 61 96 ...
            18 2 104 57 106 107 ...
            19 110 54 80 52 111 78]
        clear ntk2
        [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only',  chsInPatch, 'images_v1');
    end
else
    
    [ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');
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
if SORT_ALL
    % trace name
    trace_name=ntk2.fname;
    % frequency sampling
    Fs=ntk2.sr;
    % light time stamps
    light_ts=(find(diff(double(ntk2.images.frameno))==1)+860);
    %directions of the bar in degrees
    
    % GET GROUPINGS OF ELECTRODES
    TIMEOUT = 50
    for i= 1:TIMEOUT
        try
            [elsInPatch chsInPatch  indsInPatch] = get_electrodes_sorting_patches(ntk2, 6);
        catch
            disp('Error calling figure')
        end
    end
    
end

%% RECALC INDICES FOR SELECTED CHANNELS
clear indsInPatch
indsInPatch{1} = 0;
for i=1:length(chsInPatch)
   for j=1:length(chsInPatch{i})
    indsInPatch{i}(j) = find(ntk2.channel_nr == chsInPatch{i}(j));
       
       
   end
end


%% SPIKE SORTING
for i=5+LOOP_OFFSET:length(indsInPatch)+LOOP_OFFSET
    fileDone = 1;
    save('../Matlab/file_completed.mat','fileDone');
    
    
    tic
    
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
    
    save(strcat('../proc/agg_spikes_',num2str(i),'_', ntk2.fname(end-21:end-11),'.mat'), 'spikes' )
    fprintf('-----------------------------------------------------')
    toc
end

end
