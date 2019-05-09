% send visual stimulus

% plot configs
configDirName = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/'

iConfigNumber=1:98
plotConfig = input('Plot electrode config [y/n].','s')
if strcmp(plotConfig,'y')
    figure, hold on
    gui.plot_hidens_els, hold on
    plot_electrode_config_by_num(configDirName, iConfigNumber,'plot_rand_color',...
        'label_with_number');
end
%% select configurations
configNos = [24 26];patternLength = length(configNos);
for i = 1:7
    configNos = [configNos configNos(end-1:end)+...
        7*ones(1,patternLength)];
end
fileNameConfig = configs.get_el_config_names_by_number(configDirName, configNos);

junk = input('Please start visual stimulus and press enter when ready >>');
% send configuration during visual stimulus
configs.send_configs_to_chip(configDirName, fileNameConfig)

%% make flist
[sortGroupNumber flist sortingRunName] = flists.make_and_save_flist;

% compute all activity maps
clear activity_map
for i=1:length(flist)
    activity_map{i} = wrapper.patch_scan.extract_activity_map(flist{i});
    progress_info(i,length(flist));
    
end
%% plot activity maps on array
figure
gui.plot_hidens_els('marker_style', 'cx'), hold on
dirNameConfig = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/';
load(fullfile(dirNameConfig,'configCtrXY'));

for i=1:length(flist)
    hidens_generate_amplitude_map(activity_map{i},'no_border','no_colorbar', ...
        'no_plot_format','do_use_max');
    text(configCtrX(configNos(i)),configCtrY(configNos(i)),num2str(configNos(i)));
end
fprintf('Remember: send config to chip!\n');

