function plot_spots_response(st, stimChangeTs)

neurName = '';
% plot cell responses
spotsSettings = file.load_single_var('settings/', 'stimFrameInfo_spots.mat');


stimFrameInfo = spotsSettings;

if length(stimChangeTs)/2 ~= length(stimFrameInfo.rep)
    error('timestamps do not match.')
end
framenoSeparationTimeSec = 0.5;
adjustToZero = 1;
neur.spt.spikeTrains = extract_spiketrain_repeats_to_cell(st, ...
    stimChangeTs,adjustToZero);



runs = [];
runs.on = find(spotsSettings.rgb>0);
runs.off = find(spotsSettings.rgb==0);
% sorted by size
[diamsSorted ISpots] = sort(spotsSettings.dotDiam(runs.on));

h=figure, hold on
figs.set_size_fig(h,[ 21         264        1346         748]);
subplot(1,2,1);

uniqueDiam = unique(diamsSorted)';
diamLabel = num2str(uniqueDiam);
numReps = 5;
xCoordLabel = -0.5*ones(6,1);
yCoordLabel = [12.5:25:25*5+12.5]';
text(xCoordLabel, yCoordLabel , diamLabel,'Color','b')

for i=1:length(diamsSorted)
    plot.raster(neur.spt.spikeTrains{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
    if i==1
        line([0 2.5], (5*i-2.5)*[1 1]);
    elseif diamsSorted(i-1)~=diamsSorted(i);
        line([0 2.5], (5*i-2.5)*[1 1]);
    elseif i==length(diamsSorted)
        line([0 2.5], (5*i+2.5)*[1 1]);
    end
    
end
title(sprintf('spots ON (%s)',neurName));
[diamsSorted ISpots] = sort(spotsSettings.dotDiam(runs.off));
ISpots = ISpots +length(runs.off);
subplot(1,2,2); hold on
text(xCoordLabel, yCoordLabel , diamLabel,'Color','b')
for i=1:length(diamsSorted)
    plot.raster(neur.spt.spikeTrains{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
    for i=1:length(diamsSorted)
        plot.raster(neur.spt.spikeTrains{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
        if i==1
            line([0 2.5], (5*i-2.5)*[1 1]);
        elseif diamsSorted(i-1)~=diamsSorted(i);
            line([0 2.5], (5*i-2.5)*[1 1]);
        elseif i==length(diamsSorted)
            line([0 2.5], (5*i+2.5)*[1 1]);
        end
    end
    
end
title(sprintf('spots OFF (%s)',neurName));


end