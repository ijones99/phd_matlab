function [meanCost stdCost qValuesLabel] = do_cost_based_analysis(selSpikes, stimDurSec,NeuronName)
% function [meanCost stdCost] = do_cost_based_analysis(selSpikes, stimDurSec,NeuronName)
% arguments:
%   selSpikes: cell with a cell for each repeat
%   StimDurSec: same as above, but with single values for length of
%   stimulus
%   neuronName: name to label neuron

    clear X
     
    %make output struct
    
    % Number of stimulus classes in experiment
    X.M = int32(1);
    
    % Number of sites in experiment.
    X.N = int32(1);
    
    % Array of structures with recording site information
    % fileNames(neuronIndNo).name
    X.sites.label{1} = strcat(['Neuron ', NeuronName,'_','-']);
    X.sites.recording_tag = {'episodic'};
    X.sites.time_scale = 1;
    X.sites.time_resolution = 1.0000e-04;
    X.sites.si_unit = 'none';
    X.sites.si_prefix = 1;
     % trials
    numTrials = length(selSpikes);
       
    numTrials = 35;
    numInitTrialsDrop = 5;
    numTrialsUsed = numTrials - numInitTrialsDrop;
    numStartStopTsPerStimulusCluster = 35;
    
    
    % Put into array
    spikeCount = [];
    avgNumSpikesAll = [];
    stdNumSpikesAll = [];
    for iStim=1
        
        for iTrial=1:numTrialsUsed
            X.categories(iStim).trials(iTrial).start_time = 0;
            X.categories(iStim).trials(iTrial).end_time = stimDurSec{iTrial};
            X.categories(iStim).trials(iTrial).Q = int32(length(selSpikes{iTrial}));
            X.categories(iStim).trials(iTrial).list = selSpikes{iTrial};
            spikeCount(end+1) = length(selSpikes{iTrial});
            
        end
        avgNumSpikes = mean(spikeCount);
        stdNumSpikes = std(spikeCount);
        avgNumSpikesAll(end+1) = avgNumSpikes;
        stdNumSpikesAll(end+1) = stdNumSpikes;
        
        
        X.categories(iStim).label{1} = '';
        X.categories(iStim).P = int32(numTrialsUsed);
        X.categories(iStim).trials = X.categories(iStim).trials';
    end
    
    % Array of structures with categorized response data
    
    
    % try for a range of q values
    clear meanCost; clear stdCost
    meanCost = cell(X.M,1); stdCost = cell(X.M,1);
    qValuesLabel = {};
    costVals = cell(X.M,1);
    qExp = [-5:6];
    
    qValues = [ 10.^qExp ]
    
    for iQValue = qValues
        iQValue
        % Calculate costs
        % compare when only # spikes used
        opts.shift_cost =  iQValue; % seconds
        Y = metric(X, opts)
        qValuesLabel{end+1} = strcat([ num2str(log10(iQValue))]) ;
        % for number of categories
        for iCat = 1:X.M
            
            % get cost values
            costVals{iCat} = Y.d(1:numTrialsUsed,1+((iCat-1)*numTrialsUsed):numTrialsUsed*iCat);
            % remove zeros
            costVals{iCat} = costVals{iCat}(find(costVals{iCat}>0))/avgNumSpikes;
            % calculated values
            meanCost{iCat}(end+1) = mean(costVals{iCat});
            stdCost{iCat}(end+1) = std(costVals{iCat});
        end
    end

end