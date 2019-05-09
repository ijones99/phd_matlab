5358
5662


colorMaps = [[.1:1/26:1]',[1:-1/26:.1]',[.1:1/26:1]']
colorMaps = rand(30,3);
figure
hold on

for i=1:20
    
   plot([1:10]+i, 'color', colormap( colorMaps(i,:)))
    

end

%%

Folder = {'Rec27_252','Rec27_257','Rec27_259','Rec27_245', 'Rec27_250', };%
flistName = {'flist27_252','flist27_257','flist27_259','flist27_245' ,'flist27_250'};%
cd /home/ijones/Matlab/Spikesorting/MatlabTesting

for p = 4:4

    
%go to directory
eval(['cd ',Folder{p}]);

%load electrode list
load electrode_list

%load ntk data
for i=16:length(electrode_list)
    try
        loadntk2eventsonly('enable_save_data','minutes_to_load', 46,'total_channels_to_load',1,'electrode',6097);
    catch
        disp('error');
    end
end

% cluster data

for i = 1:length(electrode_list)
%     try
        clusterdata('enable_save_data','electrode', electrode_list(i,1));
%     catch
%         disp('error');
%     end
    close all

end
%---------------- Rec27_252 ----------------%

%interactive
activeChannels = electrode_list(:,1);%[4958, 4754, 4753, 4652, 5364, 5363, 5262, 5161, 5466, 5365, 6075, 5978, 5973, 8576, 5672, 6487, 6486, 6386, 6384, 6284, 6283, 6182, 6181, 6080];
errorLoadingClustered = [];


for i = 1:length(activeChannels)
    try
        if isempty(dir(strcat('Merg*',num2str(activeChannels(i)),'*mat')))
            analyzeandmergeclusters('enable_save_data','electrode',activeChannels(i));
        end
        catch
%         errorLoadingClustered(length(errorLoadingClustered)+1)=activeChannels(i);
    end
    close all
%     save errorLoadingClustered errorLoadingClustered
end

% electrodes have light response
% 252: 5262, 5365, 5367, 
% 257: 5365, 
%move down one directory
cd ..
end


%% ---------------- put clusters together---------------- %
% file names
mergedClusterFileName = dir('Merged*mat');
comboNeuron1 = [];
clusterCounter = 1;

for i = 1:length(mergedClusterFileName)
    %load each cluster file
    i
    eval(['load ',mergedClusterFileName(i).name])
    
    % add all clusters to main cluster
    for j = 1:size(sufficientlyActiveClusters,2)
        
        comboNeuron1{clusterCounter} = sufficientlyActiveClusters{j};
        clusterCounter = clusterCounter+1;
    end
    size(comboNeuron1)
end
    
    save -v7.3 comboNeuron1 comboNeuron1
    
    

    
%Michele's data
%     6097
