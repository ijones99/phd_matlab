% get settings file
stimCellName = 'stim_cell_04';
dirName = sprintf('log_files/%s/',stimCellName); 
settings = merge_settings_files(dirName);
flistAll = print_stim_settings_data(settings, 'stimType', ...                        
    'stimCh', 'flist' );

% % save data
% flistFileNameID = get_flist_file_id(flist{1}); % use first flist value
% save(sprintf('stim_cell_%s.mat', flistFileNameID), 

%% Convert files and load DAC info
fileName = 'stim_cell_neur_01'; 
junk = input(sprintf('file name "%s." ok?', fileName));

fileInd = 7;
for m = 1
    flist = {}; flist{1} = flistAll{fileInd};
    cell2mat(settings.stimCh);
    %
    doPreFilter = 0;
    % convert file
    recFreqMsec = 2e1;
    
    out = {};
    out.run_name = stimCellName;
    out.flist = flistAll;
    out = add_field_to_structure(out,'configs_stim_light', settings);
    out = add_field_to_structure(out,'dir_log_files_stim_light', dirName);
    
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
    out.channel_nr = mea1.getChannelNr;
    out.el_idx = mea1.MultiElectrode.getElectrodeNumbers;
    elPos = mea1.MultiElectrode.getElectrodePositions;
    % mea1{1}.getChannelNr
    out = add_field_to_structure(out,'channel_nr', mea1.getChannelNr);
    out = add_field_to_structure(out,'x', elPos(:,1)');
    out = add_field_to_structure(out,'y', elPos(:,2)');
    % load dac info
    ntkExtractedFieldsName = strrep(strrep(flist{1},'.stream','_extract_fld'),'.ntk','.mat');
    if ~exist(ntkExtractedFieldsName,'file')
        ntkOut = load_field_ntk(flist{1}, {'dac1', 'dac2'});
        save(ntkExtractedFieldsName,'ntkOut');
    else
        load(ntkExtractedFieldsName)
    end
    out = add_field_to_structure(out,'dac1', ntkOut.dac1);
    out = add_field_to_structure(out,'dac2', ntkOut.dac2);
    
    if sum(diff(ntkOut.dac2+ntkOut.dac1)) == 0
        phaseType = 'Opposed';
    else
        phaseType = 'Same';
    end
    
    out = add_field_to_structure(out,'configs_stim_light.stim_phase_type', phaseType);
    
    save(sprintf('neur_%s.mat', fileName),'out');
end
%% plot stim data
readOutChNo = 80;
titleStr = 'test';
stimCellName = '';
doPrintToFile = 0;
out = plot_electric_stimulus_response(out, mea1, readOutChNo, ...
    titleStr, stimCellName,  fileInd, doPrintToFile);

%% Plot stim data - all traces and mean

doPrintToFile = 1;
titleStr = 'axon_stim_';
readOutChNo = [ 86];
stimDAC = 2;

pulseType = 'biphasic';
if strcmp(pulseType,'biphasic')
    numDACSwitchesPerStim = 3;
elseif strcmp(pulseType,'triphasic')
    numDACSwitchesPerStim = 4;
end

stimChNo = settings.stimCh{fileInd};
ampIndex = 1:16;

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
meanSig = {};
% settings
% chNo = [ 73 85 91 98 96 20 84 95 77 27 33];
%90%96 %92 ]; distal @ 92, proximal 90, 105 at cell body
% localNtkIndNumber = find(ntk2.sig == readOutChNo)
% get stim timepoints
if stimDAC == 1
    stimDACData = ntkOut.dac1;
elseif stimDAC == 2
    stimDACData = ntkOut.dac2;
end

[p2pStimValsPerPulse stimPulsePts] = get_dac_epochs_in_data( stimDACData, numDACSwitchesPerStim );
dacValues = unique(p2pStimValsPerPulse);

for j = ampIndex(1:end-1)
    dacSettingNum = j;
    stimValInds = find(p2pStimValsPerPulse == dacValues(dacSettingNum)); % indices of
    ... stimPulsePts for this DAC setting
        
% get selected data; rows: indices for data around each timepoint
epochInds = calculate_epoch_inds( stimPulsePts(stimValInds), preTimeMsec, ...
    postTimeMsec);
for iChNo = 1:length(readOutChNo)
    chInd = find(out.channel_nr == readOutChNo(iChNo));
    epochDataSig = zeros(size(epochInds));
    for i=1:size(epochInds,1)
        epochDataSig(i,:) = mea1.getData(epochInds(i,:),chInd);
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
            sprintf('pk2pk: %d mV',settings.amps2{1}(j+1,1)*2),'FontSize',11);
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
titleName = strrep(sprintf('%s[%s] Type[%s %s]\nStimCh[%s] ReadCh[%s]', ...
    titleStr, stimCellName, pulseType, phaseType, stimChNoChar, readOutChNoChar ),' ','_');
fileName = strrep(sprintf('%s[%s] Type[%s %s] StimCh[%s] ReadCh[%s]', ...
    titleStr, stimCellName, pulseType, phaseType, stimChNoChar, readOutChNoChar ),' ','_');fprintf('%s\n', titleName);
title(titleName, 'Interpreter', 'none','FontSize',11);

if doPrintToFile
    dirName = '../Figs/';
    saveas(h,fullfile(dirName, fileName),'fig');
    savefigtofile(h, dirName, fileName)
end
%% zoom in
xlim([ -1.0508    5.1684])
ylim([3.3508e+03  5.8082e+03])
if doPrintToFile
    dirName = '../Figs/';
    saveas(h,fullfile(dirName, strcat(fileName,'_zoom')),'fig');
    savefigtofile(h, dirName, strcat(fileName,'_zoom'))
end
%% plot stim data - average at different els
% settings
doPrintToFile = 0;

chNo = [ mea1.getChannelNr'];
preTimeMsec = 5; postTimeMsec = 20;
pulseType = 'biphasic';
if strcmp(pulseType,'biphasic')
    numDACSwitchesPerStim = 3;
elseif strcmp(pulseType,'triphasic')
    numDACSwitchesPerStim = 4;
end
recFreq = 2e4;
h=figure, hold on
set(h, 'Position', [72, 92, 1418, 1020]);
cmap = pmkmp(length(chNo),'IsoL');
ampsInd = 9;
for j = ampsInd
    dacSettingNum = j;
    
    % get stim timepoints
    voltSwitchTime = diff(ntkOut.dac1);
    switchTimePts = find(voltSwitchTime~=0);
    
    stimPulsePts = switchTimePts(1:numDACSwitchesPerStim:end);
    voltageNextToPulse = switchTimePts(2:numDACSwitchesPerStim:end);
    
    % get voltage values
    p2pStimValsPerPulse = ntkOut.dac1(stimPulsePts)-ntkOut.dac1(voltageNextToPulse);
    dacValues = unique(p2pStimValsPerPulse);
    stimValInds = find(p2pStimValsPerPulse == dacValues(dacSettingNum));
    
    % get selected data
    
    epochInds = calculate_epoch_inds( stimPulsePts(stimValInds), preTimeMsec, ...
        postTimeMsec);
    
    epochDataDac1 = zeros(size(epochInds));
    for i=1:size(epochInds,1)
        epochDataDac1(i,:) = ntkOut.dac1(epochInds(i,:));
    end
    % plot data
    %         plot(epochDataDac1')
    hold on
    % plot([1:size(epochDataDac1,2)]*1000/recFreq-preTimeMsec, mean(epochDataDac1,1),'LineWidth',2,'Color', [0 0 0])
    meanEpochData = mean(epochDataDac1,1);
    plot(meanEpochData-meanEpochData(1),'--','LineWidth',2,'Color', [0 0 0 ])
    % title(['DAC value ', num2str(dacValues(dacSettingNum))]);
    
end
%
for iCh =1:length(chNo)
    for j = ampsInd
        
        
        chInd = find(mea1.getChannelNr==chNo(iCh));
        dacSettingNum = j;
        
        % get stim timepoints
        voltSwitchTime = diff(ntkOut.dac1);
        switchTimePts = find(voltSwitchTime~=0);
        
        stimPulsePts = switchTimePts(1:numDACSwitchesPerStim:end);
        voltageNextToPulse = switchTimePts(2:numDACSwitchesPerStim:end);
        
        % get voltage values
        p2pStimValsPerPulse = ntkOut.dac1(stimPulsePts)-ntkOut.dac1(voltageNextToPulse);
        dacValues = sort(unique(p2pStimValsPerPulse),'descend');
        stimValInds = find(p2pStimValsPerPulse == dacValues(dacSettingNum));
        
        % get selected data
        
        epochInds = calculate_epoch_inds( stimPulsePts(stimValInds), preTimeMsec, ...
            postTimeMsec);
        
        epochData = zeros(size(epochInds));
        for i=1:size(epochInds,1)
            epochData(i,:) = mea1.getData(epochInds(i,:),chInd);
        end
        % plot data
        %         plot(epochData')
        hold on
        % plot([1:size(epochData,2)]*1000/recFreq-preTimeMsec, mean(epochData,1),'LineWidth',2,'Color', [0 0 0])
        if iCh/2==round(iCh/2)
            lineStyle= '--';
        elseif iCh/3==round(iCh/3)
            lineStyle= '*';
        elseif iCh/5==round(iCh/5)
            lineStyle= 'o';
        
        else
             lineStyle= '-';
        end
        plot(mean(epochData,1),lineStyle,'LineWidth',2,'Color', cmap(iCh,:))
        % title(['DAC value ', num2str(dacValues(dacSettingNum))]);
        
    end
end
axis('tight')
% title(['Response at Channel ', num2str(ChNo(iCh)) ,...
%     ', Triphasic Stim at Channel 89: Sorting 5, Cell 4']);
xlabel('Time (msec)')
ylabel('Amp (arbitrary units)');

title(sprintf('Regional Scan #1, Biphasic Stimulation. Stim Ch %d; %3.0f mV (DAC write), %3.0f setting (DAC read), %3.0f setting (DAC write)', ...
    stimChNo, mVPerDacVal*settings.amps(j), dacValues(j),settings.amps(j)),'FontSize',fontSize);


legendVals = num2str(abs(chNo'),'ch %d'); 
firstVal = repmat(' ',1,size(legendVals,2));
firstVal(1,1:4) = 'stim'; 
legendVals = [firstVal; legendVals]
legend(legendVals)
if doPrintToFile
    fileName = sprintf('%s_%s_Response_Traces_StimCh_%d_%03.0f_mV_%dDAC_read_Val_%dDAC_write',sortingRunName,...
        pulseType, stimChNo, mVPerDacVal*dacValues(j),dacValues(j),settings.amps(j));
    dirName = '../Figs/';
    saveas(h,fullfile(dirName, fileName),'fig');
    savefigtofile(h, dirName, fileName)
end



%% plot stim data - means
% settings
% chNo = [ 73 85 91 98 96 20 84 95 77 27 33];
readOutChNo = 117%90%96 %92 ]; distal @ 92, proximal 90, 105 at cell body
stimChNo = 62;
xLimVal = [-5 15];
yLimVal = [1500 1500];
ampIndex = 9;

sourceRaw = 1;
doPrintToFile = 0;


mVPerDacVal = 1.6949;
preTimeMsec = 5; postTimeMsec = 15;
fontSize = 18;

pulseType = 'biphasic';
if strcmp(pulseType,'biphasic')
    numDACSwitchesPerStim = 3;
elseif strcmp(pulseType,'triphasic')
    numDACSwitchesPerStim = 4;
end
recFreq = 2e4;
h=figure, hold on
set(h, 'Position', [72, 92, 1418, 1020]);
cmap = colormap;

% plot data
for iCh =1:length(readOutChNo)
    for j = ampIndex
        
        
        chInd = find(mea1.getChannelNr==readOutChNo(iCh));
        dacSettingNum = j;
        
        % get stim timepoints
        voltSwitchTime = diff(ntkOut.dac1);
        switchTimePts = find(voltSwitchTime~=0);
        
        stimPulsePts = switchTimePts(1:numDACSwitchesPerStim:end);
        voltageNextToPulse = switchTimePts(2:numDACSwitchesPerStim:end);
        
        % get voltage values
        p2pStimValsPerPulse = ntkOut.dac1(voltageMaxInds)-ntkOut.dac1(voltageMinInds);
        dacValues = unique(p2pStimValsPerPulse);
        stimValInds = find(p2pStimValsPerPulse == dacValues(dacSettingNum));
        
        % get selected data
        
        epochInds = calculate_epoch_inds( stimPulsePts(stimValInds), preTimeMsec, ...
            postTimeMsec);
        
        epochData = zeros(size(epochInds));
        for i=1:size(epochInds,1)
            epochData(i,:) = mea1.getData(epochInds(i,:),chInd-1);
        end
        % plot data
        epochDataPlot = epochData';
        % create x-axis
        xAxisVector = linspace(-preTimeMsec,postTimeMsec,size(epochDataPlot,1))';
        xAxisMat = repmat(xAxisVector,1, size(epochDataPlot,2));
        plot(mean(xAxisMat,2), mVPerDacVal*mean(epochDataPlot,2), 'LineWidth', 2,'Color', cmap(2*j,:))
        
        hold on
        
    end
end
legend(num2str(round(dacValues(ampIndex)*mVPerDacVal)))
doPlot
axis('tight')
% title(['Response at Channel ', num2str(ChNo(iCh)) ,...
%     ', Triphasic Stim at Channel 89: Sorting 5, Cell 4']);
xlabel('Time (msec)','FontSize', fontSize)
ylabel('Amp (mV)','FontSize', fontSize);
title(sprintf('Regional Scan #1, Triphasic Stimulation at ch %d (Axon)', ...
    readOutChNo),  'FontSize', fontSize);
xlim([xLimVal(1) xLimVal(2)])
ylim([yLimVal(1) yLimVal(2)])

figure(h)

set(gca,'FontSize', fontSize)
set(findall(h,'type','text'),'fontSize',fontSize)

% legendVals = num2str(abs(readOutChNo'),'ch %d'); 
% legendVals = ['stim '; legendVals]
% legend(legendVals)
% title(sprintf('Regional Scan #1, Biphasic Stimulation at ch 6 for %d mV', settings.amps(j)))
if doPrintToFile
    fileName = sprintf('%s_Response_Traces_StimCh_%d_ReadoutCh_%d',sortingRunName,...
        stimChNo, readOutChNo);
    dirName = '../Figs/';
    saveas(h,fullfile(dirName, fileName),'fig');
    savefigtofile(h, dirName, fileName)
end

%%
figure,plot(ntkOut.dac1), hold on, plot(stimPulsePts,ones(1,length(stimPulsePts))*500,'r.'), ...
    plot(abs(switchTimePts),ones(1,length(switchTimePts))*499,'g.')



%% plot all of the footprints for the cell search

h=figure
dsCellIdx = 1:length(SC(1).localSortingID);
numberSubplotsOnEdge = ceil(sqrt(length(dsCellIdx)));

nElsInFootprint = 10;
PLOT_PROPAGATION = 1;
PLOT_FOR_NEUROROUTER = 1;

dsCellIdx = 1:length(SC(1).localSortingID);                   % local inds of DS cells
colorMap=pmkmp(length(dsCellIdx),'IsoL');
for i=dsCellIdx
    figure
    hold on
    
    elPositionXY = TL(1).MES.electrodePositions;
    waveform = SC(1).T_merged(:,:,i);
    waveform = permute(waveform, [3 2 1]);
    elNumber = TL(1).MES.electrodeNumbers;
    if PLOT_PROPAGATION
        plot_propagation_direction(elPositionXY, waveform, ...
            elNumber, nElsInFootprint)
        hold on
    end
    
    
    if PLOT_FOR_NEUROROUTER
        [h1 h2] = plot_footprints_simple( elPositionXY, waveform, elNumber, ...
        'plot_color',colorMap(find(dsCellIdx==i),:), 'format_for_neurorouter',...
        'line_width', 1, 'hide_els_plot'); 
    else
        
        [h1 h2] = plot_footprints_simple( elPositionXY, waveform, elNumber, ...
            'plot_color',colorMap(find(dsCellIdx==i),:),'hide_els_plot', ...
            'rev_y_dir');
        
    end
%     title(sprintf('Sorting #%d, cell#%d',sortGroupNumber, i))
% 
    hold off
    axis tight
    axis equal
    axis off
    fileName = sprintf('Footprint_%s_cell%d_plot',sortingRunName,i);
    dirName = '../Figs/';
    saveas(h,fullfile(dirName, fileName),'fig');
    savefigtofile(h, dirName, fileName)
 
end


%% plot full footprint over regional scan
figure, hold on

for clusterNo = 7%1:10

spikeTimes = clusterSorting;


for i=2:length(mea1)
    if i==1
        selSpikeTimes = spikeTimes(find(spikeTimes(:,2)<dataChunkParts(i)));
    else
        selSpikeTimes = spikeTimes(find(and(spikeTimes(:,2)>dataChunkParts(i-1), spikeTimes(:,2)<dataChunkParts(i))),:);
        selSpikeTimes(:,2) = selSpikeTimes(:,2)-dataChunkParts(i-1);
    end
    SSC = mysort.spiketrain.SpikeSortingContainer('ClusterSorting', selSpikeTimes, 'wfDataSource', mea1{i}, 'nMaxSpikesForTemplateCalc' , 500);
    TL = SSC.getTemplateList();
    for k=clusterNo%:length(TL)
        idx=find([TL.name]== clusterNo);
        if ~isempty(idx)
            plot_footprints_simple(TL(idx).MultiElectrode.electrodePositions, TL(idx).waveforms', ...
                'input_templates','hide_els_plot',...
                'plot_color','b','rev_x_dir', ...
                'format_for_neurorouter')   %'plot_color',rand(1,3))
        else
            warning('cluster number not found in configuration.');
        end
        %         mysort.plot.templates2D(TL(k).waveforms, TL(k).MultiElectrode.electrodePositions, 1000, 0, 'ah', ah)
        
    end
    
    drawnow
end
legend(num2str([clusterNo]'));

title(sprintf('%s Scan, Cluster Number %d', sortingRunName, clusterNo),...
    'interpreter', 'none');

end



