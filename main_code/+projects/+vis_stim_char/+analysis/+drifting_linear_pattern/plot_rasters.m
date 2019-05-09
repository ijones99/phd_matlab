function dataOut = plot_rasters(selClus, varargin)


script_load_data
idxStim = driftingLinearPatternRIdx;

dirNameProf = '../analysed_data/profiles/';

% load stim params
stimSettings = load('settings/stimParams_Drifting_Linear_Pattern.mat');

plotColor = {'r' 'b' 'c' 'k' 'm' 'g'};
h = [];
xLim = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'fig')
            h = varargin{i+1};
        elseif strcmp( varargin{i}, 'xlim')
            xLim = varargin{i+1};
        end
    end
end

if ~isempty(h)
    figs.scale(h,50,100);
end

% get stim change timestamps
allStimChs = stimChangeTs{idxStim };

% add repeats
numReps = 5;

stimChTimesWithReps = [];
for i=1:2:length(allStimChs)
    stimChTimesWithReps = [stimChTimesWithReps linspace(allStimChs(i),allStimChs(i+1),numReps+1)];
end

subplotEdges = [length(selClus)+1 1];

subplot(subplotEdges(1),subplotEdges(2),1), hold on
stimXAxis= linspace(0,20,length(stimSettings.Settings.PATTERN_VECTOR));
plot(stimXAxis, 100*stimSettings.Settings.PATTERN_VECTOR/255,'LineWidth',1);
xlabel('Time (seconds)')
ylabel('Trial')
title('Stimulus')

idxRaster = [[[1:5] [1:5]+6 [1:5]+6*2 [1:5]+6*3 [1:5]+6*4 [1:5]+6*5]' [[1:5] [1:5]+6 [1:5]+6*2 [1:5]+6*3 [1:5]+6*4 [1:5]+6*5]'+1];
 idxPlotColor = sort(repmat(1:6, 1,numReps));
 
for i=1:length(selClus)
    % load data
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf))
    
    % get spiketimes
    stCurr = neurM(idxStim).ts;
            
    % create idx raster for data access
   
    % create idx raster for baseline
    baselineTime=1;
   
    % get spiketime segments
    allParapinChs = stimChTimesWithReps;%stimChangeTs{idxStim}/2e4;
    [spikeTrain spikeTrainSeg spikeTrainBL spikeTrainBLSeg] = spiketrains.get_raster_series(stCurr/2e4, ...
        allParapinChs/2e4 , idxRaster,'baseline_sec',baselineTime );
   
    subplot(subplotEdges(1),subplotEdges(2),i+1), hold on
    spikeCnt = [];
    for j =1 :length(spikeTrainSeg)
        
        plot.raster(spikeTrainSeg{j},'offset',j,'height',0.8,'color',plotColor{idxPlotColor(j)});
        
    end
    if ~isempty(xLim)
        xlim(xLim);
    end
    ylim([0 length(stimSettings.Settings.DIR)*numReps+1]);
    
    text(-0.5, length(stimSettings.Settings.DIR)*numReps/2,num2str(selClus(i)));
    set(gca, 'YTick', []);
    progress_info(i,length(selClus));
    
end

suptitle(sprintf('Drifting Linear Pattern [%d to %d]',selClus(1),selClus(end)));

shg

% add cluster and date info
% dataOut.clus_num = idxFinalSel.keep;
% dataOut.date = get_dir_date;
% dirName =  '../analysed_data/moving_bar_ds';
% mkdir(dirName)
% save(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'), 'dataOut');
% fprintf('dataOut saved.\n')
