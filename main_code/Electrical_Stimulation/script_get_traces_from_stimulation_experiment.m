

%% get all traces
voltageReps = a.voltageReps; % 
epochOut = zeros(300,128,a.repeats);

for iEpoch = 1:length(selEpochs)
    [target_trace epoch map] = extractTrigRawTrace( Info, NaN, ...
        'fulltrace','epoch',selEpochs(iEpoch));
    traces = squeeze(target_trace(elIdx,:,:))';
    tracesSpaced = space_traces_along_yaxis(traces, plotSpacing);
    epochOut(:,:,iEpoch) = tracesSpaced;
    iEpoch
end

%%

figure, plot(diffTrace);
endArtifactTime = 85;
selChOutIdx = 9;
diffTrace = diff(epochOut(:,selChOutIdx,1));
figure, hold on
numResponses = 0;
for i=1:a.repeats
    diffTrace = diff(epochOut(:,selChOutIdx,i));
    diffTraceSel = diffTrace(endArtifactTime:end);diffTraceSel  = ...
        diffTraceSel -mean(diffTraceSel );
    stdDiffTrace = std(diffTraceSel);
    findAboveThreshVals = find(diffTraceSel<-stdDiffTrace*2)+endArtifactTime
    if sum(findAboveThreshVals)
        numResponses = numResponses+1;
    end
    plot(diffTraceSel);
end

%% save to var
elicitedResponses(iVolt, elIdx) = numResponses


