% send visual stimulus
figure, hold on
% plot configs
configDirName = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/'

gui.plot_hidens_els, hold on
iConfigNumber=1:98
plot_electrode_config_by_num(configDirName, iConfigNumber,'plot_rand_color',...
    'label_with_number')
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
%% Select the spikesorting electrodes on the activity map at high-activity location
flistNo = input('flist number >>');
flist{flistNo}
fileNameConfig{flistNo}
h = figure; hold on, axis square
hidens_generate_amplitude_map(activity_map{flistNo},'no_border','no_colorbar', ...
'no_plot_format','do_use_max');
gui.plot_hidens_els('marker_style', 'cx')
junk = input('Select els to spikesort.\nZoom to position and press [enter] to begin:');
figure(h)
staticEls = clickelectrode('color', 'r','num_els',6);
fprintf('Done.\n')

%% spikesort selected electrodes
flistNo = input('flist#: ');
junk = input(sprintf('flist = %s. Ok?',flist{flistNo}));
doSpikesorting = 1;
if doSpikesorting
    [spikes meaData dataChunkParts concatData] = load_and_spikesort_selected_els(flist(flistNo),...
        staticEls);  
else
    [junk meaData dataChunkParts concatData] = load_and_spikesort_selected_els(flist(flistNo),...
        staticEls,'no_spikesorting');  
end

%% get spike times for each config
spikeTimes = [spikes.assigns' round(2e4*spikes.spiketimes')];
ts = {};
for i=1:length(meaData)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), dataChunkParts(i), ...
        dataChunkParts(i+1));
    ts{i} = spikeTimes(selSpikeTimeInds,:);
    ts{i}(:,2) = ts{i}(:,2)-dataChunkParts(i);
end

%% plot footprints
foundClus = unique(ts{1}(:,1))';
for clusNo = foundClus
    try
    clusTsInds = find(ts{1}(:,1)==clusNo);
    plot.plot_footprint_from_h5data(meaData,ts{1}(clusTsInds,2))
    title(sprintf('Cluster %d',clusNo));
    end
end
fprintf('Done plotting.\n')
%% put into neuron structure format
sortGroupNumber = input('Enter sort group number>> ');
sortElGp = input('Enter number for selected el groups>> ');
fileName = sprintf('neur_patch_scan_n_%02d_g_%02d',sortGroupNumber,sortElGp);
if exist(fileName, 'file')
    junk = input('file exists!');
end

for i=1%:length(meaData)
    out = create_neur_struct(meaData{i}, spikes.labels(:,1), ts{i}, 'ds_cell', ...
        flist{i},'load_ntk_fields', {'images.frameno','dac1', 'dac2'});
    % add frame and dac info
    out = add_field_to_structure(out,'file_name', fileName);
    out = add_field_to_structure(out,'configs_stim_light', configs_stim_light);
    out = add_field_to_structure(out,'static_els', staticEls);
    out = add_field_to_structure(out,'flist', flist);
    out = add_field_to_structure(out,'spikes', spikes);
    
 
end
save(sprintf('%s.mat', out.file_name),'out');

%% plot the footprint of scan patch struct!
% out.cluster_no'
% clusterNo =input('Select cluster
% for i=1:length(clusterNo)
% h=figure;
% gui.plot_hidens_els('marker_style', 'cx'), hold on 
% neur_struct.patch_scan.plot.plot_footprint_from_neur_struct(...
%     out, 0, 'cluster_no', clusterNo(i),'plot_color', 'b', ...
%    'scale', 45);
% dateStr = get_date_from_flist(out.flist);
% title(sprintf('Date: %s | Cell Name: %s | Cluster %d', dateStr, out.file_name,clusterNo(i)), 'Interpreter', 'none' )
% end

%% plot DS info
dateStr = get_date_from_flist(out.flist); 
for i=1:length(out.neurons)

    [Y,I] = sort(Settings.DIRECTIONS(1,:));
    barsPresentedOrder = [I I+8 ];

            figure, hold on
    neur_struct.patch_scan.plot.neur_plot_ds(out,'neur_idx', i,...
        'dir_sort',barsPresentedOrder)
    title(sprintf('Date: %s|Cell Name: %s|Cluster#:%d', dateStr, out.file_name,out.cluster_no(i)), 'Interpreter', 'none' )
    
end
