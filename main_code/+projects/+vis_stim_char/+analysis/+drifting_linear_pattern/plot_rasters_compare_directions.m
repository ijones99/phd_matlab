function dataOut = plot_rasters(selClus, varargin)


script_load_data
idxStim = driftingLinearPatternRIdx;

dirNameProf = '../analysed_data/profiles/';

% load stim params
stimSettings = load('settings/stimParams_Drifting_Linear_Pattern.mat');

plotColor = 'k';
h = [];


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'fig')
            h = varargin{i+1};
        end
    end
end

if ~isempty(h)
    
    figs.maximize(h);
end

% get stim onset timestamps
allStimChsIdx = 1:2:length(stimChangeTs{idxStim });

dataOut.meanSpikeCnt = {};
dataOut.stdSpikeCnt = {};
dataOut.meanFR = {};
dataOut.stdFR = {};
meanBLFR = [];

onOffBias = [];

subplotEdges = [length(selClus)+1 1];

subplot(subplotEdges(1),subplotEdges(2),1), hold on
stimXAxis= linspace(0,100,5*length(stimSettings.Settings.PATTERN_VECTOR));

plot(stimXAxis, repmat(stimSettings.Settings.PATTERN_VECTOR,1,5),'LineWidth',1)
 
for i=1:length(selClus)
    % load data
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf))
    
    % get spiketimes
    stCurr = neurM(idxStim).ts;
            
    % create idx raster for data access
    idxRaster = [allStimChsIdx' [allStimChsIdx+1]'];

    % create idx raster for baseline
    baselineTime=1;
   
    % get spiketime segments
    [spikeTrain spikeTrainSeg spikeTrainBL spikeTrainBLSeg] = spiketrains.get_raster_series(stCurr/2e4, ...
        stimChangeTs{idxStim}/2e4, idxRaster,'baseline_sec',baselineTime );
   
    subplot(subplotEdges(1),subplotEdges(2),i+1), hold on
    spikeCnt = [];
    for j =1 :length(spikeTrainSeg)
        
        plot.raster(spikeTrainSeg{j},'offset',j,'height',0.8,'ylim',[0 6],'color',plotColor);
        
    end
    
    progress_info(i,length(selClus));
    
end
shg

% add cluster and date info
% dataOut.clus_num = idxFinalSel.keep;
% dataOut.date = get_dir_date;
% dirName =  '../analysed_data/moving_bar_ds';
% mkdir(dirName)
% save(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'), 'dataOut');
% fprintf('dataOut saved.\n')
