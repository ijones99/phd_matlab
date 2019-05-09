% ---------------- set constants ---------------- %


% mainDirPath = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/4Aug2010_DSGCs_ij/';
% analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec00_39_146/');

% ---------------- load data and save it---------------- %
load(fullfile(analyzedDataDirPath,'electrode_list'));

for i = 1%length(electrode_list)
    load(fullfile(analyzedDataDirPath,strcat('mergDataElectrode',num2str(electrode_list(i,1)),'.mat')));
    plot_neurons(sufficientlyActiveClusters,'dotraces_gray','separate_subplots')
%     plot_neurons(sufficientlyActiveClusters,'elidx')
%     figure, 
%     plot_neurons(sufficientlyActiveClusters)
% 
%     plot_isi(sufficientlyActiveClusters);
%     plot_neuron_events(sufficientlyActiveClusters,20000,[1:length(sufficientlyActiveClusters)])
end

%%
%plot subsets of large cluster structure
for i = 0:ceil(length(sufficientlyActiveClusters)/5)
    try
        plot_neurons(sufficientlyActiveClusters(5*i+1:5*i+5),'separate_subplots','elidx')
    catch
        plot_neurons(sufficientlyActiveClusters(5*i+1:5*i+3),'separate_subplots','elidx')
    end
    %maximize screen
    title(strcat('First cluster = ',num2str(5*i+1)));
    set(gcf,'Units','normalized','Position',[0.00 0.032 1.00 0.905])
end

%%

