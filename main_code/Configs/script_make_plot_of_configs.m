% plot_electrode_config_outline(elConfigInfoAll{5},'label', 'name')


% load all configs
dirName.configs = '~/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile6x18/';
% if this var doesn't exist: 
elConfigInfoAll = get_all_config_info(dirName.configs)
load(fullfile(dirName.configs, 'elConfigInfoAll.mat'))
% plot Configs
% nrg = nr.Gui
% set(gcf, 'currentAxes',nrg.ChipAxesBackground)
%%
cmap = jet;
figure, plot_all_electrodes(elConfigInfoAll{1}.info), axis square, hold on

for i=1:length(elConfigInfoAll)   
    % plot waveforms
    plot_electrode_config('el_config_info', elConfigInfoAll{i}.info, ...
        'marker_color', cmap(randi([1, length(cmap)],1,1),:), ...
        'label', num2str(elConfigInfoAll{i}.number), ...
        'marker_style','.');
endn