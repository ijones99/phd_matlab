%% create dataset
repeatNum = 50;
costInfo = {};
mu = 0; % distribution settings
numSpikes = length(spikeTrainBase); % number spikes
spikeTrains = {};
precisionInfo = {};
sigmaValues = 1e-3*([0.5:0.5:5 6:10  ]);
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

%% script_test_precision_measures_meister1995_cross_corr
precisionRatio = [];
precisionInfoStd = [];
sigmaVal = [];
precisionInfoMean = [];
precisionInfoStd = [];
% bin data
sigmaGroupsInds = 1:length(sigmaValues);
sigmaGroupsNum = length(sigmaValues);
figure
for iGroup = 1:length(precisionInfo)% for all groups of repeats
    
    % # of stimulus repeats
    numStimRepeats = length(precisionInfo{iGroup}.spikeTrains);
    lengthStim = round(precisionInfo{iGroup}.spikeTrains{1}(end));
    bins = [0:0.001:lengthStim]; % set bins
    numBins = length(bins);  % number of bins
    
    % bin data for Exp spiketrains
    for i=1:numStimRepeats % for number of spiketrain groups
        precisionInfo{iGroup}.binnedData{i} = ...
            histc(precisionInfo{iGroup}.spikeTrains{i},[bins]);
    end
    
    % get all possible pairwise combinations for repeats
    ccCombis = combnk(1:numStimRepeats,2);
    
    % take cross correlation of first combination to get  size of xcf
    [xcf,lags,bounds] = crosscorr(precisionInfo{iGroup}.binnedData{ccCombis(1,2)}, ...
        precisionInfo{iGroup}.binnedData{ccCombis(1,2)});
        
    allCCs = zeros(length(ccCombis), length(xcf)); % initialized allCCs
    
    for iComb = 1:length(ccCombis) % go through all spiketrain pairwise combinations
        
        % select 2 at a time
        spiketrainA = precisionInfo{iGroup}.binnedData{ccCombis(iComb,1)};
        spiketrainB = precisionInfo{iGroup}.binnedData{ccCombis(iComb,2)};
        
        % take cross correlation of the two spike trains
        [xcf,lags,bounds] = crosscorr(spiketrainA,spiketrainB);
        
        % save all the cross correlations
        allCCs(iComb,:) = xcf;
        
        % find middle area under curve
        ccEdgesMiddle = [-1 1];
        ccEdgeMiddleInds = find(ismember(lags,ccEdgesMiddle)); % get indices of edges
        
        % compute middle area under curve
        middleArea = trapz(xcf(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)));
        totalArea = trapz(xcf); % compute area under total curve
        
        % totalAreaAll(iGroup) = totalArea;
        precisionInfo{iGroup}.precisionRatio(iComb) = middleArea/totalArea;
        precisionInfo{iGroup}.totalArea(iComb) = totalArea;
       
    end
    precisionInfoMean(iGroup) = mean(precisionInfo{iGroup}.precisionRatio);
    precisionInfoStd(iGroup) = std(precisionInfo{iGroup}.precisionRatio);
    iGroup
    xcfMean = mean(allCCs,1);
    xcfStd = std(allCCs,1);
    subplot(ceil(length(precisionInfo)/2),2,iGroup), plot(lags,xcfMean)
    ylim([-0.1 1]);
    title(strcat('Cross Correlation for Two Stimulus Repeats, Sigma = ', ...
        num2str(precisionInfo{iGroup}.sigma)));
    sigmaVal(iGroup) = precisionInfo{iGroup}.sigma;
    
    
    hold on
    area(lags(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)), ...
        xcfMean(ccEdgeMiddleInds(1):ccEdgeMiddleInds(2)));
    text(10,0.3,num2str(precisionInfoMean(iGroup) ));
end

%% plot as function of sigma value
figure, 
errorbar(log(sigmaValues), precisionInfoMean, precisionInfoStd), hold on;
% plot(log(sigmaVal),(precisionRatio),'x-'), hold on
title('Cross Correlation Precision Ratio')
xlabel('Log Jitter Sigma Value')
ylabel('Precision Ratio');


fitobject = fit(log(sigmaValues'),precisionInfoMean','poly2')
textLocRangeX = xlim;
textLocRangeY = ylim;
textLocX = (textLocRangeX(2)-textLocRangeX(1))*0.75+textLocRangeX(1);
textLocY = (textLocRangeY(2)-textLocRangeY(1))*0.75+textLocRangeY(1);

% plot formula
text(textLocX,textLocY,['f(x) = p1*x^2 + p2*x + p3',10, ...
    'p1 = ',num2str(fitobject.p1),10, 'p2 = ', num2str(fitobject.p2),10, ...
    'p3 = ', num2str(fitobject.p3) ])

% plot fit

plot(log(sigmaValues),fitobject.p1*log(sigmaValues).^2 +fitobject.p2*log(sigmaValues) ...
    + fitobject.p3,'k')

% plot area
for iGroup = 1:length(precisionInfo)% for all groups of repeats
    totalAreaSum(iGroup) = mean(precisionInfo{iGroup}.totalArea);
end

figure, plot(log(sigmaValues),totalAreaSum);
xlabel('Log Jitter Sigma Value');
ylabel('Area Under Curve');
title('Area Under Curve of Cross Correlations');

%% plot as function of percent spikes removed
figure, plot(percentSpikesToRemove,(precisionRatio),'x-'), hold on
title('Cross Correlation Precision Ratio As Function of % Spikes Removed')
xlabel('Log Jitter Sigma Value')
ylabel('Percent Spikes Removed');


