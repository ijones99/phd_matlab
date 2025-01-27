% ---------------- set constants ---------------- %
global mainDirPath
global  analyzedDataDirPath
global electrodeOfInterest
load(fullfile(analyzedDataDirPath,strcat('electrode_list.mat')));
load(fullfile(analyzedDataDirPath,strcat('ntk2ChannelLookup.mat')));

channelOfInterest = find(electrode_list(:,1)==electrodeOfInterest);

fprintf('path = %s \n',analyzedDataDirPath);
r = input('Correct path?')

% ---------------- load data and save it---------------- %
% load electrode_list;
%%

for i = 1:length(electrode_list)
    close all
    try
        load(fullfile(analyzedDataDirPath,strcat('clustDataElectrode',num2str(electrode_list(i,1)),'.mat')));
        sufficientlyActiveClusters=merge_neurons(sufficientlyActiveClusters,'interactive',1,'no_isi');
        plot_neurons(sufficientlyActiveClusters,'dotraces_gray','separate_subplots')
        save(fullfile(analyzedDataDirPath,strcat('mergDataElectrode',num2str(electrode_list(i,1)),'.mat')),'sufficientlyActiveClusters');
    catch
        disp('error')
    end
    fprintf('---- loop number %d/%d ----\n',i,length(electrode_list));
end

%% plot
%%

for i = 1:4%:length(electrode_list)
    
    electrode_list(i,1)
    load(fullfile(analyzedDataDirPath,strcat('mergDataElectrode',num2str(electrode_list(i,1)),'.mat')));
%     figure
    plot_neurons(sufficientlyActiveClusters,'dotraces_gray','separate_subplots')
    %     figure
    %     plot_neurons(sufficientlyActiveClusters)
    fprintf('---- loop number %d ----\n',i);
end