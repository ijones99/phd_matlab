function auto_load_ntk2(electrode_list, number_els, minutesToLoad)
% auto_load_ntk2(electrode_list, number_els, minutesToLoad)

% ---------------- set constants ---------------- %
global electrodeOfInterest
global  mainDirPath analyzedDataDirPath
temp_neurons=cell(0,0);
flist={};
flist_for_analysis
flist
k=1; % file number
siz=20000*60*minutesToLoad; % frames to load
loadAllChannels = 1 ;
doPlot          = 1 ;


fprintf('path = %s \n',analyzedDataDirPath);
% r = input('Correct path?');

% ---------------- load data and save it---------------- %
load(fullfile(analyzedDataDirPath,strcat('ntk2ChannelLookup.mat')));
disp('!!!!!')
length(electrode_list)

for i = 1:size(electrode_list,1)
    electrode_list
    try
        electrodeOfInterest = electrode_list(i,1);
        
        ntk=initialize_ntkstruct(flist{k},'hpf', 500, 'lpf', 3000);
            
        surroundingElectrodes = convertelectrodestochannels(electrodeOfInterest, electrode_list, ntk2ChannelLookup, number_els)
      
        [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only', surroundingElectrodes, 'images_v1');
        siz
        clear ntk
        ntk2=detect_valid_channels(ntk2,1); % remocmosmea_recordingsve bad channels and compute the noise levels
        
        [B XI]=sort(ntk2.el_idx);
        ch_idx=XI;
        
        % hack, with this function "reextract_aligned_traces" crashes...to be fixed
        ntk2.frame_no=[];
        ntk2.frame_no=[1:length(ntk2.sig)];
                
        %save ntk2 struct
        save(fullfile(analyzedDataDirPath,strcat('ntkLoadedDataElectrode',num2str(electrodeOfInterest),'.mat')),'ntk2','-v7.3');
          
    catch
        beep()
        i
        electrode_list
        fprintf('Error with electrode')
    end
end
end