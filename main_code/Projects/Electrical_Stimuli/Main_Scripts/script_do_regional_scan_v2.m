%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%-------------- DO THE REGIONAL SCAN (of specific area) ----------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do donut scan
all_els=hidens_get_all_electrodes(2);
sortGroupNumber = input('Enter sort group number>> ');
sortingRunName = sprintf('neur_regional_scan_n_%02d',sortGroupNumber)

scanConfigDir = sprintf('../Configs/%s/', sortingRunName );
eval(['!mkdir -p ',scanConfigDir])

% get static els near init segment
figNo = input('Enter figure number:>> ');
figure(figNo)
junk = input('Select init seg electrode(s).\nZoom to position and press [enter] to begin:');
staticEls = clickelectrode('color', 'r','num_els',6);
fprintf('Done selecting fixed (init segment) electrodes.\n')

m = input('Press key to select region to record from.>> ');
% get scanning els
% [scanEls indsLocalInside] = select_els_in_sel_pt_polygon( ...
%     all_els, 'num_points',15)
center = [];
fprintf('click on center of config:>> ');
[center(1) center(2)] = ginput(1);
rIn = 150; rOut = 200;
[scanEls areaOutInds] = els.get_electrodes_in_donut(center, rIn, rOut);

fprintf('Done selecting scanning electrodes.\n')

% get area to scan
configs_stim_light = generate_specific_point_defined_stim_configs(scanEls,...
    staticEls,  sortingRunName, 'no_plot')

out={};
out = add_field_to_structure(out,'type', 'regional_scan');
% out = add_field_to_structure(out,'el_configs', el_configs);
out = add_field_to_structure(out,'scan_els', scanEls);
try
out = add_field_to_structure(out,'inds_local_inside', indsLocalInside);
end
out = add_field_to_structure(out,'static_els', staticEls);

% Convert hex to cmdraw.nrk2
fileNameConfig = dir([[ scanConfigDir,'/'], '*hex.nrk2']);
for i=1:length(fileNameConfig)
    fileNameConfig(i).name = strrep(fileNameConfig(i).name,'.hex.nrk2','');
end
for i=1:length(fileNameConfig)
    doConvertHex = 0;
    if ~exist(sprintf('%s%s.cmdraw.nrk2', scanConfigDir, fileNameConfig(i).name)) || doConvertHex
        convert_config_hex2cmdraw(['../Configs/', scanConfigDir], fileNameConfig(i).name)
    end
end







%% create configs for scanning area
all_els=hidens_get_all_electrodes(2);
sortGroupNumber = input('Enter sort group number>> ');
sortingRunName = sprintf('neur_regional_scan_n_%02d',sortGroupNumber)

scanConfigDir = sprintf('../Configs/%s/', sortingRunName );
eval(['!mkdir -p ',scanConfigDir])

% get static els near init segment
figNo = input('Enter figure number:>> ');
figure(figNo)
junk = input('Select init seg electrode(s).\nZoom to position and press [enter] to begin:');
% staticEls = clickelectrode('color', 'r','num_els',6);
fprintf('Done selecting fixed (init segment) electrodes.\n')

m = input('Press key to select region to record from.>> ');
% get scanning els
[scanEls indsLocalInside] = select_els_in_sel_pt_polygon( ...
    all_els, 'num_points',15)
fprintf('Done selecting scanning electrodes.\n')

% get area to scan
configs_stim_light = generate_specific_point_defined_stim_configs(scanEls,...
    staticEls,  sortingRunName, 'no_plot')

out={};
out = add_field_to_structure(out,'type', 'regional_scan');
% out = add_field_to_structure(out,'el_configs', el_configs);
out = add_field_to_structure(out,'scan_els', scanEls);
out = add_field_to_structure(out,'inds_local_inside', indsLocalInside);
out = add_field_to_structure(out,'static_els', staticEls);

% Convert hex to cmdraw.nrk2
fileNameConfig = dir([[ scanConfigDir,'/'], '*hex.nrk2']);
for i=1:length(fileNameConfig)
    fileNameConfig(i).name = strrep(fileNameConfig(i).name,'.hex.nrk2','');
end
for i=1:length(fileNameConfig)
    doConvertHex = 0;
    if ~exist(sprintf('%s%s.cmdraw.nrk2', scanConfigDir, fileNameConfig(i).name)) || doConvertHex
        convert_config_hex2cmdraw(['../Configs/', scanConfigDir], fileNameConfig(i).name)
    end
end


%% send configurations to chip while showing stimulus %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
configs.send_configs_to_chip(scanConfigDir, fileNameConfig)
%% create flist for different patches with shared (static) electrodes ...
% (near initial segment)
% ------------------ SETTINGS ------------------ %
sortGroupNumber = input('Enter sort group number>> ');
sortingRunName = sprintf('neur_regional_scan_n_%02d',sortGroupNumber);
doMakeFlistNew = prompt_for_string_selection('Make new flist?', 'yes_no');
expName = path_name_decomposition(pwd,'part_no',2,'reverse','string_out');
% ---------------------------------------------- %
load StimParams_Bars.mat
nrkFileGroups = num2cell([1:length(fileNameConfig)]);
% configs_stim_light = generate_ds_scan_configs_file(Settings, nrkFileGroups);

fprintf('sortingRunName = %s\n', sortingRunName);
m = input('okay? (remember to include the flist from the moving bars)')
if doMakeFlistNew
    make_flist_select(['flist_',sortingRunName,'.m'])
end
flist = {};eval(['flist_',sortingRunName]);
% save(sprintf('%s_configurations.mat', sortingRunName ), 'configs_stim_light','flist');
% out = add_field_to_structure(out,'configs_stim_light', configs_stim_light);
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
[spikes meaData dataChunkParts concatData] = ...
    load_and_spikesort_selected_els(flist, staticEls);
% load_and_spikesort_selected_els(flist, staticEls, 'first_config_is_block');
%% load h5 files only
meaData = mea1.load_mea1_data(out.flist);
%%
save([sortingRunName,'_ums_sorting'], 'spikes');
fprintf('Saving completed.\n');
% save([sortingRunName,'_concatenated_data'], 'concatData', 'dataChunkParts')
%% save data to struct & get spike times for each config
out = add_field_to_structure(out,'concat_data', concatData);
out = add_field_to_structure(out,'data_chunk_parts', dataChunkParts);
out = add_field_to_structure(out,'spikes', spikes);

%
spikeTimes = [out.spikes.assigns' round(2e4*out.spikes.spiketimes')];
ts = {};
for i=1:length(meaData)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), out.data_chunk_parts(i), ...
        out.data_chunk_parts(i+1));
    ts{i} = spikeTimes(selSpikeTimeInds,:);
    ts{i}(:,2) = ts{i}(:,2)-out.data_chunk_parts(i);
end
doPlotNeuroRouter= 1;
out = add_field_to_structure(out,'ts', ts);
% save('regional_scan_04.mat', 'out')
%% take a look at the selected cluster to compare with ds cell found (no neurorouter)
allClusterNos = unique(out.ts{1}(:,1))'
% umsClusNo = input('Enter cluster number>> ');
umsClusNo  = allClusterNos;
for i=1:length(umsClusNo)
    try
        h = figure, hold on, axis square
        gui.plot_hidens_els('marker_style', 'cx')
    [out.footprint.mposx out.footprint.mposy mat out.footprint.wfs] =...
        construct_footprint_from_mea1_data(meaData(1), ...
        umsClusNo(i), out.ts(1));
   
    plot_footprints_simple([out.footprint.mposx out.footprint.mposy], ...
        out.footprint.wfs, ...
        'input_templates','hide_els_plot',...
        'plot_color','k','scale', 55);
%     neur_struct.regional_scan.plot.plot_peak2peak_amplitudes(out)
    %
    catch
       fprintf('Error with %d\n',i)
    end
end


%% take a look at the selected cluster to compare with ds cell found
allClusterNos = unique(out.ts{1}(:,1))'
umsClusNo = input('Enter cluster number>> ');

for i=1:length(umsClusNo)
    [footprint.mposx footprint.mposy mat footprint.wfs] =...
        construct_footprint_from_mea1_data(meaData(1), ...
        umsClusNo(i), out.ts(1));
    
    h = figure; hold on, axis square
    gui.plot_hidens_els('marker_style', 'cx')
    
    plot_footprints_simple([footprint.mposx footprint.mposy], ...
        footprint.wfs, ...
        'input_templates','hide_els_plot',...
        'plot_color','b', 'scale', 15);
    %
end

%% plot topological footprint
allClusterNos = unique(out.ts{1}(:,1))'
umsClusNo  = input('Enter cluster number>> ');
[footprint.mposx footprint.mposy mat footprint.wfs] = ...
    construct_footprint_from_mea1_data(meaData, umsClusNo(1), out.ts);
out = add_field_to_structure(out,'footprint', footprint);



%% plot footprint with irouter
fileName = 'neur_regional_scan_01';

if exist(fileName, 'file')
    junk = input('file exists!');
end
allClusterNos = unique(out.ts{1}(:,1))'
umsClusNo  = input('Enter cluster number>> ');
for i=1:length(umsClusNo)

    fileNameSuffix = num2str(1);
    footprint = {};
    [footprint.mposx footprint.mposy mat footprint.wfs] = ...
        construct_footprint_from_mea1_data(meaData, ...
        umsClusNo(i), out.ts);
    
    h = figure; hold on, axis square
    gui.plot_hidens_els('marker_style', 'cx')
    plot_footprints_simple([footprint.mposx footprint.mposy], ...
        footprint.wfs, ...
        'input_templates','hide_els_plot',...
        'plot_color','b','scale', 45);
    % save([sortingRunName,'_completeFootprint'], 'footprintWaveforms','mposx', 'mposy')
   
    out = add_field_to_structure(out,'footprint', footprint);
    out = add_field_to_structure(out,'cluster_no', umsClusNo(i));
   
end
% neur_struct.regional_scan.plot.plot_peak2peak_amplitudes(out)
%% save
save(sprintf('%s.mat', fileName),'out');
% save(sprintf('%s.mat', fileName),'out');



