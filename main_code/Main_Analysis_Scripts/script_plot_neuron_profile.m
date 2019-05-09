%% Stimulus names
movieTitles = {'Orig Movie', 'Static Median Surround', 'Dynamic Median Surround', ...
    'Dynamic Median Surround Shuffled', 'Pixelated Surround 10%', ...
    'Pixelated Surround 50%', 'Pixelated Surround 90%'}; 
%% set up figure 
h = figure('Position', [1 1 1000 1200] ); % [left bottom width height]....get(0,'ScreenSize')  [1 1 1920 1200]                                                                                    
numSubplotsVert = 8;
subPlotNo = 3;
setSpacing = 0.013;
setPadding = 0.01;
setMargin = 0.015;


%% get direction names
% get directory names for movies
dirNamesSortGp = dir('../analysed_data/T*');
for i=1:length(dirNamesSortGp)
    frameNoNamesSortingGroup = strcat('../analysed_data/',dirNamesSortGp(i).name); % directory where movie results are located
    dirName.SortingGroup{i} = strcat('../analysed_data/',dirNamesSortGp(i).name);
    listDirInfoFrameno = dir(fullfile(frameNoNamesSortingGroup,'frameno*'));
    fileNameFrameNo{i} =  listDirInfoFrameno.name;
    dirName.St{i} = strcat(dirName.SortingGroup{i},'/03_Neuron_Selection/');
end
%% Plot Raster and PSTH
elNumbers = 4842; prefix = 'st_*';
sortingGroup = [2 2 3 3 4 4 4]; % Group that was sorted
stimulusNo = [1 2 1 2 1 2 3];
titleNo = [1:7];
for iPlotData = 1:length(titleNo)
    fprintf('%s: %s - %s\n', movieTitles{titleNo(iPlotData)}, fileNameFrameNo{sortingGroup(iPlotData)}, ...
        dirName.SortingGroup{sortingGroup(iPlotData)})
    %% load file and frameno
    fileInds = get_file_inds_from_el_numbers(dirName.St{sortingGroup(iPlotData)}, prefix, elNumbers);
    neuronNames = get_neur_names_from_dir(dirName.St{sortingGroup(iPlotData)}, prefix, fileInds);
    load(fullfile(dirName.St{sortingGroup(iPlotData)},neuronNames{1})); % load spiketimes
    eval(['timeStamps = ', neuronNames{1},'.ts;']); %rename spiketimes
    load(fullfile(dirName.SortingGroup{sortingGroup(iPlotData)}, fileNameFrameNo{sortingGroup(iPlotData)}));
    frameno = single(frameno);
    timeStampsOrig = timeStamps;
    
    % plot rasters
    % --------- Settings -------- %
    repeatsToPlot = [6:35]+(stimulusNo(iPlotData)-1)*35;
    binSize = 0.025;
    subaxis(numSubplotsVert,2,subPlotNo, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    plot_rasters_for_repeats(timeStampsOrig, frameno, repeatsToPlot), subPlotNo = subPlotNo+1;
    title(movieTitles{titleNo(iPlotData)})
    
    % plot PSTH
    subaxis(numSubplotsVert,2,subPlotNo, 'Spacing', setSpacing, 'Padding', setPadding, ...
        'Margin', setMargin);
    [psthDataMeanSmoothed timeStamps psthDataSmoothed] = ...
        plot_psth_for_repeats(timeStampsOrig, frameno, repeatsToPlot, binSize);
    corrIndex = get_corr_index_meister96(psthDataSmoothed,0.025, 0.1, 0)
    subPlotNo = subPlotNo+1;
    title(movieTitles{titleNo(iPlotData)})
    ylim([0 100])
    iPlotData
end
currDir = pwd; slashLocs = strfind(currDir,'/');
dataDate = currDir(slashLocs(end-1)+1:slashLocs(end)-1);
% mtit makes a title at the top of a subplot figure
mtit(gca,strcat(['Raster and PSTH for Neuron: ', dataDate, '/el-', num2str(elNumbers)]));

%% Plot Cost Based Analysis
elNumbers = 5455; prefix = 'st_*';
sortingGroup = [2 2 3 3 4 4 4]; % Group that was sorted
stimulusNo = [1 2 1 2 1 2 3];
titleNo = [1:7];
plotColors = get_plot_colors(length(stimulusNo));
figure, hold on
for iPlotData = 1:length(titleNo)
    fprintf('%s: %s - %s\n', movieTitles{titleNo(iPlotData)}, fileNameFrameNo{sortingGroup(iPlotData)}, ...
        dirName.SortingGroup{sortingGroup(iPlotData)})
    %% load file and frameno
    fileInds = get_file_inds_from_el_numbers(dirName.St{sortingGroup(iPlotData)}, ...
        prefix, elNumbers);
    neuronNames = get_neur_names_from_dir(dirName.St{sortingGroup(iPlotData)}, ...
        prefix, fileInds);
    load(fullfile(dirName.St{sortingGroup(iPlotData)},neuronNames{1})); % load spiketimes
    eval(['timeStamps = ', neuronNames{1},'.ts;']); %rename spiketimes
    load(fullfile(dirName.SortingGroup{sortingGroup(iPlotData)}, ...
        fileNameFrameNo{sortingGroup(iPlotData)}));
    frameno = single(frameno);
    timeStampsOrig = timeStamps;
    % plot rasters
    % --------- Settings -------- %
    repeatsToPlot = [6:35]+(stimulusNo(iPlotData)-1)*35;
    binSize = 0.025;
    neurNames = strrep(neuronNames,'st_','');
    underscoreLoc = findstr(dirName.SortingGroup{sortingGroup(iPlotData)},'_');
    suffixName{iPlotData} = ...
        dirName.SortingGroup{sortingGroup(iPlotData)}(underscoreLoc(5):end);
    plot_cost_based_analysis(suffixName{iPlotData}, neurNames, ...
        stimulusNo(iPlotData), plotColors(iPlotData,:));
end
currDir = pwd; slashLocs = strfind(currDir,'/');
dataDate = currDir(slashLocs(end-1)+1:slashLocs(end)-1);
mtit(gca,strcat(['Cost-Based Analysis for Neuron: ', dataDate, '/el-', num2str(elNumbers)]));
legend(movieTitles)

%% 
h = figure('Position', [1 1 1000 1200] )
subplotsVert = 3;
subplotsHor = 2;



%% Plot dots response
% subplot(subplotsVert,subplotsHor,2)
load ../analysed_data/T16_18_56_8_diff_size_dots_moving_bars/frameno_T16_18_56_8_diff_size_dots_moving_bars.mat
load ../analysed_data/T16_18_56_8_diff_size_dots_moving_bars/03_Neuron_Selection/st_4846n13.mat
stMatrix = st_4846n13;
selectSegment= 1;
load StimCode/StimParams_SpotsIncrSize.mat
[frAvg peakFr] = plot_peak_firing_rate_for_diff_size_dots(stMatrix, ...
    frameno, selectSegment, StimMats, Settings)
title(strcat(['Response to Varying Diameter Flashing Dots: ', dataDate, '/el-', num2str(elNumbers)]));
