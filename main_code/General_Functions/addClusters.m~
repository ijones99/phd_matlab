% ---------------- set constants ---------------- %


% mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/4Aug2010_DSGCs_ij/';
% analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec00_39_146/');
% mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/5Mar2011_DSGCs_ij/';
% analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec12_21_7/');
mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/11Jan2011_DSGCs/';
analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec48_16_1/');
mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/5Mar2011_DSGCs_ij/';
analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec12_21_7/');

fprintf('path = %s \n',analyzedDataDirPath);
r = input('Correct path?')


% ---------------- load data and save it---------------- %
load electrode_list;


patchCluster = [];
countPatchClust = 1;

%go through list of electrodes
for i = 1:length(electrode_list)
    %load data
    load(fullfile(analyzedDataDirPath,strcat('mergDataElectrode',num2str(electrode_list(i,1)),'.mat')));
    
    %go through all clusters per file
    for j = 1:length(sufficientlyActiveClusters)
        patchCluster{countPatchClust}=sufficientlyActiveClusters{j};
        countPatchClust = countPatchClust+1;
    end
    
    fprintf('---- loop number %d ----\n',i);
    
end

% save data --> all clusters in patch
save(fullfile(analyzedDataDirPath,strcat('patchClust.mat')),'patchCluster');