%% Configs for active area

scanConfigDir = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc3_tile2x6/';
doConvertHex = 1;

fileNameConfig = dir([[ scanConfigDir,'/'], '*hex.nrk2']);
fileNameEl2Fi= dir([[ scanConfigDir,'/'], '*el2fi*']);
for iFile=1:length(fileNameConfig)
    fileNameConfig(iFile).name = strrep(fileNameConfig(iFile).name,'.hex.nrk2','');
    if ~exist(sprintf('%s%s.cmdraw.nrk2', scanConfigDir, fileNameConfig(iFile).name)) || doConvertHex
        convert_config_hex2cmdraw([scanConfigDir], fileNameConfig(iFile).name);
    end
end

%% Send configs
timeAtEachConfig = 4;
for iFile=1:length(fileNameConfig)
    
   send_config_to_chip([scanConfigDir], fileNameConfig(iFile).name)
    fprintf('Sent %s\n', fileNameConfig(iFile).name);
    pause(timeAtEachConfig);
end
%% Show moving bar stimulus:
% -----------------> 1 ----------------->
% Send selected config with CmdGui 
% -----------------> 2 ----------------->
% Run script_show_bars_ds_scan.m
%   ntk files will be recorded
% -----------------> 3 ----------------->
% Generate ds scan configs file
% ------------------ SETTINGS ------------------ %
% ---------- file names -------------
sortGroupNumber = 2;
% ------------------------------------
fprintf('Group number = %d\n', sortGroupNumber);
m = input('okay?')
nrkFileGroups = num2cell([1:2]); 
expName = path_name_decomposition(pwd,'part_no',2,'reverse','string_out');
makeNewFlist = 1;
% ---------------------------------------------- %
load StimParams_Bars.mat % stim parameters
sortingRunName = sprintf('cell_search_scan%d',sortGroupNumber);disp(sortingRunName)
configs = generate_ds_scan_configs_file(Settings, nrkFileGroups);
if makeNewFlist, make_flist_select(sprintf('flist_cell_search%d.m',sortGroupNumber))
end

flist = {};eval([sprintf('flist_cell_search%d',sortGroupNumber)]);
save(sprintf('%s_configurations.mat', sortingRunName ), 'configs','flist');
%% do sorting of patches to find DS cells
ana.michele.dsCellScanSorting.startSorting(expName, sortingRunName,sortingRunName );
%% get neuron plotting data (with DS info)
[C R TL SC] = ana.michele.dsCellScanSorting.plotDSCells(expName, sortingRunName);
%% get neuron plotting data (no DS)
[TL SC] = ana.ian.load_cell_data(expName, sortingRunName);
%% open chip viewer
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
%% Plot footprints & propagation direction (DS)
% ------------------ SETTINGS ------------------ %
nElsInFootprint = 10;
doSavePlot = 0;
% ---------------------------------------------- %
dsCellIdx = find(R.isDScell);                   % local inds of DS cells
colorMap=pmkmp(length(dsCellIdx),'IsoL');
for i=dsCellIdx
    elPositionXY = TL.MES.electrodePositions;
    waveform = SC.T_merged(:,:,i);
    waveform = permute(waveform, [3 2 1]);
    elNumber = TL.MES.electrodeNumbers;
    plot_propagation_direction(elPositionXY, waveform, ...
    elNumber, nElsInFootprint)
    [h1 h2] = plot_footprints_simple( elPositionXY, waveform, elNumber, ...
        'plot_color',colorMap(find(dsCellIdx==i),:), 'format_for_neurorouter',...
        'hide_els_plot'); 
    if doSavePlot
        fileName = sprintf('%s_ds_cell_footprints',sortingRunName);
        dirName = '../Figs/';
        saveas(h,fullfile(dirName, fileName),'fig');
        savefigtofile(h, dirName, fileName)
    end
end
%% open chip viewer
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
%% Plot footprints (No DS)
% ------------------ SETTINGS ------------------ %
PLOT_FOR_NEUROROUTER = 1;

nElsInFootprint = 10;
PLOT_PROPAGATION = 0;
doSavePlot = 0;
% ---------------------------------------------- %\
if ~PLOT_FOR_NEUROROUTER, 
    h = figure; 
    scrsz = get(0,'ScreenSize');
    figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)])
else
    nrg = nr.Gui
    set(gcf, 'currentAxes',nrg.ChipAxesBackground)
    
end
dsCellIdx = 1:length(SC(1).localSortingID);                   % local inds of DS cells
colorMap=pmkmp(length(dsCellIdx),'IsoL');
for i=1%dsCellIdx
    elPositionXY = TL(1).MES.electrodePositions;
    waveform = SC(1).T_merged(:,:,i);
    waveform = permute(waveform, [3 2 1]);
    elNumber = TL(1).MES.electrodeNumbers;
    if PLOT_PROPAGATION
        plot_propagation_direction(elPositionXY, waveform, ...
            elNumber, nElsInFootprint)
        if ~PLOT_FOR_NEUROROUTER
        hold on
        end
    end
    if PLOT_FOR_NEUROROUTER
        [h1 h2] = plot_footprints_simple( elPositionXY, waveform, elNumber, ...
        'plot_color',colorMap(find(dsCellIdx==i),:), 'format_for_neurorouter','hide_els_plot', ...
          'flip_templates_ud','flip_templates_lr'); 
    else
        [h1 h2] = plot_footprints_simple( elPositionXY, waveform, elNumber, ...
            'plot_color',colorMap(find(dsCellIdx==i),:),'hide_els_plot', ...
            'rev_x_dir','flip_templates_ud','flip_templates_lr');
    end
    title(sprintf('Sorting #%d, cell#%d',sortGroupNumber, i))
    figure(gcf)
    if ~PLOT_FOR_NEUROROUTER
        axis tight, axis equal
    end
    m = input('press key> ','s')
    if m=='q'
        return
    end
    if ~PLOT_FOR_NEUROROUTER, hold off, end
    if doSavePlot
        fileName = sprintf('%s_cluster%d_footprints',sortingRunName,i);
        dirName = '../Figs/';
        saveas(h,fullfile(dirName, fileName),'fig');
%         savefigtofile(h, dirName, fileName)
    end
end

%% -------------- DO THE REGIONAL SCAN (of specific area) ----------------
% create configs for scanning area
sortGroupNumber = 12;
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
recordTime = 7; % seconds
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
%% spikesort different patches with shared (static) electrodes (near initial segment)
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
mea1 = {};
for i=1:length(flist)
    h5FileName = strrep(flist{i},'ntk','h5');
    mea1{i} = mysort.mea.CMOSMEA(h5FileName, 'useFilter', 0, 'name', 'Raw');
    fprintf('Loading...%3.0f percent done.\n', i/length(flist)*100)
end

% concatenate data
concatData = single([]);
dataChunkParts = 0;
dataChunkLengthMsec = 5;
dataChunkLengthSamples = 2e4*dataChunkLengthMsec;
for i=1:length(flist)
    % find inds for sel channels
    dataInds = multifind_ordered(mea1{i}.getAllSessionsMultiElectrodes.electrodeNumbers, staticEls);
    
    if i==1
        concatData = single(mea1{i}.getData(:,dataInds));
    else
        concatData = [concatData; single(mea1{i}.getData(:,dataInds))];
    end
    dataChunkParts(i+1) = size(concatData,1);
    fprintf('Progress %3.0f\n', 100*i/length(flist));
end

save([sortingRunName,'_concatenated_data'], 'concatData', 'dataChunkParts')
fprintf('Saving completed.\n');

%% spikesort all configs
% check for arguments
Fs = 2e4;
thrValue = 4.5;
numKmeansReps = 1;
% SPIKE SORTING
clear data
data{1} = concatData;

spikes = [];
% default_waveformmode = 1 is for all traces mode
spikes = ss_default_params(Fs, 'thresh', thrValue);
spikes.elidx = staticEls;
% spikes.channel_nr = chNumbers;untitled8.m
fName = 'fileName';
% SET VIEW MODE;
spikes.params.display.default_waveformmode = 1; % 1: "show all spikes" mode; ...
% 2: show bands

% give file names to spike struct
spikes.fname = fName;
spikes.clus_of_interest=[];
spikes.template_of_interest=[];

% detect spikes
runTime(1) = 0;
tic
spikes = ss_detect(data,spikes)
runTime(2) = toc;
fprintf('ss_detect. Time %3.0f.\n', runTime(2));
tic
spikes = ss_align(spikes);
runTime(3) = toc;
fprintf('ss_align. Time %3.0f.\n', runTime(3));
% cluster spikes
options.reps = numKmeansReps;
options.progress = 0;
tic
spikes = ss_kmeans(spikes, options);
runTime(4) = toc;
fprintf('ss_kmeans. Time %3.0f.\n', runTime(4));
tic
spikes = ss_energy(spikes);
runTime(5) = toc;
fprintf('ss_energy. Time %3.0f.\n', runTime(5));
tic
spikes = ss_aggregate(spikes);
runTime(6) = toc;
fprintf('ss_agg. Time %3.0f.\n', runTime(6));
fprintf('Total runtime: %3.0f mins\n', sum(runTime));

spikes.params.display.default_waveformmode = 2;
splitmerge_tool(spikes)

save([sortingRunName,'_ums_sorting'], 'spikes');
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



%% open chip viewer
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)

%% plot the footprint
doPlotNeuroRouter= 1;

if doPlotNeuroRouter
        nrg = nr.Gui
        set(gcf, 'currentAxes',nrg.ChipAxesBackground)
        ah = nrg.ChipAxes;
        
end

%
umsClusNo = 1
% scrsz = get(0,'ScreenSize');
% figure('Position',[1 scrsz(4)*3/4 scrsz(3)/2 scrsz(4)]), hold on

% for movie
mposx = [];
mposy = [];
mat = [];

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
    'plot_color','b', 'flip_templates_ud','flip_templates_lr'); 

    mposx = [mposx ; data.x];
    mposy = [mposy ; data.y];
    mat   = [mat ; dataOffsetCorr ];
    
    catch
        fprintf('No spikes for %d.\n', i)
    end
    drawnow
    if ~doPlotNeuroRouter
        axis equal
    end
    progress_info(i,length(mea1))
end

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

