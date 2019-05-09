%% Show moving bar stimulus:
% -----------------> 1 ----------------->
% Send selected config with CmdGui 
% -----------------> 2 ----------------->
% Run script_show_bars_ds_scan.m
%   ntk files will be recorded
% -----------------> 3 ----------------->
% Generate ds scan configs file
% ------------------ SETTINGS ------------------ %
sortGroupNumber = 2;
nrkFileGroups = num2cell([1:2]); 
expName = '08Oct2013';
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
nElsInFootprint = 10;
PLOT_PROPAGATION = 0;
PLOT_FOR_NEUROROUTER = 1;
doSavePlot = 1;
% ---------------------------------------------- %\
if ~PLOT_FOR_NEUROROUTER, 
    h = figure; 
    scrsz = get(0,'ScreenSize');
    figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)])
end
dsCellIdx = 1:length(SC(1).localSortingID);                   % local inds of DS cells
colorMap=pmkmp(length(dsCellIdx),'IsoL');
for i=dsCellIdx
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
        'plot_color',colorMap(find(dsCellIdx==i),:), 'format_for_neurorouter','hide_els_plot'); 
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
all_els=hidens_get_all_electrodes(2);
sortingRunName = sprintf('regional_scan_%02d',sortGroupNumber);
scanConfigDir = sprintf('../Configs/%s/', sortingRunName );
mkdir(scanConfigDir)

% get static els near init segment
numStaticEls = 7;
while length(nrg.configList.selectedElectrodes) < numStaticEls 
    pause(0.25)
end
staticEls = nrg.configList.selectedElectrodes;
fprintf('Done selecting fixed (init segment) electrodes.\n')

m = input('Press key> ');

% get scanning els
[scanEls indsLocalInside] = select_els_in_sel_pt_polygon( all_els )
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
recordTime = 60; % seconds
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
    send_config_to_chip(['../Configs/', scanConfigDir], fileNameConfig(i).name)
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
sortGroupNumber = 3;
doMakeFlistNew = 1;
expName = '08Oct2013';
% ---------------------------------------------- %
load StimParams_Bars.mat
nrkFileGroups = num2cell([1:length(fileNameConfig)]);
configs = generate_ds_scan_configs_file(Settings, nrkFileGroups);
if doMakeFlistNew
    make_flist_select(['flist_',sortingRunName,'.m'])
end
flist = {};eval(['flist_',sortingRunName]);
save(sprintf('%s_configurations.mat', sortingRunName ), 'configs','flist');


%% Convert to h5
for i=1:length(flist)
    mysort.mea.convertNTK2HDF(flist{i},'prefilter', 0);
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
dataChunkLengthSamples = 2e4*5;
for i=1:length(flist)
    % find inds for sel channels
    dataInds = multifind_ordered(mea1{i}.getAllSessionsMultiElectrodes.electrodeNumbers, staticEls);
    
    if i==1
        concatData = single(mea1{i}.getData(1:dataChunkLengthSamples,dataInds));
    else
        concatData = [concatData; single(mea1{i}.getData(1:dataChunkLengthSamples,dataInds))];
    end
    dataChunkParts(i+1) = size(concatData,1);
    fprintf('Progress %3.0f\n', 100*i/length(flist));
end

save([sortingRunName,'_concatenated_data'], 'concatData', 'dataChunkParts')
fprintf('Saving completed.\n');
%% do limited spike sorting (~5els)

nSamplesPerSecond = 2e4;
note = sortingRunName;
DS = mysort.ds.Matrix(concatData, nSamplesPerSecond, note);
% P.botm.run = 1;                          % activate botm sorting

%% spikesort all configs
tmpDataPath = ['../analysed_data/computed_results/', sortingRunName,'/'];
clear P
P = struct();
P.spikeDetection.thr = 4;
% P.spikeCutting.maxSpikes = 150000;
% P.spikeAlignment.method = 'onUpsampledMean';
% P.spikeAlignment.maxSpikes = 150000;
% P.featureExtraction.cutLeft = 3;
% P.featureExtraction.Tf = 12;
% P.clustering.meanShiftBandWidthFactor = 2.5;
[S P] = mysort.sorters.sort(DS, tmpDataPath,'TestSort_new_params5',P);
clusterSorting = [S.clusteringMerged.ids(:) round(S.clusteringMatched.ts(:))];
% mysort.plot.SliderDataAxes(mea1{1})
clusterNosFound = unique(clusterSorting(:,1))';
save([sortingRunName,'_spikesorting_results'], 'S', 'P', 'clusterSorting','clusterNosFound')
%% open chip viewer
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
%% Get templates
spikeTimes = clusterSorting;
% get selected spiketimes
selSpikeTimes = {};
for i=1:length(mea1)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), dataChunkParts(i), dataChunkParts(i+1));
    selSpikeTimes{i} = spikeTimes(selSpikeTimeInds,:);
    selSpikeTimes{i}(:,2) = selSpikeTimes{i}(:,2)-dataChunkParts(i);
end
% get templates
SSC = {}; TL = {};
for i=2:length(mea1)
    SSC{i} = mysort.spiketrain.SpikeSortingContainer('ClusterSorting', selSpikeTimes{i}, ...
        'wfDataSource', mea1{i}, 'nMaxSpikesForTemplateCalc' , 400);
    TL{i} = SSC{i}.getTemplateList();
    fprintf('-------------- Calc SSC & TL: %.0f -------------- \n',...
        100*i/length(mea1))
end

save(sprintf('%s_templates_cluster%d.mat', sortingRunName, clusterNo ), 'SSC','TL');

%% plot templates

% ------------------ SETTINGS ------------------ %
doPlotInNeuroRouter = 1;
spikeTimes = clusterSorting;
doPrintToFile = 0;

for clusterNo = clusterNosFound(2:end)
    if doPlotInNeuroRouter
        nrg = nr.Gui
        set(gcf, 'currentAxes',nrg.ChipAxesBackground)
        ah = nrg.ChipAxes;
        
    end

    % plot footprints
    if doPlotInNeuroRouter
        for i=2:length(TL)
            for k=clusterNo
                TLtemp = TL{i};
                idx=find([TLtemp.name]== k);
                if ~isempty(idx)
                    plot_footprints_simple(TL{i}(idx).MultiElectrode.electrodePositions, ...
                        TL{i}(idx).waveforms', ...
                        'input_templates','hide_els_plot','format_for_neurorouter',...
                        'plot_color','b');   %'plot_color',rand(1,3));
                    hold on
%                 mysort.plot.templates2D(TL{i}(idx).waveforms, TL{i}(idx).MultiElectrode.electrodePositions, 1000, 0, 'ah', ah)
                
                else
                    warning('cluster number not found in configuration.');
                end
                  
            end
        end
    end    

  
    if doPrintToFile
        legend(num2str([clusterNo]'));
        
        title(sprintf('%s Scan, Cluster Number %d', sortingRunName, clusterNo),...
            'interpreter', 'none');
        fileName = sprintf('%s_Footprint_Cluster_Num_%d',sortingRunName,...
            clusterNo);
        dirName = '../Figs/';
        saveas(ah,fullfile(dirName, fileName),'fig');
    end
    m = input('hit key');
    close all
end



%% FINISHED WITH FINDING NEURON!!!


%% plot all clusters

nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
ah = nrg.ChipAxes;

save(sprintf('%s_templates_cluster%d.mat', sortingRunName, clusterNo ), 'SSC','TL');

