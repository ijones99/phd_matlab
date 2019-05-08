%% load R variable

expName = get_dir_date;
def = dirdefs();
% load configurations: configs(1)
load(fullfile(def.projHamster, 'sorting_in',expName, 'configurations.mat'));
load(fullfile(def.sortingOut, sprintf('%s_resultsForIan.mat', expName)));

runNo =1;
configColumn = runNo; configIdx= 17;
[tsMatrixAuto ] = spiketrains.extract_single_neur_spiketrains_from_felix_sorter_results(...
    R, configColumn, configIdx);

%%
% extract spike trains
load frameno_run_01
spotsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_spots.mat');
stimFrameInfo = spotsSettings;
% get switch times
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno{configIdx},interStimTime);

if length(stimChangeTs)/2 ~= length(stimFrameInfo.rep)
    error('timestamps do not match.')
end
framenoSeparationTimeSec = 0.5;
adjustToZero = 1;

for i=1:length(tsMatrixAuto)
    tsMatrixAuto(i).spikeTrains = extract_spiketrain_repeats_to_cell(tsMatrixAuto(i).st{1}, ...
        stimChangeTs,adjustToZero);
    progress_info(i, length(tsMatrixAuto))
end

%
%% plot spots response

neurName = '';
% plot cell responses
spotsSettings = file.load_single_var('settings/', 'stimFrameInfo_spots.mat');

% 
runs = [];
runs.on = find(spotsSettings.rgb>0);
runs.off = find(spotsSettings.rgb==0);


for j = 1:length(tsMatrixAuto)
    [diamsSorted ISpots] = sort(spotsSettings.dotDiam(runs.on));
    figure, hold on
    
    for i=1:length(diamsSorted)
        plot.raster(tsMatrixAuto(j).spikeTrains{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
        if i==1
            line([0 2.5], (5*i-2.5)*[1 1]);
        elseif diamsSorted(i-1)~=diamsSorted(i);
            line([0 2.5], (5*(i)-2.5)*[1 1]);
        elseif i==length(diamsSorted)
            line([0 2.5], (5*i+2.5)*[1 1]);
        end
        
    end
    title(sprintf('spots ON - rIdx = %d, R = %d', j, tsMatrixAuto(j).clus_num))
    [diamsSorted ISpots] = sort(spotsSettings.dotDiam(runs.off));
    ISpots = ISpots +length(runs.off);
    figure, hold on
    for i=1:length(diamsSorted)
        plot.raster(tsMatrixAuto(j).spikeTrains{ISpots(i)}/2e4,'height', 2,'offset', 5*i);
        if i==1
            line([0 2.5], (5*i-2.5)*[1 1]);
        elseif diamsSorted(i-1)~=diamsSorted(i);
            line([0 2.5], (5*(i)-2.5)*[1 1]);
        elseif i==length(diamsSorted)
            line([0 2.5], (5*i+2.5)*[1 1]);
        end
        
    end
    
    
    title(sprintf('spots OFF - rIdx = %d, R = %d', j, tsMatrixAuto(j).clus_num))
    junk = input('enter')
    close all
end