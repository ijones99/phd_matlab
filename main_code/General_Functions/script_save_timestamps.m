%script save timestamps
% #2
global targetDir
% targetDir = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/5Mar2011_DSGCs_ij/analysed_data/rec12_21_7/5Channels'
fileList = dir(fullfile(targetDir,'clustDataElectrode*mat')); %get list of all files;


for i=1:size(fileList,1)
    
    fprintf('%.2f\n',i/size(fileList,1))
    clear tsData
    load(fullfile(targetDir,fileList(i).name)); %load data
    
    for j = 1:size(sufficientlyActiveClusters,2)
        sufficientlyActiveClusters{j}.trace=[];% remove field 'trace'
    end
    tsData = cell(size(sufficientlyActiveClusters)); % create empty cell for data
    tsData = sufficientlyActiveClusters; % assign data to cell
    clear sufficientlyActiveClusters;
    save(fullfile(targetDir,strcat('tsData',fileList(i).name(end-7:end-4),'.mat')),'tsData');% save cell
       

end