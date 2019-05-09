%% Directory & Stimulus Names
dirName.Roska = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska';
dirName.Exp = {'07Aug2012' '21Aug2012' '30Oct2012'   };
dirName.SortGp = dir('../analysed_data/T*');
dirName.AnalysedData = '../analysed_data/';
% Stimulus names
stimNames = {'White Noise', 'Orig Movie', 'Static Median Surround', 'Dynamic Median Surround', ...
    'Dynamic Median Surround Shuffled', 'Pixelated Surround 10%', ...
    'Pixelated Surround 50%', 'Pixelated Surround 90%', 'Dots of Different Sizes', 'Moving Bars'}; 
%% create matrix from framenumbers
clear framenoInfo
for i=1:length(dirName.SortGp)
    [framenoInfo{i}] = get_frameno_info(dirName.SortGp(i).name);i
end
%% Create neuron names list: NEURONSLIST
% list of neuron names and directory locations
neuronsList = {};
% get electrode numbers from stat surround
% sortingGpNo = [2 2 3 3 4 4 4]; % sorting group number
% selectSegment = [1 2 1 2 1 2 3]; % segment from each sorting group
prefix = 'st_*';
dirNameSt = strcat('../analysed_data/', dirName.SortGp(2).name, '/03_Neuron_Selection/');
elNumbersInDir = get_el_numbers_from_dir(dirNameSt, prefix);
for iDir = 1:length(dirName.SortGp)
    underscoreLoc = strfind(dirName.SortGp(iDir).name,'_');
    neuronsList{iDir}.date = get_dir_date;
    neuronsList{iDir}.stim_name =  dirName.SortGp(iDir).name(underscoreLoc(end-2):end);
    neuronsList{iDir}.dir_loc =   strcat('../analysed_data/', dirName.SortGp(iDir).name, ...
        '/03_Neuron_Selection/');
    neuronsList{iDir}.neuron_names = get_neur_names_from_el_nos( elNumbersInDir, ...
        neuronsList{iDir}.dir_loc, prefix,1);
end
%% Create Output Files
dirNameResults = fullfile(dirName.AnalysedData,'Results/');
doClear = 0;
for iFile = 1:length(neuronsList{2}.neuron_names)
    save_to_results_file(neuronsList{2}.neuron_names{iFile}, 1, {},doClear);
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

expGroupNumMovingBars = 5;
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
    save_to_results_file(neuronsList{2}.neuron_names{iNeurons}, saveToFieldNum,outputData{iNeurons} );
end

%% Put STA Data into output struct
% in this dir: ../analysed_data/T14_02_26_0_white_noise_050/STA_Data/
expGroup = 2; % white noise checkerboard group
dirSTAData = strrep(neuronsList{expGroup}.dir_loc,'03_Neuron_Selection','STA_Data');

prefixStaPlot = 'staTemporalPlot_';
prefixStaFrames = 'staFrames_';
saveToFieldNum = 1;
% neuronsList{expGroup}.neuron_names = {'4842n175'    '4846n217'    '5051n197'    '5148n17'    '5455n83'    '6172n220'    '6272n159'    '6275n205'    '6376n154'}

for iNeurons = 1:length(neuronsList{expGroup}.neuron_names)
    if  ~isempty(neuronsList{expGroup}.neuron_names{iNeurons})
        if exist(strcat(fullfile(dirSTAData,strcat(prefixStaPlot,neuronsList{expGroup}.neuron_names{iNeurons})),'.mat'),'file'), ...
                
        iNeurons
        % load sta plot info
        load(fullfile(dirSTAData,strcat(prefixStaPlot,neuronsList{expGroup}.neuron_names{iNeurons})));
        STAOut.neuron_name = neuronsList{expGroup}.neuron_names{iNeurons};
        STAOut.date = get_dir_date;
        STAOut.stim_name = 'White Noise Checkerboard';
        % load frames
        load(fullfile(dirSTAData,strcat(prefixStaFrames,neuronsList{expGroup}.neuron_names{iNeurons})));
        
        
        
        
        try
            save_to_results_file(neuronsList{2}.neuron_names{iNeurons}, saveToFieldNum,STAOut);
        catch
            fprintf('File does not exist: %s\n',  STAOut.neuron_name);
        end
        end
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

%% plot data
h = figure('Position', [1 1 1000 1200] ); % [left bottom width height]....get(0,'ScreenSize')  [1 1 1920 1200]                                                                                    
set(gcf,'color',[1 1 1])

setSpacing = 0.015;
setPadding = 0.015;
setMargin = 0.017;
subplotsVert = 5;
% length(neuronsList{2}.neuron_names) ;
subplotsHor = 4;
indWhiteNoise = 2;
hold on
for i=1
    iNeuron = i;
    plotInd = (i-1);
    resultsData = load_results_files(neuronsList{indWhiteNoise}.neuron_names{iNeuron});
    % plot polar -------------------------------------
    subaxis(subplotsVert,subplotsHor,1+plotInd, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    
    stimGroupNo = 10;
    plot_polar_for_ds(resultsData{stimGroupNo}.bar_directions, resultsData{stimGroupNo}.mean_fr)
    title(neuronsList{2}.neuron_names{iNeuron},'FontWeight','bold');
    xlabh = get(gca,'Title'); set(xlabh,'Position',get(xlabh,'Position') - [0 1 0]);
    % plot RF sizes ----------------------------------
    subaxis(subplotsVert,subplotsHor,2+plotInd, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    stimGroupNo = 9;
    peakFr = max(frAvg,[],2);
    plot(resultsData{stimGroupNo}.settings.DOT_DIAMETERS,resultsData{stimGroupNo}.fr_peak(1:end/2),'b*-','LineWidth',2), hold on
    plot(resultsData{stimGroupNo}.settings.DOT_DIAMETERS,resultsData{stimGroupNo}.fr_peak(end/2+1:end),'r*-','LineWidth',2)
    xlabel('Dot Diameter (microns)'), ylabel('Firing Rate')
    if i==1, title('RF Sizes','FontWeight','bold'), end

    % plot STA ---------------------------------------
    subaxis(subplotsVert,subplotsHor,3+plotInd, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    stimGroupNo = 1;                                                                
    plot(resultsData{stimGroupNo}.x_axis, resultsData{stimGroupNo}.STA,'LineWidth',2,'Color',[0 0.5 0]);
    
    if i==1, title('STA','FontWeight','bold'), end
    xlabel('Time (msec)'), ylabel('Pixels');

    
    % plot PSTH of dot stim ---------------------------------------------
    subaxis(subplotsVert,subplotsHor,4+plotInd, 'Spacing', setSpacing, 'Padding', ...
        setPadding, 'Margin', setMargin);
    stimGroupNo = 9;
    plot([0:0.025:1], resultsData{stimGroupNo}.meanPsthSmoothed,'k','LineWidth',2);
    if i==1, title('PSTH for Dot','FontWeight','bold'), end
    xlabel('Time (sec)'), ylabel('Firing Rate')
    
end