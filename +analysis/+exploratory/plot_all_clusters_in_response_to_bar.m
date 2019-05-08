%% load R variable

expName = get_dir_date;
def = dirdefs();
% load configurations: configs(1)
load(fullfile(def.projHamster, 'sorting_in',expName, 'configurations.mat'));
load(fullfile(def.sortingOut, sprintf('%s_resultsForIan.mat', expName)));

runNo =1;
configColumn = runNo; configIdx= 3;
[tsMatrixAuto ] = spiketrains.extract_single_neur_spiketrains_from_felix_sorter_results(...
    R, configColumn, configIdx);

%%
% extract spike trains
load frameno_run_01
barsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_movingBar_2Reps.mat');
stimFrameInfo = barsSettings;
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
%% plot bars response
barsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_movingBar_2Reps.mat');

plotColor = 'k';
% idxSorted=1:96;
for j=34:length(tsMatrixAuto)
    
    h=figure, hold on, 
    k=1;
    for barOffset = [300, 0,-300]
        subplot(3,1,k)
        idx = intersect(find(barsSettings.rgb>0),find( barsSettings.offset==barOffset));
        
        [junk I] = sort(barsSettings.angle(idx));
        
        idxSorted = idx(I);
        for i=1:length(idxSorted)
            if ~iseven(i) %is odd
                text(0.2,5*i+2.5,num2str(barsSettings.angle(idxSorted(i))),'color', plotColor)
            end
            if iseven(barsSettings.angle(idxSorted(i)))
                plotColor = 'b';
            else
                plotColor = 'k';
            end
            ylim([ 0 90]),xlim([ 0 4])
            plot.raster(tsMatrixAuto(j).spikeTrains{idxSorted(i)}/2e4,'height', 2,'offset', 5*i,'color', plotColor);
            title(sprintf('rIdx = %d, R = %d, offset=%d', j, tsMatrixAuto(j).clus_num,barOffset ))
        end
        k=k+1;
    end
    
    junk = input('press enter')
    close(h)
end
% title(sprintf('bars (%s)',neurName));