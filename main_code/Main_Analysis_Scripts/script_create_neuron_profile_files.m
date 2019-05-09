%% Directory & Stimulus Names
% "sort group:" groups that were sorted together
% "stimulus name:" name of stimulus that was shown

dirName.Roska = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska';
dirName.Exp = { '13Dec2012_2'   };
dirName.SortGp = dir('../analysed_data/T*'); % all sort groups
dirName.AnalysedData = '../analysed_data/';
dirName.responses = fullfile(dirName.AnalysedData,'responses'); mkdir(dirName.responses);
dirName.refinfo = fullfile(dirName.AnalysedData,'refinfo'); mkdir(dirName.refinfo);
% Stimulus names
stimNames = {'White_Noise', 'Orig_Movie', 'Static_Median_Surround', 'Dynamic_Median_Surround', ...
    'Dynamic_Median_Surround_Shuffled', 'Pixelated_Surround_10_Percent', ...
    'Pixelated_Surround_50_Percent', 'Pixelated_Surround_90_Percent', 'Dots_of_Different_Sizes', 'Moving_Bars'}; 
elConfigInfo = get_el_pos_from_nrk2_file;



%% get stim frame stop start info: FRAMENOINFO
% start and stop frame info for each sort group
% saved in refinfo directory
clear framenoInfo 
doLoadSaved = 0;
if doLoadSaved
    load(fullfile(dirName.refinfo, 'framenoInfo.mat'))
else
    for i=1:length(dirName.SortGp)
        shift_and_save_frameno_info(dirName.SortGp(i).name)
        [framenoInfo{i}] = get_frameno_info(dirName.SortGp(i).name);i
    end
    save(fullfile(dirName.refinfo, 'framenoInfo.mat'), 'framenoInfo'); 
end
%% Create neuron names list: NEURONSLIST
indSortGpWhiteNoise = 2;
neuronsList = {};
prefix = 'st_*';
% timestamp directory
dirName.St = strcat('../analysed_data/', dirName.SortGp(indSortGpWhiteNoise).name, '/03_Neuron_Selection/');
for iDir = 1:length(dirName.SortGp)
    underscoreLoc = strfind(dirName.SortGp(iDir).name,'_');
    neuronsList{iDir}.date = get_dir_date;
    neuronsList{iDir}.stim_name =  dirName.SortGp(iDir).name(underscoreLoc(4):end);
    neuronsList{iDir}.dir_loc =   strcat('../analysed_data/', dirName.SortGp(iDir).name, ...
        '/03_Neuron_Selection/');
    neuronsList{iDir}.neuron_names = get_neur_names_from_el_nos( [0001:0030 elConfigInfo.selElNos], ...
        neuronsList{iDir}.dir_loc, prefix,1);
end

%% write lookup table: LOOKUPTABLENEURONS
doLoadSaved = 0;
if doLoadSaved
    lookupTableNeurons = {};
    lookupTableNeurons = csvimport(fullfile(dirName.responses,'lookupTableNeurons.csv'));  
else
    indSortGpWhiteNoise = 2; % white noise index
    clear  neuronNamesWn
    for i=1:length(selNeuronInds)
        neuronNamesWn{i} = neuronsList{indSortGpWhiteNoise}.neuron_names{selNeuronInds(i)};% % prepare cell
    end
    lookupTableNeurons = cell(length(neuronNamesWn),length(stimNames) );
          
    % add neuron names from white noise
    for i=1:length(neuronNamesWn)
        lookupTableNeurons{i+1,1}  = neuronNamesWn{i};
    end
    
    % add headers
    for j=1:length(stimNames)
        lookupTableNeurons{1,j}  = stimNames{j};
    end
    
    cell2csv(fullfile(dirName.refinfo,'lookupTableNeurons.csv'), lookupTableNeurons,'w');
    % S = csvimport('lookupTableNeurons.csv')
end
%% Create Output Files (blank)
dirNameProfiles = fullfile(dirName.AnalysedData,'profiles/');
doClear = 1;
for iFile = 1:length(neuronsList{2}.neuron_names)
    try
    save_to_profiles_file(neuronsList{2}.neuron_names{iFile}, 1, {},doClear);
    catch
       fprintf('Error with file\n');
        
    end
    
end
%% Get moving bars data
numReps = 20;
numDirections = 8;
selectSegment = 2;
a = 1:numReps; a = repmat(a,1,numDirections);
b = 0:numReps*2:numReps*2*(numDirections-1); b = sort(repmat(b,1,numReps));
selectedRepeats = a+b; % These are the selected segments for the bright bars
b = 0:numReps*2:numReps*2*(numDirections-1); b = sort(repmat(b,1,numReps));
selectedRepeats = a+b; % bright bars
load StimCode/StimParams_Bars.mat
expGroupNumMovingBars = 7;
saveToFieldNum = 10;
frameno = load_frameno(dirName.SortGp(expGroupNumMovingBars).name);

for iNeurons = 1:length(neuronsList{expGroupNumMovingBars}.neuron_names)
    outputData = {};
    % neuron name
    outputData{iNeurons}.date = get_dir_date;
    outputData{iNeurons}.stim_name = 'Moving Bars';
    outputData{iNeurons}.dir = neuronsList{expGroupNumMovingBars}.dir_loc;
    outputData{iNeurons}.neuron_name = neuronsList{expGroupNumMovingBars}.neuron_names{iNeurons};
    % load timestamps
    load(fullfile(neuronsList{expGroupNumMovingBars}.dir_loc, strcat('st_',...
        neuronsList{expGroupNumMovingBars}.neuron_names{iNeurons})));
    eval(['stMatrix = st_',  neuronsList{expGroupNumMovingBars}.neuron_names{iNeurons},';']);
    stimDirectionsDegrees = Settings.BAR_DRIFT_ANGLE;
    [frAvg peakFr meanFr] = plot_firing_rate_moving_bars(stMatrix, frameno, ...
    selectSegment, Settings,selectedRepeats);
    responseAmplitudes = meanFr;
    %     plot_polar_for_ds(stimDirectionsDegrees, responseAmplitudes')
    outputData{iNeurons}.repeats = selectedRepeats;
    outputData{iNeurons}.bar_directions = stimDirectionsDegrees;
    outputData{iNeurons}.mean_fr = responseAmplitudes';
    %     title(strcat(['Response to Moving Bars ON: ', get_dir_date, '/el-', ...
    % neuronsList{expGroupNumMovingBars}.neuron_names{iNeurons}]));
    % uses neuronsList #2 since neurons are named from white noise
    % clusterings
    save_to_results_file(neuronsList{2}.neuron_names{iNeurons}, saveToFieldNum,outputData{iNeurons} );
end
%% Put STA Data into output struct
% in this dir: ../analysed_data/T14_02_26_0_white_noise_050/STA_Data/
indSortGpWhiteNoise = 2; % white noise checkerboard group
dirSTAData = strrep(neuronsList{indSortGpWhiteNoise}.dir_loc,'03_Neuron_Selection','STA_Data');
prefix = 'sta_plot_';
saveToFieldNum = 1;
% neuronsList{indSortGpWhiteNoise}.neuron_names = {'4842n175'    '4846n217'  ...
% '5051n197'    '5148n17'    '5455n83'    '6172n220'    '6272n159'    ...
% '6275n205'    '6376n154'}
for iNeurons = 1:length(neuronsList{indSortGpWhiteNoise}.neuron_names)
    try
    if exist(strcat(fullfile(dirSTAData,strcat(prefix,neuronsList{indSortGpWhiteNoise}.neuron_names{iNeurons})),'.mat'),'file')
        load(fullfile(dirSTAData,strcat(prefix,neuronsList{indSortGpWhiteNoise}.neuron_names{iNeurons})));
        STAOut.neuron_name = neuronsList{indSortGpWhiteNoise}.neuron_names{iNeurons};
        STAOut.date = get_dir_date;
        STAOut.stim_name = 'White Noise Checkerboard';
        iNeurons
        try
            save_to_results_file(neuronsList{2}.neuron_names{iNeurons}, saveToFieldNum,STAOut);
        catch
            fprintf('File does not exist: %s\n',  STAOut.neuron_name);
        end
    end
    catch
       fprintf('Error with %d\n', iNeurons); 
    end
    
end
%% Put dots response data into struct
expGroup = 5; 
saveToFieldNum = 9;
prefix = 'st_';
frameno = load_frameno(dirName.SortGp(expGroup).name);
load StimCode/StimParams_SpotsIncrSize.mat
startTime = 0; stopTime = 1; binWidth = 0.025;
selectSegment = 1;
for iNeurons =1:length(neuronsList{expGroup}.neuron_names)
    clear stMatrix
    figure
    if exist(strcat(neuronsList{expGroup}.dir_loc,prefix,neuronsList{expGroup}.neuron_names{iNeurons},'.mat'),'file')
        load(strcat(neuronsList{expGroup}.dir_loc,prefix,neuronsList{expGroup}.neuron_names{iNeurons},'.mat')); % load data
        eval(['stMatrix = ', prefix, neuronsList{expGroup}.neuron_names{iNeurons},';']);
        
        outputData.neuron_name = neuronsList{expGroup}.neuron_names{iNeurons};
        outputData.date = get_dir_date;
        outputData.stim_name = stimNames{saveToFieldNum};
        
        [frAvg peakFr segments] = plot_peak_firing_rate_for_diff_size_dots(stMatrix, ...
            frameno, selectSegment, StimMats, Settings);
        outputData.fr_avg = frAvg;
        outputData.fr_peak = peakFr;
        outputData.stim_mats = StimMats;
        outputData.settings = Settings;
        outputData.segments = segments;
        [Y maxPeakInd] = max(peakFr); maxPeakInd = maxPeakInd(1);
        % for: Settings.DOT_BRIGHTNESS_VAL, StimMats.PRESENTATION_ORDER
        if maxPeakInd > 6
            ONDots = 0; % On dots off; therefore OFF dots are being used
            maxPeakInd = maxPeakInd - 6;
            selSegmentInds = find(StimMats.PRESENTATION_ORDER==maxPeakInd) + length(StimMats.PRESENTATION_ORDER);
        else % ON Dots are being used
            ONDots = 1; % On dots off; therefore OFF dots are being used
            selSegmentInds = find(StimMats.PRESENTATION_ORDER==maxPeakInd);
        end
        
        outputData.meanPsthSmoothed = get_psth_for_repeat_segments(segments, selSegmentInds,startTime, stopTime, binWidth)

        
        save_to_results_file(neuronsList{2}.neuron_names{iNeurons}, saveToFieldNum,outputData);
        
        %         catch
        %             fprintf('File does not exist: %s\n',  STAOut.neuron_name);
        %
        %         end
    end
    iNeurons
end

