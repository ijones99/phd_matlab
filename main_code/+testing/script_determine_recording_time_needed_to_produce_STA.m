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


%% This script computes the RF (STA) for differing durations of time
% in order to determine how much time is necessary to create 
% a receptive field
% SETTINGS:
doPlot = 0;

%
clusNos = unique(gdf1(:,1))';
timeLimMins = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
timeLim = timeLimMins*2e4*60;
bestSTAInd = [];
corrVal = [];
subplotCounter = 1;
numClus = length(clusNos);
numShift =0;
for iClus = 1+numShift:numClus+numShift
    for iTimeLim = 1:length(timeLim)
        idxTsPerClus = find(gdf1(:,1)==clusNos(iClus));
        stAll = gdf1(idxTsPerClus,2);
        stLim = stAll(find(stAll<timeLim(iTimeLim)));
        
        if length(stLim)>0
            [staFrames staTemporalPlot plotInfo bestSTAInd ] =...
                ifunc.sta.make_sta( stLim, ...
                white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
                frameno{configIdx});
            bestIm(:,:,iTimeLim) = staFrames(:,:,bestSTAInd);
            if doPlot
                subplot(numClus,length(timeLim), subplotCounter);
                imagesc(bestIm(:,:,iTimeLim))
                axis square, axis off
                title(sprintf('%d min\n%d spk', timeLimMins(iTimeLim), length(stLim)));
            end
        end
        subplotCounter = subplotCounter+1;
    end
    
    for j=1:size(bestIm,3)
        corrVal(j,iClus) = corr2(bestIm(:,:,j), bestIm(:,:,end));
    end
    iClus
end
save corrVal corrVal

[rows,cols,vals] = find(corrVal(end-7:end,:)<0.5);
idxBadResponses = unique(cols);
idxGoodResponses = find(not(ismember(1:size(corrVal,2),idxBadResponses)));
figure, plot(corrVal(:,idxGoodResponses))



        %%
        
        %         [profData2{iClus}.staFrames profData2{iClus}.staTemporalPlot ...
        %             profData2{iClus}.plotInfo profData2{iClus}.bestSTAInd h] =...
        %             ifunc.sta.make_sta( stLim, ...
        %             white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        %             frameno{configIdx});,'do_print';
        %
        %         figure,
        %         subplot(1,2,1)
        %         imagesc(profData1{iClus}.staFrames(:,:,profData1{iClus}.bestSTAInd ))
        %         %     title(sprintf('Cluster %d', R.St1IDs(idxKeep(iClus))));
        %         axis square
        %
        %         subplot(1,2,2)
        %         imagesc(profData2{iClus}.staFrames(:,:,profData2{iClus}.bestSTAInd ))
        %         %     title(sprintf('Cluster %d', R.St2IDs(R.k2f(idxKeep(iClus)))));
        %         axis square
        %
        %         %     dirNameStaPlot = '../Figs/spikesortingProblem/STA_comparisons';
        %         %     fileNameStaPlot = sprintf('sta_clus_%d_vs_clus_%d',  R.St1IDs(idxKeep(iClus)), ...
        %         %         R.St2IDs(R.k2f(idxKeep(iClus))));
        %         %     save.save_plot_to_file(dirNameStaPlot, fileNameStaPlot, 'fig');
        %         fprintf('num spikes %d\n', length(stLim))
        %         pause(0.5)
        %     end
        %     close all
        % end