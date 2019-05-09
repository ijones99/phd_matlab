function percentResponse = get_percent_spike_response(epochDataSig)
% function percentResponse = GET_PERCENT_SPIKE_RESPONSE(epochDataSig)
%
% epochDataSig(i,:) = mea1.getData(epochInds(i,:),chInd);
% epochDataSig      [repeatsxdata samples]  

samplesPerMsec = 20;
timeRangeSamples = 2*samplesPerMsec;
baselineIndsSamples = 1:2e1*0.75;
stimFinishTimeSamples = 35;

% data all
for i=1:size(epochDataSig,1)
    epochDataSig(i,:) = epochDataSig(i,:) - mean(epochDataSig(i,baselineIndsSamples));
end
meanEpochDataSig = mean(epochDataSig,1);
medianEpochDataSig = median(epochDataSig,1);

% get baseline data
baselineMean = median(median(epochDataSig(:, baselineIndsSamples),2));
rmsNoise = mean(rms(epochDataSig(:, baselineIndsSamples),2));

% get min peak value
[ sigMinAmp, sigMinTimeSamples ] = min(medianEpochDataSig(stimFinishTimeSamples+1:...
    timeRangeSamples+stimFinishTimeSamples+1));

% threshold value
threshold = -1*((abs(sigMinAmp) - rmsNoise)/2 + rmsNoise);
[rows, cols] = find(epochDataSig(:,stimFinishTimeSamples+1:...
    timeRangeSamples+stimFinishTimeSamples+1)<threshold);

numPassThresh = length(unique(rows));
percentResponse = 100*numPassThresh/size(epochDataSig,1);

%% plot
% figure, hold on
% plot(xAxisMat, epochDataSig', 'LineWidth', 1)
% plot(xAxisVector, medianEpochDataSig,'k','LineWidth', 3)
% plot(xAxisMat(sigMinTimeSamples+stimFinishTimeSamples), ...
%     sigMinAmp,'+r', 'LineWidth', 3)

end