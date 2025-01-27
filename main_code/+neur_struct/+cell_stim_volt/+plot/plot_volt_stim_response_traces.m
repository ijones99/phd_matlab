function meanSig = plot_volt_stim_response(out, readOutChNo, varargin)
%% Plot stim data - all traces and mean
fileInd = 1;
doPrintToFile = 0;
titleStr = 'axon_stim_';
stimCellName = out.run_name;
% readOutChNo = [ 114];
stimDAC = 2;
stimElIdx = [];
readoutElIdx = [];
doUseChInTitle = 0;
meaData = [];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'cell_name')
            stimCellName = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_no')
            fileInd = varargin{i+1};
        elseif strcmp( varargin{i}, 'save')
            doPrintToFile = 1;
        elseif strcmp( varargin{i}, 'stim_dac')
            stimDAC = varargin{i+1};        
        elseif strcmp( varargin{i}, 'stim_elidx')
            stimElIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'readout_elidx')
            readoutElIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'mea_data')
            meaData = varargin{i+1};
            
        end
    end
end




pulseType = 'biphasic';
if strcmp(pulseType,'biphasic')
    numDACSwitchesPerStim = 3;
elseif strcmp(pulseType,'triphasic')
    numDACSwitchesPerStim = 4;
end

for iFileInd = 1:length(fileInd)
    
    % get readout channel
    if ~isempty(readoutElIdx)
        readoutInd = find(out.el_idx{fileInd(iFileInd)}==readoutElIdx);
        if isempty(readoutInd)
            error('readoutElIdx not found; most likely you must subtract one from all el numbers.\n');
            
        else
            readOutChNo = out.channel_nr{fileInd(iFileInd)}(readoutInd );
        end
        
    end
    
    
    %get stim channel
    if isempty(stimElIdx)
        stimChNo = out.configs_stim_volt.stimCh{fileInd(iFileInd)};
        stimInd = find(out.channel_nr{fileInd(iFileInd)}==stimChNo);
        stimElIdx = out.el_idx{fileInd(iFileInd)}(stimInd);
    else
        stimInd = find(out.el_idx{fileInd(iFileInd)}==stimElIdx);
        stimChNo = out.channel_nr{fileInd(iFileInd)}(stimInd);
    end
    ampIndex = 1:size(out.configs_stim_volt.amps2{fileInd(iFileInd)},1);
    
    if length(stimChNo) == 1
        phaseType = '';
    end
    
    mVPerDacVal = 10*1000*2.9 / 1024; %Volts
    signalGain = 959;
    
    out.configs_stim_volt.amps2{fileInd(iFileInd)}(ampIndex,1);
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
    meanSig = {};
    % settings
    % chNo = [ 73 85 91 98 96 20 84 95 77 27 33];
    %90%96 %92 ]; distal @ 92, proximal 90, 105 at cell body
    % localNtkIndNumber = find(ntk2.sig == readOutChNo)
    % get stim timepoints
    if stimDAC == 1
        stimDACData = out.configs_stim_volt.dac1{fileInd(iFileInd)};
    elseif stimDAC == 2
        stimDACData = out.configs_stim_volt.dac2{fileInd(iFileInd)};
    end
    
    [p2pStimValsPerPulse stimPulsePts] = get_dac_epochs_in_data( stimDACData, numDACSwitchesPerStim );
    dacValues = unique(p2pStimValsPerPulse);
    
    for j = ampIndex(1:end)
        dacSettingNum = j;
        stimValInds = find(p2pStimValsPerPulse == dacValues(dacSettingNum)); % indices of
        ... stimPulsePts for this DAC setting
            
    % get selected data; rows: indices for data around each timepoint
    if isempty(meaData)
        meaData = mysort.mea.CMOSMEA(strrep(out.configs_stim_volt.flist{fileInd(iFileInd)},'.ntk','.h5'), 'useFilter', 0, 'name', 'Raw');
    end
    
    epochInds = calculate_epoch_inds( stimPulsePts(stimValInds), preTimeMsec, ...
        postTimeMsec);
    for iChNo = 1:length(readOutChNo)
        if iscell(out.channel_nr)
            chInd = find(out.channel_nr{fileInd} == readOutChNo(iChNo));
        else
            chInd = find(out.channel_nr == readOutChNo(iChNo));
        end
        if isempty(chInd)
           fprintf('Error: wrong readout channel selected.\n');
           return
        end
        epochDataSig = zeros(size(epochInds));
        for i=1:size(epochInds,1)
            epochDataSig(i,:) = meaData.getData(epochInds(i,:),chInd);
            plotOffset = plotSpacing*j - mean(epochDataSig(i,:));
            epochDataSig(i,:) = plotOffset + epochDataSig(i,:);
        end
        meanEpochDataSig = mean(epochDataSig,1);
        
        epochDataDac1 = zeros(size(epochInds));
        epochDataDac2 = zeros(size(epochInds));
        for i=1:size(epochInds,1) % go through each timepoint
            epochDataDac1(i,:) = stimDACData(epochInds(i,:))*mVPerDacVal/10;
        end
        % plot data
        epochDataSigPlot = epochDataSig';
        % create x-axis
        xAxisVector = linspace(-preTimeMsec,postTimeMsec,size(epochDataSigPlot,1))';
        xAxisMat = repmat(xAxisVector,1, size(epochDataSigPlot,2));
        hold on
        meanEpochData = mean(epochDataDac1,1);
        xAxis = linspace(-preTimeMsec, postTimeMsec,length(meanEpochData));
        if iChNo == 1
            dacPulse = meanEpochData-meanEpochData(1)+meanEpochDataSig(1);
            plot(xAxis, dacPulse,'--','LineWidth',1,...
                'Color', [0.4 0.4 0.4] );
            text(xAxisVector(70), dacPulse(end)+80,  ...
                sprintf('pk2pk: %d mV',out.configs_stim_volt.amps2{fileInd(iFileInd)}(j,1)*2),'FontSize',11);
        end
        
        
        % plot data from each repeat if there is output from only one electrode
        if length(readOutChNo) == 1
            plot(xAxisMat, epochDataSigPlot, 'LineWidth', 1)
            lineWidthData = 2;
        else
            lineWidthData = 1;
        end
        % plot mean
        meanSig{end+1} = mean(epochDataSigPlot,2);
        plot(xAxisVector, meanSig{end},'-', ...
            'LineWidth', lineWidthData,'Color',cmap(iChNo,:))
        
        % plot light-stimulated footprint
        offsetFpWf = mean(meanSig{end}(end-15:end));
        %     plot(xAxisVector(1:length(footprintWaveform)), ...
        %         footprintWaveform+offsetFpWf,'-', 'LineWidth', ...
        %         1,'Color','r');
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
    % set(findall(h,'type','text'),'fontSize',fontSize)
    set(gca,'FontSize', fontSize)
    
    stimChNoChar = num2str(stimChNo);
    readOutChNoChar = num2str(readOutChNo);
    try
        if doUseChInTitle
            titleName = strrep(sprintf('%s[%s] Type[%s %s]\nStimCh[%s] ReadCh[%s]', ...
                titleStr, stimCellName, pulseType, phaseType, stimChNoChar, readOutChNoChar ),' ','_');
            fileName = strrep(sprintf('%s[%s] Type[%s %s] StimCh[%s] ReadCh[%s]', ...
                titleStr, stimCellName, pulseType, phaseType, stimChNoChar, readOutChNoChar ),' ','_');fprintf('%s\n', titleName);
            title(titleName, 'Interpreter', 'none','FontSize',11);
        else
            titleName = strrep(sprintf('%s[%s] Type[%s %s]\nStimEl[%d] ReadEl[%d]', ...
                titleStr, stimCellName, pulseType, phaseType, stimElIdx, readoutElIdx ),' ','_');
            fileName = strrep(sprintf('%s[%s] Type[%s %s] StimEl[%d] ReadEl[%d]', ...
                titleStr, stimCellName, pulseType, phaseType, stimElIdx, readoutElIdx ),' ','_');fprintf('%s\n', titleName);
            title(titleName, 'Interpreter', 'none','FontSize',11);
            
        end
    catch
        
        fprintf('Error title')
    end
    if doPrintToFile
        dirName = '../Figs/';
        saveas(h,fullfile(dirName, fileName),'fig');
        savefigtofile(h, dirName, fileName)
    end
    
end

end