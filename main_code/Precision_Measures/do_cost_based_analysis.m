function [qValues meanCost stdCost] = do_cost_based_analysis(synthDataSel, qValues  )
% cost based analysis
% function [qValues meanCost stdCost] = do_cost_based_analysis(synthDataSel, qValues  )
%
% 
%   input
%       qValues(optional): range of q values |t1 - t2| = 2/q
%       synthDataSel: synthDataSel is a structure with timestamps of 
%           spikes and (optionally, if synthesized data) 
%           ts: {1x30 cell}
%           sigma: 1.0000e-03
%
%   output:
%       qValues: range of qvalues
%       mean costs calculated
%       std of costs calculated
% author: ijones


% Settings
qExp = [-3:.1:6]; % q-value exponents

if nargin < 2 
    qValues = [ 10.^qExp ]; % q-values
end

if isfield(synthDataSel,'sigma')
    sigmaValSec = synthDataSel.sigma;
end

clear X

% Number of stimulus classes in experiment
X.M = int32(1);

% Number of sites in experiment.
X.N = int32(1);

% Array of structures with recording site information

if exist('sigmaValSec')
    X.sites.label = {strcat(['Sigma ', num2str(sigmaValSec)])};
else
    X.sites.label = {'_'};
end
X.sites.recording_tag = {'episodic'};
X.sites.time_scale = 1;
X.sites.time_resolution = 1.0000e-04;
X.sites.si_unit = 'none';
X.sites.si_prefix = 1;
%

% trials
numTrials = length(synthDataSel.ts);
catLabels = {'orig-movie', ...
    'stat-med-surr'};
% catLabels = {'dyn-surr', ...
%     'dyn-surr-shuff'}

% , ...
%     'dynamic-med-surr', ...
%     'dynamic-med-surr-shuffled', ...
%     'pix-surr-shuffled-75-percent'};
% catLabelsInds = [1*ones(1,5) 2*ones(1,5) 3*ones(1,5) 4*ones(1,5) 5*ones(1,5)];


numInitTrialsDrop = 0;
numTrialsUsed = numTrials - numInitTrialsDrop;
numStartStopTsPerStimulusCluster =length(synthDataSel.ts) ;


% Put into array
spikeCount = [];
avgNumSpikesAll = [];
stdNumSpikesAll = [];


for iTrial=1:numTrialsUsed
    X.categories(1).trials(iTrial).start_time = 0;
    X.categories(1).trials(iTrial).end_time = synthDataSel.ts{iTrial}(end); % length of stim 29.9642
    X.categories(1).trials(iTrial).Q = int32(length(synthDataSel.ts{iTrial})); % # spikes 138
    X.categories(1).trials(iTrial).list = synthDataSel.ts{iTrial}; % timestamps
    spikeCount(end+1) = X.categories(1).trials(iTrial).Q;
    
end
avgNumSpikes = mean(spikeCount);
stdNumSpikes = std(spikeCount);
avgNumSpikesAll(end+1) = avgNumSpikes;
stdNumSpikesAll(end+1) = stdNumSpikes;


X.categories(1).label = catLabels(1);
X.categories(1).P = int32(numTrialsUsed);
X.categories(1).trials = X.categories(1).trials';

% try for a range of q values
clear meanCost; clear stdCost
meanCost = []; stdCost = [];
qValuesLabel = {};
costVals = cell(X.M,1);

textprogressbar('start')
i=1;
for iQValue = qValues
    %         iQValue;
    % Calculate costs
    % compare when only # spikes used
    opts.shift_cost =  iQValue; % seconds
    Y = metric(X, opts);
    qValuesLabel{end+1} = strcat([ num2str(log10(iQValue))]) ;
    % for number of categories
    
        
        % get cost values
        costVals = Y.d(1:numTrialsUsed,1:numTrialsUsed);
        % remove zeros
        costVals = costVals(find(costVals>0))/avgNumSpikes;
        % calculated values
        meanCost(end+1) = mean(costVals);
        stdCost(end+1) = std(costVals);
    textprogressbar((i/length(qValues)*100));
   i=i+1;
end
textprogressbar('end')









end