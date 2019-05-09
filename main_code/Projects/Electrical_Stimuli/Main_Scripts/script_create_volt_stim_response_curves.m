
%% run function for getting stim response (sigmoidal curves) 
regionalOutFile = 'neur_regional_scan_01';
outRegional = load(regionalOutFile);outRegional = outRegional.out;
%%
[out] = neur_struct.cell_stim_volt.compute_volt_stimulus_response(outRegional, ...
    out,'set_stim_and_readout',0)

%% plot regional footprint
% load regional footprint data

[out] = neur_struct.cell_stim_volt.compute_volt_stimulus_response(outRegional, ...
    out,'set_stim_and_readout',1)

%% plot the response circles over the contour plot of the p2k values

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Original script: 20.01.2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure, hold on
responseCurve = [];
stimDAC = 2;
preTimeMsec = 1;
postTimeMsec = 5;

stimCellName = 'stim_cell_04';
% [elidxInFile  chNoInFile] = get_elidx_from_el2fi(sprintf('../Configs/%s',stimCellName));

% indices in footprint matrix
elidxInFile = 5791;
fpIdx = multifind(out.el_idx, elidxInFile,'first');

% select readout els
fpIdxReadout = fpIdx(1);
% el numbers of interest
elidxReadout = out.el_idx(fpIdxReadout);

ic50 = [];

for fileInd = 1%:length(out.flist)-5

flist = {}; flist{1} = out.flist{fileInd};
%
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
mea1 = mysort.mea.CMOSMEA(strrep(flist{1},'.ntk','.h5'), 'useFilter', ...
    0, 'name', 'Raw');

% load dac info
ntkExtractedFieldsName = strrep(strrep(flist{1},'.stream','_extract_fld'), ...
    '.ntk','.mat');
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
    phaseType = 'Same';
end

% get data
% amplitude index
ampIndex = 3;

chNumbersMea1 = mea1.getChannelNr;
elNumbersMea1 = mea1.MultiElectrode.getElectrodeNumbers;

pulseType = 'biphasic';
if strcmp(pulseType,'biphasic')
    numDACSwitchesPerStim = 3;
elseif strcmp(pulseType,'triphasic')
    numDACSwitchesPerStim = 4;
end

% get stim timepoints
if stimDAC == 1
    stimDACData = ntkOut.dac1;
elseif stimDAC == 2
    stimDACData = ntkOut.dac2;
end

threshNumTimesRms = 3.5;
plotChoice = 'no_plot';
zeroStimVals = find(out.configs_stim_volt.amps2{1}(:,1)==0);
out.configs_stim_volt.amps2{1}(zeroStimVals,:) = [];
doRecalculateCurves = 1;
for ampIndex = 1:length(out.configs_stim_volt.amps2{1}(:,1))
    if doRecalculateCurves
        [traceIdxSpike numReps] = spike_detector_i(stimDACData, ...
            numDACSwitchesPerStim,ampIndex, ...
            preTimeMsec, postTimeMsec, elNumbersMea1, elidxReadout, ...
            mea1, threshNumTimesRms,...
            plotChoice,'ylim', [-200,300]);
    end
    responseCurve(fileInd, ampIndex) = length(traceIdxSpike)/numReps;
    title(num2str(ampIndex));
end

x = out.configs_stim_volt.amps2{1}(:,1)*2;
y = responseCurve(fileInd,:);
plotColor = rand(1,3);
set(gca,'FontSize',15)
plot(x,y,'o--', 'Color',plotColor ,'LineWidth', 2)
try
    fittedData{fileInd} = fit_sigmoidal_curve_to_percent_response(x,y);
%     plot(fittedData{fileInd}, 'k');
    yFit{fileInd} = feval(fittedData{fileInd} ,x);
    plot(x,yFit{fileInd},'Color', plotColor);
catch
    fittedData{fileInd} = [];
    fprintf('Error\n')
end
drawnow
[junk ic50idx] = min(abs(yFit{fileInd}-0.5));
ic50(fileInd) = x(ic50idx);
end
legend off
save(sprintf('%s_responseCurves.mat', cellSearchScanName ), ...
    'responseCurve','fittedData');

legend(num2str(chNoInFile'));
title(sprintf('Response Curves: %s',stimCellName), 'Interpreter', 'none','FontSize', 16);
xlabel('Stimulus Amplitude (mV)','FontSize', 15);
ylabel('Cell Response (decimal)','FontSize', 15);


  save(sprintf('%s.mat', fileName),'out');
