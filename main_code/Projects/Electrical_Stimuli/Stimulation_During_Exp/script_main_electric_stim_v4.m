%% Convert configs for active area
scanConfigDir = ...
    '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc3_tile2x6/';
doConvertHex = 1;
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
timeAtEachConfig = 4;
for iFile=1:length(fileNameConfig)
   send_config_to_chip([scanConfigDir], fileNameConfig(iFile).name)
    fprintf('Sent %s\n', fileNameConfig(iFile).name);
    pause(timeAtEachConfig);
end

%% Create flist for moving bar stimulus (run after running stimulus) and 
sortGroupNumber = 1;
makeNewFlist = 1;
% ------------------------------------
fprintf('Group number = %d\n', sortGroupNumber);
m = input('okay?') ; clear m
nrkFileGroups = num2cell([1:2]); 
expName = path_name_decomposition(pwd,'part_no',2,'reverse','string_out');
% ---------------------------------------------- %
load StimParams_Bars.mat % stim parameters
sortingRunName = sprintf('cell_search_scan_%02d',sortGroupNumber);disp(sortingRunName)
configs_stim_light = generate_ds_scan_configs_file(Settings, nrkFileGroups);
if makeNewFlist, 
    make_flist_select(sprintf('flist_cell_search_%02d.m',sortGroupNumber))
end
flist = {};eval([sprintf('flist_cell_search_%02d',sortGroupNumber)]);
flistFileNameID = get_flist_file_id(flist{1}); % use first flist value
save(sprintf('%s_configurations.mat', sortingRunName ), 'configs_stim_light','flist');

%% load moving bar data and cut events for activity map 
flistNo = 1;
chunkSize = 2e4*60*4;
ntk=initialize_ntkstruct(flist{flistNo},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'digibits');
thr_f=4;
pretime=16;
posttime=16;
allevents=simple_event_cut(ntk2, thr_f, pretime, posttime);
activity_map=convert_events(allevents,ntk2)

%% Select the spikesorting electrodes on the activity map at high-activity location
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
hidens_generate_amplitude_map(activity_map,'no_border','no_colorbar', ...
'no_plot_format');
numStaticEls = 8;  
fprintf('Please select %d electrodes on which to spikesort.', numStaticEls);
while length(nrg.configList.selectedElectrodes) < numStaticEls 
    pause(0.25)
end
fprintf('Done selecting electrodes.\n')
staticEls = nrg.configList.selectedElectrodes;

%% spikesort selected electrodes
doSpikesorting = 1;
if doSpikesorting
    [spikes mea1 dataChunkParts concatData] = load_and_spikesort_selected_els(flist,...
        staticEls);  % 'force_file_conversion'
    save(sprintf('%s_spikes.mat', sortingRunName ), 'spikes');
else
    [junk mea1 dataChunkParts concatData] = load_and_spikesort_selected_els(flist,...
        staticEls,'no_spikesorting');  % 'force_file_conversion'
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

%% put into neuron structure format
fileName = 'patch_scan_n_';
for i=1%:length(mea1)
    out = create_neur_struct(mea1{i}, spikes.labels(:,1), ts{i}, 'ds_cell', ...
        flist{i},'load_ntk_fields', {'images.frameno','dac1', 'dac2'});
    % add frame and dac info
    
    out = add_field_to_structure(out,'configs_stim_light', configs_stim_light);
    out = add_field_to_structure(out,'static_els', staticEls);
    
    fileNameNew = get_consecutive_filename(fileName)
    save(sprintf('%s.mat', fileNameNew),'out');
end

%% plot the footprint
doPlotNeuroRouter= 1;
clusterNo = 8;
[nrg ah ] = plot_footprint_from_neur_struct(...
    out, doPlotNeuroRouter, 'cluster_no', clusterNo);

%% plot DS info
for i=1:length(out.neurons)
    figure, hold on
    neur_struct.patch_scan.neur_plot_ds(out,'neur_idx', i)
    title(sprintf('Cluster %d', out.cluster_no(i)))
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%-------------- DO THE REGIONAL SCAN (of specific area) ----------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create configs for scanning area
sortGroupNumber = 7;
all_els=hidens_get_all_electrodes(2);
sortingRunName = sprintf('regional_scan_%02d',sortGroupNumber);
fprintf('sortingName = %s \n', sortingRunName);
m = input('okay?')
scanConfigDir = sprintf('../Configs/%s/', sortingRunName );

eval(['!mkdir -p ',scanConfigDir])

fprintf('Select init seg electrode(s).\n');
% get static els near init segment
numStaticEls = 7;
while length(nrg.configList.selectedElectrodes) < numStaticEls 
    pause(0.25)
end
staticEls = nrg.configList.selectedElectrodes;
fprintf('Done selecting fixed (init segment) electrodes.\n')

m = input('Press key> ');
% get scanning els
[scanEls indsLocalInside] = select_els_in_sel_pt_polygon( all_els, 'num_points',8 )
fprintf('Done selecting scanning electrodes.\n')

pause(0.5)
% get area to scan
configs_stim_light = generate_specific_point_defined_stim_configs(scanEls, staticEls,...
    sortingRunName, 'no_plot')

out={};
out = add_field_to_structure(out,'type', 'regional_scan');
out = add_field_to_structure(out,'el_configs', el_configs);
out = add_field_to_structure(out,'scan_els', scanEls);
out = add_field_to_structure(out,'inds_local_inside', indsLocalInside);
out = add_field_to_structure(out,'static_els', staticEls);

%% send configurations to chip while showing stimulus %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------ SETTINGS ------------------ %
ipAddress = 'bs-dw17';
neurolizerSlotNo = 0;
recordTime = 20; % seconds
% ---------------------------------------------- %
fileNameConfig = dir([[ scanConfigDir,'/'], '*hex.nrk2']);
for i=1:length(fileNameConfig)
    fileNameConfig(i).name = strrep(fileNameConfig(i).name,'.hex.nrk2','');
end

if scanConfigDir(end) ~= '/';
    scanConfigDir(end+1) = '/';
end

for i=1:length(fileNameConfig)
    % Convert hex to cmdraw.nrk2
    i
    doConvertHex = 0;
    if ~exist(sprintf('%s%s.cmdraw.nrk2', scanConfigDir, fileNameConfig(i).name)) || doConvertHex
        convert_config_hex2cmdraw(['../Configs/', scanConfigDir], fileNameConfig(i).name)
    end
    
    % Send config to chip
    send_config_to_chip([ scanConfigDir], fileNameConfig(i).name)
    fprintf('send to chip: %s\n', strcat([ scanConfigDir], fileNameConfig(i).name));
    pause(0.5);
    hidens_startSaving(neurolizerSlotNo,ipAddress,'','');
    pause(recordTime);
    hidens_stopSaving(neurolizerSlotNo,ipAddress);
    pause(0.5);
    fprintf('-------------- Progress %.0f -------------- /n',100*i/length(fileNameConfig))
end
disp('Done.')
%% spikesort different patches with shared (static) electrodes ...
% (near initial segment)
% ------------------ SETTINGS ------------------ %
doMakeFlistNew = 1;
expName = path_name_decomposition(pwd,'part_no',2,'reverse','string_out');
% ---------------------------------------------- %
load StimParams_Bars.mat
nrkFileGroups = num2cell([1:length(fileNameConfig)]);
configs_stim_light = generate_ds_scan_configs_file(Settings, nrkFileGroups);
sortGroupNumber
fprintf('sortingRunName = %s\n', sortingRunName);
m = input('okay?')
if doMakeFlistNew
    make_flist_select(['flist_',sortingRunName,'.m'])
end
flist = {};eval(['flist_',sortingRunName]);
% save(sprintf('%s_configurations.mat', sortingRunName ), 'configs_stim_light','flist');
out = add_field_to_structure(out,'configs_stim_light', configs_stim_light);
out = add_field_to_structure(out,'flist', flist);

%% Convert to h5

ntkData = {};
for i=1:length(flist)
    try
        mysort.mea.convertNTK2HDF(flist{i},'prefilter', 1);
    catch
        fprintf('already converted.\n')
    end
%     ntkData{i} = get_fields_from_ntk_file(flist{1}, fieldNames)
    fprintf('progress %3.0f\n', 100*i/length(flist));
end
%% load all h5 files (regional scan)
[spikes mea1 dataChunkParts concatData] = ...
    load_and_spikesort_selected_els(flist, staticEls);
save([sortingRunName,'_ums_sorting'], 'spikes');
fprintf('Saving completed.\n');
% save([sortingRunName,'_concatenated_data'], 'concatData', 'dataChunkParts')
out = add_field_to_structure(out,'concat_data', concatData);
out = add_field_to_structure(out,'data_chunk_parts', dataChunkParts);
out = add_field_to_structure(out,'spikes', spikes);

fprintf('Saving completed.\n');
%% get spike times for each config
spikeTimes = [spikes.assigns' round(2e4*spikes.spiketimes')];
ts = {};
for i=1:length(mea1)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), dataChunkParts(i), ...
        dataChunkParts(i+1));
    ts{i} = spikeTimes(selSpikeTimeInds,:);
    ts{i}(:,2) = ts{i}(:,2)-dataChunkParts(i);
end
doPlotNeuroRouter= 1;
out = add_field_to_structure(out,'ts', ts);
%%
fileName = 'regional_scan_n_'; 

umsClusNo = 37;
fileNameSuffix = num2str(1);
[footprint.mposx footprint.mposy mat footprint.wfs] = construct_footprint_from_mea1_data(mea1, ...
    umsClusNo, ts);

nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
ah = nrg.ChipAxes;

plot_footprints_simple([footprint.mposx footprint.mposy], ...
    footprint.wfs, ...
    'input_templates','hide_els_plot','format_for_neurorouter',...
    'plot_color','b', 'flip_templates_ud','flip_templates_lr','scale', 70);
save([sortingRunName,'_completeFootprint'], 'footprintWaveforms','mposx', 'mposy')
fprintf('Saving completed.\n');

out = add_field_to_structure(out,'footprint', footprint);
out = add_field_to_structure(out,'cluster_no', umsClusNo);
save(sprintf('neur_%s.mat', fileName),'out');

fileNameNew = get_consecutive_filename(fileName);
save(sprintf('%s.mat', fileNameNew),'out');

%% compile movie
movie.simpleMovie( mposx, mposy, mat' , 'CAxis' , [-15 2] , 'Directory', ...
    [ sortingRunName,'_gp_', num2str(umsClusNo)]);

%% open chip viewer
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)

%% plot footprint on NeuroRouter

umsClusNo = 1;

maxNumWFs = 50;
for i=1:length(mea1)
    try
        clusterInds = find(ts{i}(:,1)==umsClusNo);
        if length(clusterInds) > maxNumWFs
            clusterInds = clusterInds(1:maxNumWFs);
        end
        spikeTimesSamples = ts{i}(clusterInds,2);
        h5Data = mea1{i};
        [data] = extract_waveforms_from_h5(h5Data, spikeTimesSamples );
        
        dataOffsetCorr = data.average-repmat(mean(data.average(:,end-30:end),2),1,size(data.average,2));
        
        plot_footprints_simple([data.x data.y], ...
            dataOffsetCorr, ...
            'input_templates','hide_els_plot','format_for_neurorouter',...
            'plot_color','b');

    catch
        fprintf('No spikes for %d.\n', i)
    end
    drawnow
 
end

