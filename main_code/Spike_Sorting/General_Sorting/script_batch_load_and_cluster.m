% script_batch_load_and_cluster
global  mainDirPath analyzedDataDirPath

% % elecWithLargestPeak = [4656        4656        4762        4967        4967        4967        5064        5169        5272        5372        5374        5474        5778        5778        6089        6393        6495];
% elecWithLargestPeak = [ 6255        6357        4722        4926        4725        4622        4620        5336        5028        5540        5438        5946 5845        6354];
% 
% elecWithLargestPeakUnique = unique(elecWithLargestPeak);
% j=1;
% for i=1:length(electrode_list)
%     if find(electrode_list(i,1)==elecWithLargestPeakUnique)
%     else
%        nullInd(j) =  i;
%        j=j+1;
%     end
% end
% electrode_list(nullInd,:)=[];

mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/11Jan2011_DSGCs/';
analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec10_31_27/5Channel');
load(fullfile(mainDirPath,'Matlab',strcat('electrode_list'))); %electrode list
number_els = 4;
minutesToLoad = 2;
%load the data
auto_load_ntk2(electrode_list, number_els, minutesToLoad)
%cluster the data
auto_cluster(electrode_list, number_els,minutesToLoad)

mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/23Nov2010_DSGCs/';
analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec18_56_103/');
load(fullfile(mainDirPath,'Matlab',strcat('electrode_list'))); %electrode list
number_els = 4;
minutesToLoad = 2;
%load the data
auto_load_ntk2(electrode_list, number_els, minutesToLoad)
%cluster the data
auto_cluster(electrode_list, number_els,minutesToLoad)


mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/4Aug2010_DSGCs_ij/';
analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec00_39_146/');
load(fullfile(mainDirPath,'Matlab',strcat('electrode_list'))); %electrode list
number_els = 4;
minutesToLoad = 2;
%load the data
auto_load_ntk2(electrode_list, number_els, minutesToLoad)
%cluster the data
auto_cluster(electrode_list, number_els,minutesToLoad)





% mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/5Mar2011_DSGCs_ij/';
% analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec12_21_7/SingleChannel/');
% number_els = 1;
% minutesToLoad = 45;
% 
% auto_load_ntk2(electrode_list, number_els, minutesToLoad)
% %cluster the data
% auto_cluster(electrode_list, number_els,minutesToLoad)

exit