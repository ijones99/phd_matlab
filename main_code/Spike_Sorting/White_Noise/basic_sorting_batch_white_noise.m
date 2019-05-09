function basic_sorting_batch_white_noise

% % indices that will be used to go through spike sorting
% clear all;close all
% electrodes_group=1:5;
% for z=2:20
%     electrodes_group(z,:)=electrodes_group(z-1,:)+5;
% ends
% electrodes_group(21,:)=98:102;

% author: ijones.



clear all;close all

LOOP_OFFSET = 0; %use if the numbers do not start at 1. Default 0;
rgcs_coordinates=[]; % structure with final coordinates
%% settings
TIME_TO_LOAD = .2;%mins

% load flist with all file names
loadedDataFiles = dir('../proc/loadedData*mat');


flist={};
flist_for_sel


for flistFileNo = 1+LOOP_OFFSET:length(flist)+LOOP_OFFSET
%% LOAD SELECTED DATA

load(fullfile('../proc/',loadedDataFiles(flistFileNo).name));


%% RECALC INDICES FOR SELECTED CHANNELS
clear indsInPatch
indsInPatch{1} = 0;
indsInPatch{2} =  indsInPatch{1} ;
   for j=1:length(chsInPatch{flistFileNo})
    indsInPatch{flistFileNo}(j) = find(ntk2.channel_nr == chsInPatch{flistFileNo}(j));
       
       
   end



%% SPIKE SORTING
for i=1+LOOP_OFFSET:length(indsInPatch)+LOOP_OFFSET
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
    
    save(strcat('../proc/second_round/rerun/agg_spikes_',num2str(i),'_', ntk2.fname(end-21:end-11),'.mat'), 'spikes' )
    fprintf('-----------------------------------------------------')
    toc
end

end
