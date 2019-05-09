% extract spike trains

stimFrameInfo = spotsSettings;
% get switch times
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(neur.spt.frameno,interStimTime);

if length(stimChangeTs)/2 ~= length(stimFrameInfo.rep)
    error('timestamps do not match.')
end
framenoSeparationTimeSec = 0.5;
adjustToZero = 1;
neur.spt.spikeTrains = extract_spiketrain_repeats_to_cell(st_5055n18.ts*2e4, ...
    stimChangeTs,adjustToZero);


%% plot spots
neurName = '';
% plot cell responses
spotsSettings = file.load_single_var('settings/', 'stimFrameInfo_spots.mat');

runs = [];
runs.on = find(spotsSettings.rgb>0);
runs.off = find(spotsSettings.rgb==0);
[diamsSorted ISpots] = sort(spotsSettings.dotDiam(runs.on));

figure, hold on

for i=1:length(diamsSorted)
    plot.raster(neur.spt.spikeTrains{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
    if i==1
        line([0 2.5], (5*i+2.5)*[1 1]);
    elseif diamsSorted(i-1)~=diamsSorted(i);
        line([0 2.5], (5*i+2.5)*[1 1]);
    elseif i==length(diamsSorted)
        line([0 2.5], (5*i+2.5)*[1 1]);
    end
    
end
title(sprintf('spots ON (%s)',neurName));
[diamsSorted ISpots] = sort(spotsSettings.dotDiam(runs.off));
ISpots = ISpots +length(runs.off);
figure, hold on
for i=1:length(diamsSorted)
    plot.raster(neur.spt.spikeTrains{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
    for i=1:length(diamsSorted)
        plot.raster(neur.spt.spikeTrains{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
        if i==1
            line([0 2.5], (5*i+2.5)*[1 1]);
        elseif diamsSorted(i-1)~=diamsSorted(i);
            line([0 2.5], (5*i+2.5)*[1 1]);
        elseif i==length(diamsSorted)
            line([0 2.5], (5*i+2.5)*[1 1]);
        end
    end
    
end
title(sprintf('spots OFF (%s)',neurName));

%% plot bars response
barsSettings = file.load_single_var('settings/', 'stimFrameInfo_movingBar_2Reps.mat');
idx = intersect(find(barsSettings.rgb==0),find( barsSettings.offset==300));
figure, hold on

[junk I] = sort(barsSettings.angle(idx))
idxSorted = idx(I);
% idxSorted=1:96;
for i=1:length(idxSorted)
    if ~iseven(i)
        plotColor = 'k';
    else
        plotColor = 'r';
    end
    plot.raster(neur.mb.spikeTrains{idxSorted(i)}/2e4,'height', 2,'offset', 5*i,'color', plotColor);
    text(0.6,5*i,num2str(i))
end
title(sprintf('bars (%s)',neurName));


%% plot all clusters
%%
barsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_movingBar_2reps.mat');
idx = intersect(find(barsSettings.rgb>0),find( barsSettings.offset==-300));
figure, hold on

[junk I] = sort(barsSettings.angle(idx))
idxSorted = idx(I);



for j=1:length(tsMb.spikeTrains)
    figure, hold on
    for i=1:length(idxSorted)
        if iseven(i)
            plotColor = 'k';
        else
            plotColor = 'k';
        end
        plot.raster(tsMb.spikeTrains{j}{idxSorted(i)}/2e4,'height', 2,'offset', 5*i,'color', plotColor);
    end
end

