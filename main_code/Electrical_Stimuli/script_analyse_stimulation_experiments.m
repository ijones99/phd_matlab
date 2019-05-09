
%% load stimulation parameters
a = load('Stimulation_Variables_neur05stim.mat');

%% load map file
load global_cmos
Info.Map = loadmapfile(Info.FileName.Map,1111); % load Info.FileName.Map and plot elc locations in figure 1111

%% prune unconnected channels
fieldVals = [];
mapFields = fields(Info.Map);
for i=1:length(mapFields)
    fieldVals{i} = getfield(Info.Map, mapFields{i});
    fieldVals{i} = fieldVals{i}(validMapInds)';
    if size(fieldVals{i},1) > size(fieldVals{i},2)
        fieldVals{i} = fieldVals{i}';
    end
    eval(['Info.Map.',mapFields{i},'=fieldVals{i}']);
end
%% rearrange datastream matrix
[colNumber channelNum] = map2traceinds(Info.Map.ch, ...
    1:length(Info.Map.ch));
target_traceMapOrder = target_trace(:,colNumber,:);

%% view waveforms
elIdx = 4; % reference number of channel (not idx, not ch number)
iVolt = 2; % reference number for voltage
iEpoch = 1; % epoch number (repeat number at this voltage)

% plot settings
plotSpacing = 100;

% make figure
h = figure('Units','normalized','position',[0.6 0 0.3 1]);
isolatedTrace = {};

% select and extract epocs of interest
selEpochs = find(a.voltageReps==a.voltages(iVolt)); % in this case, each epoch
% contains one repetition for one stimulus electrode at one voltage
[target_trace epoch map] = extractTrigRawTrace( Info, NaN, ...
    'fulltrace','epoch',selEpochs(iEpoch));


traces = squeeze(target_traceMapOrder(elIdx, :,:))'; % reduce dimensions
tracesSpaced = space_traces_along_yaxis(traces, plotSpacing); % space the traces along the y axis for better view
plot(tracesSpaced,'k','LineWidth',2)
ylim([-1000 7000]);
title(sprintf('Stim Ch %d, %dmV, 30 Repeats',a.stimChannels(elIdx),a.voltages(iVolt)),...
    'FontSize', 16)


%% sort els according to xy coordinates

xyCoords = [Info.Map.px',Info.Map.py'];
[xyCoordsSort xySpatialSortInds] = sortrows(xyCoords, [1 2])







