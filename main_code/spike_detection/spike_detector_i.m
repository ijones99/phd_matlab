function [traceIdxSpike numReps epochDataSig meanData ] = spike_detector_i(stimDACData, numDACSwitchesPerStim, ...
    ampIndex, preTimeMsec, postTimeMsec, elNumbersMea1, elidxReadout, mea1, ...
    threshNumTimesRms, varargin)

% function [traceIdxSpike numReps ] = SPIKE_DETECTOR_I(stimDACData, numDACSwitchesPerStim, ...
%     ampIndex, preTimeMsec, postTimeMsec, elNumbersMea1, elidxReadout, mea1, ...
%     threshNumTimesRms, varargin)
doPlotFit = 0;
doPlot = 1;
yLim = [-100, 100];
% time after stimulation artifact
startAnalysisPt = 35;
endAnalysisPt = 89;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'no_plot')
            doPlot = 0;
        elseif strcmp( varargin{i}, 'plot_fit')
            doPlotFit = 1;
            
        elseif strcmp( varargin{i}, 'ylim')
            yLim = varargin{i+1};
        elseif strcmp( varargin{i}, 'samples_after_artifact')
            startAnalysisPt = varargin{i+1};
            
        end
    end
end

% get DAC values from dac data
[p2pStimValsPerPulse stimPulsePts] = get_dac_epochs_in_data( ...
    stimDACData, numDACSwitchesPerStim );
dacValues = unique(p2pStimValsPerPulse);

% inds for the amplitudes selected
stimValInds = find(p2pStimValsPerPulse == dacValues(ampIndex));
% indices of data that correspond to selected epochs
epochInds = calculate_epoch_inds( stimPulsePts(stimValInds), ...
    preTimeMsec, postTimeMsec);

% index in MEA1 data of output electrode
elidxReadoutMea1 = multifind(elNumbersMea1, elidxReadout,'first');

if isempty(elidxReadoutMea1)
    fprintf('!! Likely error: readout el does not exist in file.\n');
end

epochDataSig = [];
if doPlot
    figure, hold on
    plotStyles = {'--', ':',  '-'};
end

tracesLevel = zeros(size(epochInds(:,startAnalysisPt:endAnalysisPt),1), ...
    size(epochInds(:, startAnalysisPt:endAnalysisPt),2));

numReps = size(epochInds,1);

% step through repetitions
for stimRepNo = 1:numReps
    epochDataSig = mea1.getData(epochInds(stimRepNo,:),elidxReadoutMea1);
    meanData = mean(epochDataSig,2)'; 
    y = meanData(startAnalysisPt:endAnalysisPt);
    x = [0:(length(y)-1)]/2e4;
    ws = warning('off','all');  % Turn off warning
    
    p = polyfit(x,y,3);
    warning(ws)  % Turn it back on.
    f = polyval(p,x); % fitted line
    tracesLevel(stimRepNo,:) = y-f;
    if doPlotFit
        plot(x,y,'k'); hold on;
        plot(x,f,'k--');
        
    end
    
    if doPlot

                plot(x,tracesLevel(stimRepNo,:),plotStyles{randi([1,3],1)},...
            'Color',rand(1,3),'LineWidth',2);
    end
end

if doPlot
    ylim([yLim]);
end

tracesNoSig = tracesLevel(:,end-50:end);
meanRms = rms(reshape(tracesNoSig,1,size(tracesNoSig,1)*size(tracesNoSig,2)));
spikeIndRange = [1 33];
peakHeights = abs(min(tracesLevel(:,spikeIndRange(1): spikeIndRange(2)),[],2)-...
    tracesLevel(:,1));
spikeThresh = threshNumTimesRms*meanRms;
traceIdxSpike = find(peakHeights>spikeThresh)';

