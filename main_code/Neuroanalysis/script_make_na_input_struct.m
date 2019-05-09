% script_make_na_input_struct
% 
% ---------------------------------------------
% datafile
%     Describes the file that contains the data.
% site
%     Describes the physical location(s) from which the data was obtained.
... In our framework, a data set should only contain multiple sites only if 
...the sites were recorded simultaneously. Data from sites that were recorded
... sequentially should appear in separate file pairs.
% category
%     Describes the groups in which the spike trains are partitioned. 
... This is required because the spike trains must be classified into
... discrete categories for use with the toolkit.
% trace

%     Describes the spike trains contained in the data file. 
% ---------------------------------------------
iNeuron = 1;

%make output struct

% clear X
% Number of stimulus classes in experiment
X.M = int32(2);

% Number of sites in experiment. 
X.N = int32(1);

% Array of structures with recording site information
% fileNames(iNeuron).name
X.sites.label = {strcat(['Neuron ', strrep(tsMatrix{iNeuron}.name,'_','-')])};
X.sites.recording_tag = {'episodic'};
X.sites.time_scale = 1;
X.sites.time_resolution = 1.0000e-04;
X.sites.si_unit = 'none';
X.sites.si_prefix = 1;
%
% 'Original_Movie'; ...
%     'Stat_Surr_Median_Whole_Movie';...
%
% 'Dynamic_Surr_Median_Each_Frame';...
%     'Dynamic_Surr_Shuffled_Median_Each_Frame';...
%     'Pixelated_Surr_Shuffled_25_Percent_Each_Frame';...
%     'Pixelated_Surr_Shuffled_75_Percent_Each_Frame';...
%     'Pixelated_Surr_Shuffled_100_Percent_Each_Frame'...
%
% trials
numTrials = length(selSpikes);
catLabels = {'orig-movie', ...
    'stat-med-surr'}
% catLabels = {'dyn-surr', ...
%     'dyn-surr-shuff'}

% , ...
%     'dynamic-med-surr', ...
%     'dynamic-med-surr-shuffled', ...
%     'pix-surr-shuffled-75-percent'};
% catLabelsInds = [1*ones(1,5) 2*ones(1,5) 3*ones(1,5) 4*ones(1,5) 5*ones(1,5)];

numTrials = 35;
numInitTrialsDrop = 5;
numTrialsUsed = numTrials - numInitTrialsDrop;
numStartStopTsPerStimulusCluster = 35;


%%
spikeCount = [];
avgNumSpikesAll = [];
stdNumSpikesAll = [];
for iStim=1:X.M
    
    for iTrial=1:numTrialsUsed
        X.categories(iStim).trials(iTrial).start_time = 0;
        X.categories(iStim).trials(iTrial).end_time = stimDurSec{iStim}{iTrial};
        X.categories(iStim).trials(iTrial).Q = int32(length(selSpikes{iStim}{iTrial}));
        X.categories(iStim).trials(iTrial).list = selSpikes{iStim}{iTrial};
        spikeCount(end+1) = length(selSpikes{iStim}{iTrial});

    end
    avgNumSpikes = mean(spikeCount);
    stdNumSpikes = std(spikeCount);
    avgNumSpikesAll(end+1) = avgNumSpikes;
    stdNumSpikesAll(end+1) = stdNumSpikes;
    
    
    X.categories(iStim).label = catLabels(iStim);
    X.categories(iStim).P = int32(numTrialsUsed);
    X.categories(iStim).trials = X.categories(iStim).trials';
end

% Array of structures with categorized response data
%


