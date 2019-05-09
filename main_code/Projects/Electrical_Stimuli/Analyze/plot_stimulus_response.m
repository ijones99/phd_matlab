function plot_stimulus_response(dirNameSubfolder, fileInd, readOutChNo, doPrintToFile)
% get settings file

dirName = sprintf('log_files/%s/',dirNameSubfolder); 
settings = merge_settings_files(dirName);
flistAll = print_stim_settings_data(settings, 'stimType', 'stimCh', 'flist', 'suppress_print'  );

%%

flist = {}; flist{1} = flistAll{fileInd};
%%
doPreFilter = 0;
% convert file
recFreqMsec = 2e1;
for i=1:length(flist)
    if ~exist(strrep(flist{i},'.ntk','.h5'))
        mysort.mea.convertNTK2HDF(flist{i},'prefilter', doPreFilter);
    else
        fprintf('Already converted.\n');
    end
    fprintf('progress %3.0f\n', 100*i/length(flist));
end 
% load h5 file
mea1 = mysort.mea.CMOSMEA(strrep(flist{1},'.ntk','.h5'), 'useFilter', 0, 'name', 'Raw');

% load dac info
ntkExtractedFieldsName = strrep(strrep(flist{1},'.stream','_extract_fld'),'.ntk','.mat');
if ~exist(ntkExtractedFieldsName,'file')
    ntkOut = load_field_ntk(flist{1}, {'dac1', 'dac2'});
    save(ntkExtractedFieldsName,'ntkOut');
else
    load(ntkExtractedFieldsName)
end

% check for stim el
% dataLoaded = mea1.getData;
if sum(diff(ntkOut.dac2+ntkOut.dac1)) == 0
   phaseType = 'Opposed'; 
else
    phaseType = 'Same';recFreqMsec = 2e1;
for i=1:length(flist)
    if ~exist(strrep(flist{i},'.ntk','.h5'))
        mysort.mea.convertNTK2HDF(flist{i},'prefilter', doPreFilter);
    else
        fprintf('Already converted.\n');
    end
    fprintf('progress %3.0f\n', 100*i/length(flist));
end 
end

%% plot stim data - all traces
% settings
% chNo = [ 73 85 91 98 96 20 84 95 77 27 33];
%90%96 %92 ]; distal @ 92, proximal 90, 105 at cell body
% localNtkIndNumber = find(ntk2.sig == readOutChNo)
chNumbers = mea1.getChannelNr; 

titleStr = '';
stimDAC = 2;

pulseType = 'biphasic';
if strcmp(pulseType,'biphasic')
    step = 3;
elseif strcmp(pulseType,'triphasic')
    step = 4;
end

stimChNo = settings.stimCh{fileInd};
ampIndex = 1:10;

if length(stimChNo) == 1
    phaseType = '';
end

mVPerDacVal = 10*1000*2.9 / 1024; %Volts
signalGain = 959;

settings.amps2{fileInd}(ampIndex,1);
preTimeMsec = 1; postTimeMsec = 5;
xLimVal = [-preTimeMsec postTimeMsec];
fontSize = 16;
plotSpacing =500; %SPACING


recFreq = 2e4;
scrsz = get(0,'ScreenSize');
h=figure; hold on
set(h, 'Position', [1 scrsz(4) scrsz(3)*1/4 scrsz(4)]);

% plot data vals
if length(readOutChNo) > 1
    cmap = pmkmp(length(readOutChNo),'IsoL');
else
    cmap = [0 0 0];
end
for j = ampIndex
    
    dacSettingNum = j;
    % get stim timepoints
    if stimDAC == 1
        stimDACData = ntkOut.dac1;
    elseif stimDAC == 2
        stimDACData = ntkOut.dac2;
    end
    
    voltSwitchTime = diff(stimDACData);
    switchTimePts = find(voltSwitchTime~=0); % indices
    ...for time point switches (#phases + 1 per pulse:
        ...e.g. for biphasic pulse, 3 points per pulse. (see step size)
        
    stimPulsePts = switchTimePts(1:step:end); % time points of every pulse
    voltageMaxInds = switchTimePts(2:step:end); % time points of max values
    voltageMinInds = switchTimePts(3:step:end); % time points of min values
    
    % get voltage values.dac
    p2pStimValsPerPulse = stimDACData(voltageMaxInds)-stimDACData(voltageMinInds);
    dacValues = unique(p2pStimValsPerPulse);
    stimValInds = find(p2pStimValsPerPulse == dacValues(dacSettingNum)); % indices of
    ... stimPulsePts for this DAC setting
        
% get selected data; rows: indices for data around each timepoint
epochInds = calculate_epoch_inds( stimPulsePts(stimValInds), preTimeMsec, ...
    postTimeMsec);

for iChNo = 1:length(readOutChNo)
    chInd = find(chNumbers == readOutChNo(iChNo));
    epochDataSig = zeros(size(epochInds));
    for i=1:size(epochInds,1)
        epochDataSig(i,:) = mea1.getData(epochInds(i,:),chInd);
        epochDataSig(i,:) = plotSpacing*j + epochDataSig(i,:) - mean(epochDataSig(i,:));
    end
    meanEpochDataSig = mean(epochDataSig,1);
    
    epochDataDac1 = zeros(size(epochInds));
    epochDataDac2 = zeros(size(epochInds));
    for i=1:size(epochInds,1) % go through each timepoint
        epochDataDac1(i,:) = stimDACData(epochInds(i,:))*mVPerDacVal/10;
      
    end
    
    hold on
    meanEpochData = mean(epochDataDac1,1);
    xAxis = linspace(-preTimeMsec, postTimeMsec,length(meanEpochData));
    if iChNo == 1
        plot(xAxis, (meanEpochData-meanEpochData(1)+meanEpochDataSig(1)),'--','LineWidth',2,...
            'Color', [0.4 0.4 0.4] )
    end
    % plot data
    epochDataSigPlot = epochDataSig';
    % create x-axis
    xAxisVector = linspace(-preTimeMsec,postTimeMsec,size(epochDataSigPlot,1))';
    xAxisMat = repmat(xAxisVector,1, size(epochDataSigPlot,2));
    
    % plot data from each repeat if there is output from only one electrode
    if length(readOutChNo) == 1
        plot(xAxisMat, epochDataSigPlot, 'LineWidth', 1)
        lineWidthData = 2;
    else
        lineWidthData = 1;
    end
    % plot mean
    plot(xAxisVector, mean(epochDataSigPlot,2),'-', ...
        'LineWidth', lineWidthData,'Color',cmap(iChNo,:))
end
end


yLimVal = [0 1.1*max(meanEpochDataSig)];
axis('tight')
% title(['Response at Channel ', num2str(ChNo(iCh)) ,...
%     ', Triphasic Stim at Channel 89: Sorting 5, Cell 4']);
xlabel('Time (msec)','FontSize', fontSize)
ylabel('Amp (mV)','FontSize', fontSize);
% title(sprintf('Regional Scan #1, Biphasic Stimulation. Stim Ch %d; Readout ch %d: %3.0f mV (DAC write), %3.0f setting (DAC read), %3.0f setting (DAC write)', ...
%     stimChNo, readOutChNo, mVPerDacVal*settings.amps(j), dacValues(j),settings.amps(j)),'FontSize',fontSize);
xlim([xLimVal(1) xLimVal(2)])
ylim([yLimVal(1) yLimVal(2)])
set(findall(h,'type','text'),'fontSize',fontSize)
set(gca,'FontSize', fontSize)

stimChNoChar = num2str(stimChNo);
readOutChNoChar = num2str(readOutChNo);
titleName = strrep(sprintf('%s Run Name [%s] Pulse Type [%s %s]\nStim Channel [%s] Readout Channel [%s]', ...
    titleStr, dirNameSubfolder, pulseType, phaseType, stimChNoChar, readOutChNoChar ),' ','_');
fileName = strrep(sprintf('%s Run Name [%s] Pulse Type [%s %s] Stim Channel [%s] Readout Channel [%s]', ...
    titleStr, dirNameSubfolder, pulseType, phaseType, stimChNoChar, readOutChNoChar ),' ','_');fprintf('%s\n', titleName);
title(titleName, 'Interpreter', 'none','FontSize',11)

if doPrintToFile
    dirName = '../Figs/';
    saveas(h,fullfile(dirName, fileName),'fig');
    savefigtofile(h, dirName, fileName)
end

