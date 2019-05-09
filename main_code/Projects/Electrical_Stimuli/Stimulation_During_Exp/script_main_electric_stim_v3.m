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
%% Send configs to chip in series in order to scan
timeAtEachConfig = 10;
for iFile=1:length(fileNameConfig)
   send_config_to_chip([scanConfigDir], fileNameConfig(iFile).name)
    fprintf('Sent %s\n', fileNameConfig(iFile).name);
    pause(timeAtEachConfig);
end
%% Show moving bar stimulus (after running stimulus)
sortGroupNumber = 1;
% ------------------------------------
fprintf('Group number = %d\n', sortGroupNumber);
m = input('okay?')
nrkFileGroups = num2cell([1:2]); 
expName = path_name_decomposition(pwd,'part_no',2,'reverse','string_out');
makeNewFlist = 0;
% ---------------------------------------------- %
load StimParams_Bars.mat % stim parameters
sortingRunName = sprintf('cell_search_scan%d',sortGroupNumber);disp(sortingRunName)
configs = generate_ds_scan_configs_file(Settings, nrkFileGroups);
if makeNewFlist, 
    make_flist_select(sprintf('flist_cell_search%d.m',sortGroupNumber))
end
flist = {};eval([sprintf('flist_cell_search%d',sortGroupNumber)]);
save(sprintf('%s_configurations.mat', sortingRunName ), 'configs','flist');

%% load data and spikesort 
open script_plot_amplitude_map_and_spikesort

%% plot DS attributes

umsClusNo = 1;
pauseInterval = 0.2;
stimFramesTsStartStop = {};
for i=1:length(flist)
    ntkOut{i} = load_field_ntk(flist{i}, {'images.frameno'});
    stimFramesTsStartStop{i} = get_stim_start_stop_ts2(ntkOut{i}.images.frameno,...
        pauseInterval)
end
%% -------------- DO THE REGIONAL SCAN (of specific area) ----------------
% create configs for scanning area
sortGroupNumber = 1;
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
config_info = generate_specific_point_defined_stim_configs(scanEls, staticEls,...
    sortingRunName, 'no_plot')
save(sprintf('%s_electrode_number_selection.mat', sortingRunName ), 'config_info',...
    'scanEls', ...
    'indsLocalInside', 'staticEls');

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
configs = generate_ds_scan_configs_file(Settings, nrkFileGroups);
sortGroupNumber
fprintf('sortingRunName = %s\n', sortingRunName);
m = input('okay?')
if doMakeFlistNew
    make_flist_select(['flist_',sortingRunName,'.m'])
end
flist = {};eval(['flist_',sortingRunName]);
save(sprintf('%s_configurations.mat', sortingRunName ), 'configs','flist');

%% Convert to h5
for i=1:length(flist)
    mysort.mea.convertNTK2HDF(flist{i},'prefilter', 1);
    fprintf('progress %3.0f\n', 100*i/length(flist));
end
%% load all h5 files (regional scan)
[spikes mea1 dataChunkParts concatData] = ...
    load_and_spikesort_selected_els(flist, staticEls);
save([sortingRunName,'_ums_sorting'], 'spikes');
fprintf('Saving completed.\n');
save([sortingRunName,'_concatenated_data'], 'concatData', 'dataChunkParts')
fprintf('Saving completed.\n');
%% get spike times for each config
spikeTimes = [spikes.assigns' round(2e4*spikes.spiketimes')];
selSpikeTimes = {};
for i=1:length(mea1)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), dataChunkParts(i), ...
        dataChunkParts(i+1));
    selSpikeTimes{i} = spikeTimes(selSpikeTimeInds,:);
    selSpikeTimes{i}(:,2) = selSpikeTimes{i}(:,2)-dataChunkParts(i);
end
doPlotNeuroRouter= 1;

%%
umsClusNo = 15;
[mposx mposy mat footprintWaveforms] = construct_footprint_from_mea1_data(mea1, ...
    umsClusNo, selSpikeTimes);

nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
ah = nrg.ChipAxes;

plot_footprints_simple([mposx mposy], ...
    footprintWaveforms, ...
    'input_templates','hide_els_plot','format_for_neurorouter',...
    'plot_color','b', 'flip_templates_ud','flip_templates_lr');
save([sortingRunName,'_completeFootprint'], 'completeFootprint')
fprintf('Saving completed.\n');

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
        clusterInds = find(selSpikeTimes{i}(:,1)==umsClusNo);
        if length(clusterInds) > maxNumWFs
            clusterInds = clusterInds(1:maxNumWFs);
        end
        spikeTimesSamples = selSpikeTimes{i}(clusterInds,2);
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

