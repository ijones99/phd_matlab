
%% Load data
expName = get_dir_date;
def = dirdefs();

Rall = load('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/29Jul2014_resultsForIan');
Rwn = load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', sprintf('%s_resultsForIan.mat', expName)))

flist={};flist{end+1} = '../proc/Trace_id1584_2014-07-29T12_02_01_5.stream.ntk';
mea1 = load_h5_data(flist);

% use alignGDFs program
gdf1 = Rall.R{1,1};
gdf2 = Rwn.R{1};

% get STA
numSquaresOnEdge=12;
load white_noise_frames.mat
load('frameno_run_01.mat')
configIdx = 1;

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


%% extract cell from gdf

%% Function list

allClus = unique(gdf(:,1));

for i = 1:100
configIdx = 14;
runNo = 1;
clusNo = allClus(i);

% get stim timechanges
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno{configIdx},interStimTime);

% get timestamps
gdf = Rall.R{configIdx, runNo};
stCell = spiketrain_analysis.gdf.extract_st_to_cell(gdf, clusNo, stimChangeTs)

% get idx for spot size
spotsSettings = file.load_single_var('settings/', 'stimFrameInfo_spots.mat');

 [Y,idxSpotsSorted] = sort(spotsSettings.dotDiam);

idxON = find(spotsSettings.rgb >  0);
idxOFF = find(spotsSettings.rgb ==  0);

idxSpotSizeON = intersect(idxSpotsSorted, idxON);
idxSpotSizeOFF = intersect(idxSpotsSorted, idxOFF);
%
runs = [];
runs.on = find(spotsSettings.rgb>0);
runs.off = find(spotsSettings.rgb==0);
[diamsSorted ISpots] = sort(spotsSettings.dotDiam(runs.on));

figure, hold on

for i=1:length(diamsSorted)
    plot.raster(stCell{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
    if i==1
        line([0 2.5], (5*i-2.5)*[1 1]);
    elseif diamsSorted(i-1)~=diamsSorted(i);
        line([0 2.5], (5*i-2.5)*[1 1]);
    elseif i==length(diamsSorted)
        line([0 2.5], (5*i+2.5)*[1 1]);
    end
    
end
title(sprintf('spots ON (%d)',clusNo));
[diamsSorted ISpots] = sort(spotsSettings.dotDiam(runs.off));
ISpots = ISpots +length(runs.off);
figure, hold on

% latencyMat: [repeats, size]
latencyMat = nan(length(diamsSorted)/length(unique(diamsSorted) ), ...
    length(unique(diamsSorted)))

for i=1:length(diamsSorted)
    plot.raster(stCell{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
    
    if not(isempty(stCell{ISpots(i)}))
        latencyMat(i) = stCell{ISpots(i)}(1)/2e4;
    end
    text(0,5*i,num2str(i));
    if i==1
        line([0 2.5], (5*i-2.5)*[1 1]);
    elseif diamsSorted(i-1)~=diamsSorted(i);
        line([0 2.5], (5*i-2.5)*[1 1]);
    elseif i==length(diamsSorted)
        line([0 2.5], (5*i+2.5)*[1 1]);
    end
   
end
title(sprintf('spots OFF (%d)',clusNo));

a = input('press enter>> ');
close all
end



