%% SORT
%init vars
global mainDirPath
global analyzedDataDirPath
cd(strcat(mainDirPath,'Matlab/'))
% temp_neurons = {};
% temp_neuronsLength = length(temp_neurons)
% Go 2 - 75
close all

k=4; % patch number

% cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/13Oct2010_DSGCs/Matlab

flist={};
flist_search;
siz=4;
ntk=initialize_ntkstruct(flist{k},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');
ntk2=detect_valid_channels(ntk2,1);

[B XI]=sort(ntk2.el_idx);
ch_idx=XI;
%%

for i =1:length(temp_neurons)
    try
    [Imax,Ymax] = max(temp_neurons{i}.template.data,[],1);
    [Imin,Ymin] = min(temp_neurons{i}.template.data,[],1);
    peak2PeakValues = (Imax-Imin);
    [I,Y] = max(peak2PeakValues);
    
    temp_neurons(i)=plot_RGCs_bar_response(temp_neurons(i),'interactive' );
    catch
        disp('error')
        
    end
end