dirNameFig = '../analysed_data/Figures/receptive_fields/';
fileNameFig = 'rf_outlines';
supTitle = 'Title';

save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
    'font_size_all', 13 , ...
    'x_label', 'Neuron Index','y_label', 'Spike Rate (spikes/sec)',...
    'sup_title', supTitle);

%% no x-label

dirNameFig = '~/Desktop/';
fileNameFig = 'test';
supTitle = 'Title';

save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps'})
figs.font_size(13);
suptitle(supTitle);

%% save fig for publication in frontiers


figure, hist(param_Moving_Bars_DS.ds_fr_fast_on,30);
title('DS Index');
xlabel('Index');
ylabel('Cell Count');
fileName = 'moving_bars_ds_index';
dirName = '~/ln/vis_stim_hamster/Figs/';
figs.format_hist_for_pub('journal_name', 'frontiers');
figs.format_for_pub;
figs.save_for_pub(fullfile(dirName,fileName))
