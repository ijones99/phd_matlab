%     Rall       Rwn
%     1.0000    5         8.0000
%     2.0000    2.0000         0
%     5.0000   22.0000    1.0000
%     6.0000    4.0000    3.1623
%     7.0000    1.0000         0
%     8.0000    7.0000    9.4340
%    11.0000   11.0000         0
%    13.0000   10.0000    4.0000
%    20.0000   23.0000    5.0990
%    24.0000   29.0000   10.0000
%    25.0000   30.0000    7.0711
%    26.0000   29.0000    8.0623
%    30.0000   23.0000   14.0357
%    31.0000   23.0000   12.2066
%    35.0000   26.0000   10.6301
%    36.0000   20.0000   14.1421
%    37.0000   30.0000    9.8489
%    39.0000    6.0000    9.2195
%
% - the two spike trains from the checkerboard stimulus
%load data
cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/29Jul2014/Matlab

expName = get_dir_date;
def = dirdefs();

Rall = load('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/29Jul2014_resultsForIan');
Rwn = load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', sprintf('%s_resultsForIan.mat', expName)))

for matchListRow=1:7
    dirName = sprintf('../Figs/spikesortingProblem/%d', matchListRow);
    mkdir(dirName)
    
    allIdx = matchList(matchListRow ,1); wnIdx = matchList(matchListRow ,2);
    ex1.all = [];ex1.wn = [];
    
    %clus no
    ex1.all.clusNo = all.profData{allIdx}.clusNum;
    ex1.wn.clusNo = wn.profData{wnIdx}.clusNum;
    
    %st
    idx = find(Rall.R{1,1}(:,1)==ex1.all.clusNo);
    ex1.all.st = Rall.R{1,1}(idx,2)';
    idx = find(Rwn.R{1,1}(:,1)==ex1.wn.clusNo);
    ex1.wn.st = Rwn.R{1,1}(idx,2)';
    figure, hold on
    plot(ex1.all.st), hold on, plot(ex1.wn.st,'r')
    legend({'all', 'wn'})
    title(sprintf('all clus#%d and wn clus#%d', ex1.all.clusNo,  ex1.wn.clusNo));
    %save
    fileName = 'Spiketrains';
    save.save_plot_to_file(dirName, fileName, 'fig')
    
    % - the two receptive fields
    figure, subplot(1,2,1)
    imagesc(all.profData{allIdx}.staImAdj)
    title(sprintf('all clus#%d', ex1.all.clusNo));
    subplot(1,2,2)
    imagesc(wn.profData{wnIdx}.staImAdj)
    title(sprintf('wn clus#%d', ex1.wn.clusNo));
    fileName = 'RFs';
    save.save_plot_to_file(dirName, fileName, 'fig')
    
    % - footprints
    flist={};flist{end+1} = '../proc/Trace_id1584_2014-07-29T12_02_01_5.stream.ntk';
    mea1 = load_h5_data(flist);
    
    plot.plot_footprint_from_h5data(mea1, ex1.all.st(1:300))
    fileName = 'FP_all';
    save.save_plot_to_file(dirName, fileName, 'fig')
    
    plot.plot_footprint_from_h5data(mea1, ex1.wn.st(1:300))
    fileName = 'FP_wn';
    save.save_plot_to_file(dirName, fileName, 'fig')
    
    % [data] = extract_waveforms_from_h5(mea1,  spikeTimesSamples);
    % - maybe 300 cut spikes from both conditions, plotted on top of each other, ...
    % maybe only for the best 10 electrodes
    
    ex1.all.data = extract_waveforms_from_h5(mea1,  ex1.all.st(1:300));
    amps = max(ex1.all.data.average,[],2)'-min(ex1.all.data.average,[],2)';
    [junk,bestChIdx] = sort(amps,'descend'); bestChIdx=bestChIdx(1:10);
    
    figure, hold on
    offset = [0:300:3000];
    for j=1:10
        wfMat = squeeze(ex1.all.data.waveform(:,bestChIdx(j),:))';
        wfCat = reshape(wfMat,1,size(wfMat,1)*size(wfMat,2));
        plot(wfCat+offset(j))
    end
    
    
    ex1.wn.data = extract_waveforms_from_h5(mea1,  ex1.wn.st(1:300));
    amps = max(ex1.wn.data.average,[],2)'-min(ex1.wn.data.average,[],2)';
    [junk,bestChIdx] = sort(amps,'descend'); bestChIdx=bestChIdx(1:10);
    for j=1:10
        wfMat = squeeze(ex1.wn.data.waveform(:,bestChIdx(j),:))';
        wfCat = reshape(wfMat,1,size(wfMat,1)*size(wfMat,2));
        plot(wfCat+150+offset(j),'r')
    end
    legend({'all', 'wn'});
    
    fileName = 'Concat_spikes';
    save.save_plot_to_file(dirName, fileName, 'fig')
    close all
    
end

%% Compare spiketrains

expName = get_dir_date;
def = dirdefs();

Rall = load('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/29Jul2014_resultsForIan');
Rwn = load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', sprintf('%s_resultsForIan.mat', expName)))

flist={};flist{end+1} = '../proc/Trace_id1584_2014-07-29T12_02_01_5.stream.ntk';
mea1 = load_h5_data(flist);

% use alignGDFs program
gdf1 = Rall.R{1,1};
gdf2 = Rwn.R{1};

%% Do analysis of spiketrains and produce comparison table
% max spiketime
timeLim = 2e4*60*2; % minutes

% apply max
I = find(gdf1(:,2)>timeLim,1,'first')-1;
gdf1cat = gdf1(1:I,:);
I = find(gdf2(:,2)>timeLim,1,'first')-1;
gdf2cat = gdf2(1:I,:);

Rcomparison = mysort.spiketrain.alignGDFs(gdf1cat, gdf2cat, 10, 10, 10);
mysort.plot.printEvaluationTable(R,'ignoreEmptySorted', 0)

%% Create comparison matrix

[comparisonMat clusNos1 clusNos2 ] = spiketrain_analysis.compare_gdf_spiketrain_groups(gdf1cat, gdf2cat, 0)
comparisonThresh = 0.8;
[rows,cols,vals] = find(comparisonMat>comparisonThresh);

figure, imagesc(comparisonMat)



%% Felix's recommendations

% Hi Ian,
%
% so here is what I would look at first to get a quick overview of what
% happens between the two sortings. In particular, how do we best match
% two sets of neurons from different sortings?
%
% I modified the scripts around
% mysort.spiketrain.align
%
% a bit, so you will have to update the svn. There is now also
% some commentary in the functions that explains their usage.
%
%
% Have a look at
% mysort.spiketrain.alignGDFsTest
%
% You see at the very end the matrix
% R.similarityBeforeAssignmentSt1St2
%
% This is the matrix you could look at. It gives you all pairwise comparisons
% of spike trains, ignoring all the other spike trains. The numbers tell
% you how many spikes in these two spike trains are identical.
%
% On the other hand the matrix
% R.similaritySt1St2
% gives you all pairwise comparisons, INCLUDING the matching of the
% other spike trains. The numbers tell you how many spikes in these
% two spike trains are identical, IGNORING all spikes that were already
% assigned to other spike trains.
%
%
% So you could just look at R.similarityBeforeAssignmentSt1St2 and see
% which neuron is similar to which other neuron. Because of overlapping
% spikes, there will be some noise in this matrix.
%
% You can also look at
% R.similarityBeforeAssignmentSt1St2_normalized
%
% which is normalized with the number of spikes in the respective first
% spike train (St1). So it tells you how many percent of spikes of the
% spike train in St1 are in the respective spike train in St2.
%
%
% Obviously, the order of your sortings matters now. St1 is assumed to
% be the correct spike train. Since you do not know which one is correct
% and which one is not, you might get additional information by calling
% mysort.spiketrain.align
% twice, by inverting St1 and St2.
%
%
% Since you will have many spike trains, using this illustration might help:
%
figure;
imagesc(R.similarityBeforeAssignmentSt1St2_normalized);
hc = colorbar; ylabel(hc, 'Matching Ratio');
xlabel('Sorted Spike Trains');
ylabel('Ground Truth Spike Trains');

comparisonThresh = 0.7;
[rows,cols,vals] = find(R.similarityBeforeAssignmentSt1St2_normalized>comparisonThresh);
size(R.similarityBeforeAssignmentSt1St2_normalized)
matchList = [rows,cols];
size(matchList,1)
length(unique(matchList(:,1)))

%
% Let me know if you have any questions.
%
% Best,
% Felix
%

%%

% function alignGDFsTest()
gdf1 = gdf1cat;
gdf2 = gdf2cat;

R = mysort.spiketrain.alignGDFs(gdf1, gdf2, 10, 10, 10);
mysort.plot.printEvaluationTable(R, 'ignoreEmptySorted', 0);
mysort.plot.alignment(R)

R.similaritySt1St2_normalized
R.similarityBeforeAssignmentSt1St2_normalized

R.similaritySt1St2
R.similarityBeforeAssignmentSt1St2
disp('Note the difference between R.similaritySt1St2 and R.similarityBeforeAssignmentSt1St2 caused by the spike at 1100');
disp('This difference comes from the fact that during the assignment this spike is removed from the comparison of St1_1 to St2_2,');
disp('since this spike is already assigned to a spike in St2_1');

figure;
imagesc(R.similarityBeforeAssignmentSt1St2_normalized);
hc = colorbar; ylabel(hc, 'Matching Ratio');
xlabel('Sorted Spike Trains');
ylabel('Ground Truth Spike Trains');

%% plot footprints

for i=1:length(R.k2f)
    if R.k2f(i)>0
        fprintf('%d) %d | %d\n', i, R.St1IDs(i), R.St2IDs(R.k2f(i)))
    else
        fprintf('%d) %d | n/a \n', i, R.St1IDs(i))
    end
end

% valid matches
idxMatch = find(R.k2f>0);

% get num spikes
numSpikes = R.nSP1;

% filter by low number of spikes
minNumSpikes = 50;
idxSuffSpikes = find(numSpikes>minNumSpikes)

idxKeep = intersect(idxMatch, idxSuffSpikes);

% get match indices
idxClus1 = 1:length(R.k2f);
idxClus2 = R.k2f;

% get STA
numSquaresOnEdge=12;
load white_noise_frames.mat
load('frameno_run_01.mat')
configIdx = 1;

profData1 = [];
profData2 = [];
for iFile = idxKeep
    
    [profData1{iFile}.staFrames profData1{iFile}.staTemporalPlot ...
        profData1{iFile}.plotInfo profData1{iFile}.bestSTAInd h] =...
        ifunc.sta.make_sta( R.St1{idxClus1(iFile)}, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        frameno{configIdx});,'do_print';
    
    [profData2{iFile}.staFrames profData2{iFile}.staTemporalPlot ...
        profData2{iFile}.plotInfo profData2{iFile}.bestSTAInd h] =...
        ifunc.sta.make_sta( R.St2{idxClus2(iFile)}, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        frameno{configIdx});,'do_print';
    
    figure,
    subplot(1,2,1)
    imagesc(profData1{iFile}.staFrames(:,:,profData1{iFile}.bestSTAInd ))
    title(sprintf('Cluster %d', R.St1IDs(idxKeep(iFile))));
    axis square
    
    subplot(1,2,2)
    imagesc(profData2{iFile}.staFrames(:,:,profData2{iFile}.bestSTAInd ))
    title(sprintf('Cluster %d', R.St2IDs(R.k2f(idxKeep(iFile)))));
    axis square
    
    dirNameStaPlot = '../Figs/spikesortingProblem/STA_comparisons';
    fileNameStaPlot = sprintf('sta_clus_%d_vs_clus_%d',  R.St1IDs(idxKeep(iFile)), ...
        R.St2IDs(R.k2f(idxKeep(iFile))));
    save.save_plot_to_file(dirNameStaPlot, fileNameStaPlot, 'fig','no_title');
    close all
end