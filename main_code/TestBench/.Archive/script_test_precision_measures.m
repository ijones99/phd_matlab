suffixName = '_orig_stat_surr';
flistName = 'flist_orig_stat_surr'
flist ={}; eval(flistName);
% elNumbers = [4631 4938 5444 5749 5851 6059 6361 6464]; % %get from white
% noise checkerboard
flistFileNameID = get_flist_file_id(flist{1}, suffixName);

flistFileNameID = get_flist_file_id(flist{1}, suffixName);
% dir names
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);

% frameno file name
framenoFileName = strcat('frameno_', flistFileNameID, '.mat');
% load light timestamp framenos
load(fullfile(dirNameFFile,framenoFileName));

% shift timestamps for stimulus frames
frameno = shiftframets(frameno);

% get timestamps
neurNames = '6172n169';
selNeuronInds = get_file_inds_from_neur_names(dirNameSt, '*.mat', neurNames);
tsMatrix  = get_tsmatrix(flistFileNameID, 'sel_by_ind', selNeuronInds)
tsMatrixOrig = tsMatrix;
%% create jitter
% % tsMatrix = tsMatrixOrig;
% % % create jitter
% % mu = 0; sigma = .0005; % distribution settings
% % numSpikes = length(tsMatrix{1}.spikeTimes); % number spikes
% % jitter = normrnd(mu,sigma,[1,numSpikes]); % create normal distributed j

%% create dataset
neuronIndNo = 1
clear X
% clear selSpikes
% clear stimDurSec
for iStimNum = 1:2
    [selSpikes{iStimNum} , stimDurSec{iStimNum}] = parse_stimulus_repeat_responses_natural_movie(frameno, tsMatrix , neuronIndNo, iStimNum)
    
end

spikeTrains = selSpikes{1};
spikeTrainBase = selSpikes{1}{1};
%% create dataset
repeatNum = 50;
costInfo = {};
mu = 0; % distribution settings
numSpikes = length(spikeTrainBase); % number spikes
spikeTrains = {};
precisionInfo = {};
sigmaValues = 1e-3.*[1 2 5 10 100 200 500 1000]; % 1 2 5
i = 1;
clear precisionInfo
for iSigma = sigmaValues
    
    for iRepeatNum = 1:repeatNum
        jitter = normrnd(mu,iSigma,[1,numSpikes]); % create normal distributed j
        spikeTrains{iRepeatNum} = unique(sort(spikeTrainBase+jitter,'ascend'));
    end
    precisionInfo{i}.sigma = iSigma;
    precisionInfo{i}.spikeTrains = spikeTrains;
    i=i+1;
end

% Remove spikes
clear precisionInfo
spikeTrainsMod = {};
percentSpikesToRemove = [0 5 10 25 50 75 90];

sigma = iSigma; % sigma value
originalSpikeTrains = spikeTrains; % original spiketrains
repeatNum = length(originalSpikeTrains);
for i = 1:length(percentSpikesToRemove) % go through different percents removal
    clear spikeTrainsMod
    spikeTrainsMod = originalSpikeTrains; % set all groups of spikeTrains equal to original
    % keep reusing original spike trains
    numSpikesInTrain = length(originalSpikeTrains{1}); %num spikes in spike train
    numSpikesToRemove = round((percentSpikesToRemove(i)/100)*numSpikesInTrain); % num spikes to remove
    
    %     R = randperm(numSpikesInTrain);%generate random numbers
    %     spikeIndsToRem = R(1:numSpikesToRemove);%pick the first 1-n numbers
    for iRepeatNum = 1:repeatNum % go through all of the repeats in each group
        
        if percentSpikesToRemove(i) ~= 0 % if some spikes are to be removed, then remove them
            
            R = randperm(numSpikesInTrain);%generate random numbers
            spikeIndsToRem = R(1:numSpikesToRemove);%pick the first 1-n numbers
            %             spikeIndsToRem
            %             spikeIndsToRem = randi(numSpikesInTrain ,1,numSpikesToRemove);%random distribution of spike inds
            spikeTrainsMod{iRepeatNum}(spikeIndsToRem) = [];
        end
    end
    precisionInfo{i}.sigma = iSigma;
    precisionInfo{i}.percentSpikesRemoved = percentSpikesToRemove(i);
    precisionInfo{i}.spikeTrains = spikeTrainsMod;
    
    
end



%% set all all first
precisionInfo = {};
%   textprogressbar('start')
sigmaValues = [0.0005 1e-3 2e-3 5e-3 10e-3];
for iSigma = sigmaValues
    
    % separate spikes into repeats
    doPrint = 0;
    dirCBA = strcat(fullfile('../Figs/',   flistFileNameID, '/Cost_Based_Analysis'));
    
    
    
    for neuronIndNo = 1%:length( neurNames )
        clear X
        %     clear selSpikes
        %     clear stimDurSec
        %     for iStimNum = 1:2
        %         [selSpikes{iStimNum} , stimDurSec{iStimNum}] = parse_stimulus_repeat_responses_natural_movie(frameno, tsMatrix , neuronIndNo, iStimNum)
        %     end
        
        %
        
        
        %make output struct
        
        % clear X
        % Number of stimulus classes in experiment
        X.M = int32(1);
        
        % Number of sites in experiment.
        X.N = int32(1);
        
        % Array of structures with recording site information
        % fileNames(neuronIndNo).name
        X.sites.label = {strcat(['Neuron ', strrep(tsMatrix{neuronIndNo}.name,'_','-')])};
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
        numTrials = length(spikeTrains);
        catLabels = {'orig-movie'}%, ...
        %         'stat-med-surr'};
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
        
        
        % Put into array
        spikeCount = [];
        avgNumSpikesAll = [];
        stdNumSpikesAll = [];
        for iStim=1:X.M
            
            for iTrial=1:numTrialsUsed
                X.categories(iStim).trials(iTrial).start_time = 0;
                X.categories(iStim).trials(iTrial).end_time = stimDurSec{iStim}{iTrial};
                X.categories(iStim).trials(iTrial).Q = int32(length(spikeTrains{iTrial}));
                X.categories(iStim).trials(iTrial).list = spikeTrains{iTrial};
                spikeCount(end+1) = length(spikeTrains{iTrial});
                
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
        
        
        % try for a range of q values
        clear meanCost; clear stdCost
        meanCost = cell(X.M,1); stdCost = cell(X.M,1);
        qValuesLabel = {};
        costVals = cell(X.M,1);
        qExp = [-1:.1:6];
        
        qValues = [ 10.^qExp ];
        
        for iQValue = qValues
            %         iQValue;
            % Calculate costs
            % compare when only # spikes used
            opts.shift_cost =  iQValue; % seconds
            Y = metric(X, opts);
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
        
        figure, hold on
        errorbar(meanCost{1},stdCost{1},'-','LineWidth', 2)
        % bar(meanCost)
        % axis([.75 4.25 0 55])
        set(gca, 'XTick', 1:length(qValuesLabel), 'XTickLabel', qValuesLabel, ...
            'FontSize', 15,'LineWidth', 2)
        hold on
        %     % plot
        %     errorbar(meanCost{1},stdCost{1},'r','LineWidth', 2)
        
        precisionInfo{end+1}.mean = meanCost{1};
        precisionInfo{end}.std = stdCost{1};
        precisionInfo{end}.sigma = sigma;
        precisionInfo{end}.selSpikes = spikeTrains;
        % set legend & title, etc.
        title(strcat(['Cost Based Analysis of Spiketrains - ', X.sites.label, ' Sigma=', ...
            num2str(iSigma)]));
        legend('orig', 'stat surround', 'dyn med surr', 'dyn med surr shuffled')
        ylabel('Total Cost/Spike')
        xlabel('Log of Cost of Shifting Rel to Adding or Deleting Spike');
        
        if doPrint
            %             print(gcf,'-depsc', '-r150',  fullfile(dirNameSTA,strcat(titleName,'.ps')) );
            
            
            if ~isdir(dirCBA)
                fprintf('Directory does not exist\n');
                mkdir(dirCBA)
            else
                exportfig(gcf, fullfile(dirCBA,strcat(X.sites.label{1},'sigma_',num2str(iSigma),'.ps')) ,'Resolution', 120,'Color', 'cmyk')
            end
            
        end
        
    end
    [Y I] = find(iSigma==sigmaValues);
    textprogressbar(I/length(iSigma))
end

textprogressbar('end');


%% determine precision
plateauQ = [];
for i=1:length(precisionInfo)
    
    [Y plateauInd] = find(precisionInfo{i}.mean>=0.05*max(precisionInfo{i}.mean),1,'first');
    plateauInd
    plateauQ(i) = qValues(plateauInd);
    precisionValues = 2./plateauQ;
    
end
figure, plot(sigmaValues*1000, precisionValues*1000);
xlabel('Sigma Values (One Standard Dev of Jitter) (msec)')
ylabel('Precision Values (msec)')
title('Precision: Computed Precision vs. Std. of artificial Jitter (Plateau at 95%)')