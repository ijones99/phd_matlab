function create_list_files(flist)
% create_list_files(flist)
% This function creates the two files:
%   ntk2ChannelLookup.mat
%   electrode_list.mat'
%  in the  directory,
% 'analysed_data/', strcat('rec[8 id numbers]/5Channels/',
global  mainDirPath analyzedDataDirPath
mainDirPath
flist
aPrompt = input('ok?')

%create electrode lists
for i=1:length(flist)
    %    load as little data as possible
    siz = 10;
    ntk=initialize_ntkstruct(flist{i},'hpf', 500, 'lpf', 3000);
    [ntk2 ntk]=ntk_load(ntk, siz, 'images_v1'); % images_v1 argument to load ts of image
    ntk2=detect_valid_channels(ntk2,1); % remocmosmea_recordingsve bad channels and compute the noise levels
    % generate lookup file
    ntk2ChannelLookup.el_idx = ntk2.el_idx;
    ntk2ChannelLookup.channel_nr = ntk2.channel_nr;
    
    %
    analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/', strcat('rec',flist{i}(end-11-8:end-11)),'/5Channels/');%create directory
    mkdir(analyzedDataDirPath);%mkdirectory
    electrode_list = generate_electrode_list(ntk2)
    save( fullfile(analyzedDataDirPath,'ntk2ChannelLookup.mat'), 'ntk2ChannelLookup');%save file
    save( fullfile(analyzedDataDirPath,'electrode_list.mat'), 'electrode_list');%save file
    
end