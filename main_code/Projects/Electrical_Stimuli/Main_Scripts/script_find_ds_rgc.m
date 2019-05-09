%% Convert configs for active area
scanConfigDir = ...
    '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc3_tile2x6/';
scanConfigDir = ...
    '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/';

doConvertHex = 0;
fileNameConfig = dir([[ scanConfigDir,'/'], '*hex.nrk2']);
fileNameEl2Fi= dir([[ scanConfigDir,'/'], '*el2fi*']);
for iFile=1:length(fileNameConfig)
    fileNameConfig(iFile).name = strrep(fileNameConfig(iFile).name,'.hex.nrk2','');
    if ~exist(sprintf('%s%s.cmdraw.nrk2', scanConfigDir, fileNameConfig(iFile).name)) ...
            || doConvertHex
        convert_config_hex2cmdraw([scanConfigDir], fileNameConfig(iFile).name);
    end
end
%% Send configs to chip in series in order to visually (manually) scan for activity
timeAtEachConfig = 3;
for iFile=49:1:length(fileNameConfig)
   send_config_to_chip([scanConfigDir], fileNameConfig(iFile).name)
    fprintf('Sent %s\n', fileNameConfig(iFile).name);
    pause(timeAtEachConfig);
end

%% Create flist for moving bar stimulus (run after running stimulus) and 
% !!!!run file.convert_ntk2_files_in_background in another matlab session

[sortGroupNumber flist sortingRunName] = wrapper.make_and_save_flist('neur_patch_scan')
load StimParams_Bars.mat % load moving bar stim parameters
sortingRunName
configs_stim_light = generate_ds_scan_configs_file(Settings, num2cell([1]));

%% load moving bar data and cut events to create activity map 
activity_map = wrapper.patch_scan.extract_activity_map(flist)

%% Select the spikesorting electrodes on the activity map at high-activity location
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
hidens_generate_amplitude_map(activity_map,'no_border','no_colorbar', ...
'no_plot_format','do_use_max');
numStaticEls = 9;  
fprintf('Please select %d electrodes on which to spikesort.', numStaticEls);
while length(nrg.configList.selectedElectrodes) < numStaticEls 
    pause(0.25)
end
fprintf('Done selecting electrodes.\n')
staticEls = nrg.configList.selectedElectrodes;
%%
h = figure, hold on, axis square
hidens_generate_amplitude_map(activity_map,'no_border','no_colorbar', ...
'no_plot_format','do_use_max');
gui.plot_hidens_els('marker_style', 'kx')
junk = input('Select els to spikesort.\nZoom to position and press [enter] to begin:');
figure(h)
staticEls = clickelectrode('color', 'r','num_els',6);
%% spikesort selected electrodes
load StimParams_Bars.mat % load moving bar stim parameters
doSpikesorting = 1;
if doSpikesorting
    [spikes mea1 dataChunkParts concatData] = load_and_spikesort_selected_els(flist,...
        staticEls);  
else
    [junk mea1 dataChunkParts concatData] = load_and_spikesort_selected_els(flist,...
        staticEls,'no_spikesorting');  
end

%% get spike times for each config
spikeTimes = [spikes.assigns' round(2e4*spikes.spiketimes')];
ts = {};
for i=1:length(mea1)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), dataChunkParts(i), ...
        dataChunkParts(i+1));
    ts{i} = spikeTimes(selSpikeTimeInds,:);
    ts{i}(:,2) = ts{i}(:,2)-dataChunkParts(i);
end

%% plot footprints
unique(ts{1}(:,1))'
clusNo = input('Enter cluster number:>>');
clusTsInds = find(ts{1}(:,1)==clusNo);
plot.plot_footprint_from_h5data(mea1,ts{1}(clusTsInds,2))
%% put into neuron structure format
sortGroupNumber = input('Enter sort group number>> ');
sortElGp = input('Enter number for selected el groups>> ');
fileName = sprintf('neur_patch_scan_n_%02d_g_%02d',sortGroupNumber,sortElGp);
if exist(fileName, 'file')
    junk = input('file exists!');
end

for i=1%:length(mea1)
    out = create_neur_struct(mea1{i}, spikes.labels(:,1), ts{i}, 'ds_cell', ...
        flist{i},'load_ntk_fields', {'images.frameno','dac1', 'dac2'});
    % add frame and dac info
    out = add_field_to_structure(out,'file_name', fileName);
    out = add_field_to_structure(out,'configs_stim_light', configs_stim_light);
    out = add_field_to_structure(out,'static_els', staticEls);
    out = add_field_to_structure(out,'flist', flist);
    out = add_field_to_structure(out,'spikes', spikes);
    
 
end
save(sprintf('%s.mat', out.file_name),'out');

%% plot the footprint of scan patch struct - NO NEUROROUTER!
out.cluster_no'
clusterNo =out.cluster_no;
for i=1:length(clusterNo)
h=figure;
gui.plot_hidens_els('marker_style', 'cx'), hold on 
neur_struct.patch_scan.plot.plot_footprint_from_neur_struct(...
    out, 0, 'cluster_no', clusterNo(i),'plot_color', 'b', ...
   'scale', 45);
dateStr = get_date_from_flist(out.flist);
title(sprintf('Date: %s | Cell Name: %s | Cluster %d', dateStr, out.file_name,clusterNo(i)), 'Interpreter', 'none' )
end


% %% plot the footprint of scan patch struct
% out.cluster_no'
% doPlotNeuroRouter= 1;
% clusterNo =8
% nrg = nr.Gui;
% set(gcf, 'currentAxes',nrg.ChipAxesBackground);
% ah = nrg.ChipAxes;
% [nrg2 ah2 ] = neur_struct.patch_scan.plot.plot_footprint_from_neur_struct(...
%     out, doPlotNeuroRouter, 'cluster_no', clusterNo,'plot_color', 'b', ...
%     'fig_h', ah, 'scale', 20);
%% plot DS info
dateStr = get_date_from_flist(out.flist); 
for i=1:length(out.neurons)

    
    %     ,'parapin_transitions_only'
    [Y,I] = sort(Settings.DIRECTIONS(1,:));
    barsPresentedOrder = [I I+8 ];

            figure, hold on
    neur_struct.patch_scan.plot.neur_plot_ds(out,'neur_idx', i,...
        'dir_sort',barsPresentedOrder)
    title(sprintf('Date: %s|Cell Name: %s|Cluster#:%d', dateStr, out.file_name,out.cluster_no(i)), 'Interpreter', 'none' )
    
end
