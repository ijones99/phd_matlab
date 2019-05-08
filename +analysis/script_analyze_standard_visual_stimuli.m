%% get list of neurons found manually (white noise)
runNo = input('run no >> ');
fileName = sprintf('wnCheckBrdPosData_%02d.mat',runNo);
load(fileName);

fileNamesManualSel = {};
for i=1:length(wnCheckBrdPosData)
    fileNamesManualSel{i}=wnCheckBrdPosData{i}.fileName;
end

%% get RFs
[rfFieldManual manualData] = analysis.rf.get_receptive_fields(fileNamesManualSel,...
    runNo);

%% get list of neurons found automatically (white noise)
expName = get_dir_date;
def = dirdefs();
% load configurations: configs(1)
load(fullfile(def.projHamster, 'sorting_in',expName, 'configurations.mat'));
load(fullfile(def.sortingOut, sprintf('%s_resultsForIan.mat', expName)));


configColumn = runNo; configIdx= 1;
[tsMatrixAuto ] = spiketrains.extract_single_neur_spiketrains_from_felix_sorter_results(...
    R, configColumn, configIdx);

% get RF
flistName = sprintf('flist_wn_checkerboard_n_%02d',runNo);
flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');

numSquaresOnEdge = [12 12];
iMaxTimeSTACalcTime = [20];
maxTimeSTACalcTime = 15;


% get frameno info
close all
framenoName = strcat('frameno_', flistFileNameID,'.mat');
if ~exist(fullfile(dirNameFFile,framenoName))
    frameno = get_framenos(flist, 2e4*60*20);
    save(fullfile(dirNameFFile,framenoName),'frameno');
else
    load(fullfile(dirNameFFile,framenoName)); frameInd = single(frameno);
end

load white_noise_frames.mat
edgePix = 12;
white_noise_frames = white_noise_frames(1:edgePix,1:edgePix,:);
%% get RFs
profData = {}
outAuto = {};
for iFile = 1:length(tsMatrixAuto)
    [profData{iFile}.staFrames profData{iFile}.staTemporalPlot profData{iFile}.plotInfo profData{iFile}.bestSTAInd h] =...
        ifunc.sta.make_sta( tsMatrixAuto(iFile).st{1}, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        frameno);
    outAuto{iFile}.clusNum = tsMatrixAuto(iFile).clus_num;
    outAuto{iFile}.staIm = profData{iFile}.staFrames(:,:,profData{iFile}.bestSTAInd);
    outAuto{iFile}.staImAdj = beamer.beamer2array_mat_adjustment(outAuto{iFile}.staIm);
end

%% compare RFs
% rfFieldManual{1}.staIm
% outAuto{1}.staIm

comparisonMat = zeros(length(rfFieldManual), length(outAuto));

for i=1:length(rfFieldManual)
    for j=1: length(outAuto)
        
        comparisonMat(i,j) = corr2(rfFieldManual{i}.staIm, outAuto{j}.staIm);
    end
end


%% compare st
comparisonMatSt = zeros(length(rfFieldManual), length(outAuto));

for i=1:length(manualData)
    for j=1: length(outAuto)
        comparisonMatSt(i,j) = spiketrain_analysis.compare_spiketrains(...
            manualData{i}.stSel, tsMatrixAuto(j).st{1},15)/length(manualData{i}.stSel);
        
    end
end

%% create registry
threshold = 0.9;
[rows,cols,vals] = find(comparisonMat > threshold);
cellMatchReg = {};
for i=1:length(vals)
    cellMatchReg{i,1} = fileNamesManualSel{rows(i)};
    cellMatchReg{i,2} = outAuto{cols(i)}.clusNum;
end
regFileName = sprintf('matching_registry_%s_run_%d',expName, runNo);
save(regFileName, 'cellMatchReg')

%% plot footprint comparison
comparisonMatPlot = comparisonMat;
comparisonMatPlot( find(comparisonMatPlot < threshold)) = 0;
figure('Units','Normalized','Position',[0 0 .6 1]),
imagesc(comparisonMatPlot), axis equal, colorbar
[rows,cols,vals] = find(comparisonMatPlot>0);
if length(unique(rows)) ~= length(rows)
    warning('Reset threshold!')
end
titleName = sprintf('Matching RFs found manually and automatically (%s run %d)',...
    expName, runNo);
title(titleName);

saveToDir = '../Figs/rf_comparison/';
mkdir(saveToDir );
fileName = strrep(titleName,' ','_');
save.save_plot_to_file(saveToDir, fileName, 'eps' );
save.save_plot_to_file(saveToDir, fileName, 'fig' );

%% plot timestamps
% cellMatchReg
% % find cluster idx for auto
% for i=1:length(tsMatrixAuto), if tsMatrixAuto(i).clus_num == 2008, break, end, end
% stAuto = tsMatrixAuto(i).st{1};
%  a = load('../analysed_data/T10_18_39_17_wn_checkerboard_n_01/03_Neuron_Selection/st_5055n28.mat');
%  stManual = a.st_5055n28.ts*2e4;
% figure, plot(stManual), hold on, plot(stAuto,'r')
% length(find(ismember(stAuto,stManual)))

%% Analysis using R output
%% load frameno
runNo = input('Enter run number: >> ');
frameno = framenos.load_framenos_to_cell(runNo);

%% load data
expName = get_dir_date;
def = dirdefs();

Rall = load('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/29Jul2014_resultsForIan');
Rwn = load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', sprintf('%s_resultsForIan.mat', expName)))

%% plot framenos
fileIdx = input('Enter file idx >> ');
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno{fileIdx},interStimTime);
figure, hold on
plot.raster(stimChangeTs/2e4, 'height',50, 'offset', 25)
axis off
%% plot spot sizes
spotsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_spots.mat');
textColor = {'w','k'};
colorOffset = [0 60];
for iCol = 1:2
    for iHt = [102 -2]
        for i=[1:2:60]+colorOffset(iCol)
            text(stimChangeTs(i)/2e4+0.2,iHt, num2str(spotsSettings.dotDiam((i-1)/2+1)),'Color',textColor{iCol});
        end
    end
end


%% plot spikes for clusters
gdfCurr = Rall.R{fileIdx,runNo};
clusNos = unique(gdfCurr(:,1));

for iClus = 1:length(clusNos)
    stIdx = find(gdfCurr(:,1) ==clusNos(iClus));
    stCurr = gdfCurr(stIdx,2);
    stCurrSec = stCurr/2e4;
    plot.raster(stCurrSec,'color','r','offset', iClus, 'height', 0.5)
end

%% plot spiketimes for spots
fileIdx = input('Enter file idx >> ');
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno{fileIdx},interStimTime);
figure, hold on
plot.raster(stimChangeTs/2e4, 'height',50, 'offset', 25,'bold_idx',[1:2:length(stimChangeTs)])
axis off
%spot size labels
spotsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_spots.mat');
textColor = {'w','k'};
colorOffset = [0 60];
for iCol = 1:2
    for iHt = [51 -1]
        for i=[1:2:60]+colorOffset(iCol)
            text(stimChangeTs(i)/2e4+0.2,iHt, num2str(spotsSettings.dotDiam((i-1)/2+1)),'Color',textColor{iCol});
        end
    end
end
% plot rasters
gdfCurr = Rall.R{fileIdx,runNo};
clusNos = unique(gdfCurr(:,1));
for iClus = 1:10
    stIdx = find(gdfCurr(:,1) ==clusNos(iClus));
    stCurr = gdfCurr(stIdx,2);
    stCurrSec = stCurr/2e4;
    plot.raster(stCurrSec,'color','r','offset', iClus, 'height', 0.5)
end
% plot clusNum
for iClus = 1:50
    text(-0.5, iClus,num2str(clusNos(iClus)  ));
    
end




%% plot spikes and time changes

spotsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_spots.mat');
barsSettings = file.load_single_var('~/Matlab/settings/', 'stimFrameInfo_movingBar_2reps.mat');

stimFrameInfo = spotsSettings;
% get switch times



figure, hold on,
plot.raster(neur.spt.st/2e4,'color','b')
plot.raster(stimChangeTs/2e4)


%% Use Felix's spiketrain comparator

expName = get_dir_date;
runNo = 1;

[Rcomp Rout] = spiketrain_analysis.gdf.compare_gdf_spiketrains_for_wn_checkerboard(...
    expName, runNo,'min_spike_num', 40, 'min_common_to_gt_percent', 40 )

[Rout.U1(Rout.idxKeep)' Rout.U2(Rout.idxKeep)']
fprintf('Done.\n')
save R_run_no_01.mat Rcomp Rout
% load frameno & data
framenosToLoad = [1:3];
pathDef = dirdefs();
expName = get_dir_date;

% configNo = input('Enter config no >> ');
configColumn = runNo; configIdx= 1;
doLoadFrameNo = 1;
% load data
load(fullfile(pathDef.dataIn,expName,'configurations'))
load(sprintf('%s%s_resultsForIan',pathDef.sortingOut, expName))
clear frameno
% load framenos
frameNoFileName = sprintf('frameno_run_%02d', runNo);
if ~exist([frameNoFileName,'.mat'],'file')
    frameno = {};
    if ~isfield(configs(runNo), 'flist')
        configs = analysis.visual_stim.add_flist_data_to_configs_file(configs, expName);
    end
    
    frameno = get_framenos(configs(runNo).flist(framenosToLoad));
    
elseif ~exist('frameno','var')
    if doLoadFrameNo
        load(frameNoFileName, 'frameno');
    end
end
save(frameNoFileName, 'frameno')
% get     stimChangeTs = get_stim_start_stop_ts2(frameno{currRIdx},interStimTime);
interStimTime=0.5;
for i=4:length(configs(runNo).flist)
    currFrameno = get_framenos(configs(runNo).flist{i});
    stimChangeTs{i} = get_stim_start_stop_ts2(currFrameno{1},interStimTime);
end

save stimChangeTsAll stimChangeTs

%%
def = dirdefs();

expName = get_dir_date;
Rall = load(sprintf('/net/bs-filesvr01/export/group/hierlemann/Temp/FelixFranke/IanSortingOut/%s_resultsForIan',expName));
Rwn = load(fullfile(def.sortingOut, 'wn_checkerboard_during_exp', sprintf('%s_resultsForIan.mat', expName)));


%% plot RFs for matched timestamps
promptInspect=0;
doSavePlot=1;
numSquaresOnEdge=12;
load white_noise_frames.mat
% load('frameno_run_01.mat')
configIdx = 1;
profData1 = {};
for iFile = 1:length(Rout.idxKeep)
    
    % wn
    st1Idx = find(Rwn.R{1}(:,1)==Rout.U1(Rout.idxKeep(iFile)));
    st1 = Rwn.R{1}(st1Idx,2);
    st2Idx = find(Rall.R{1}(:,1)==Rout.U2(Rout.idxKeep(iFile)));
    st2 = Rall.R{1}(st2Idx,2);
    
    if iscell(frameno)
        currFrameno = frameno{1};
    else
        currFrameno = frameno;
    end
    
    [profData1{iFile}.staFrames profData1{iFile}.staTemporalPlot ...
        profData1{iFile}.plotInfo profData1{iFile}.bestSTAInd h] =...
        ifunc.sta.make_sta( st1, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        currFrameno);,'do_print';
    
    [profData2{iFile}.staFrames profData2{iFile}.staTemporalPlot ...
        profData2{iFile}.plotInfo profData2{iFile}.bestSTAInd h] =...
        ifunc.sta.make_sta( st2, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        currFrameno);'do_print';
    
    figure,
    subplot(1,2,1)
    imagesc(profData1{iFile}.staFrames(:,:,profData1{iFile}.bestSTAInd ))
    title(sprintf('Cluster %d', Rcomp.St1IDs(Rout.idxKeep(iFile))));
    axis square
    
    subplot(1,2,2)
    imagesc(profData2{iFile}.staFrames(:,:,profData2{iFile}.bestSTAInd ))
    title(sprintf('Cluster %d', Rcomp.St2IDs(Rcomp.k2f(Rout.idxKeep(iFile)))));
    axis square
    
    lTs1 = length(st1);lTs2 = length(st2); lCommon= length(find(ismember(st1,st2)));
    suptitle(sprintf('ts1: %d spikes | ts2: %d spikes | common: %d spikes\n', lTs1, lTs2,lCommon));
    
    if promptInspect
        a = input('enter')
    end
    if doSavePlot
        dirNameStaPlot = '../Figs/STA_comparisons';
        mkdir(dirNameStaPlot)
        fileNameStaPlot = sprintf('wn_clus_%d_vs_clus_%d',  Rout.U1(Rout.idxKeep(iFile)), ...
            Rout.U2(Rout.idxKeep(iFile)));
        save.save_plot_to_file(dirNameStaPlot, fileNameStaPlot, 'fig','no_title');
        fileNameStaPlot = sprintf('all_clus_%d_vs_clus_%d',  Rout.U2(Rout.idxKeep(iFile)), ...
            Rout.U2(Rout.idxKeep(iFile)));
        save.save_plot_to_file(dirNameStaPlot, fileNameStaPlot, 'fig','no_title');
    end
    close all
end

%% Plot all STAs
h=figure, hold on, set(h,'Position', [ 679          52        1179         993]);
numRowsCols = ceil(sqrt(length(profData1)));
for iSTA = 1:length(profData1)
    subplot(numRowsCols, numRowsCols, iSTA)
    imagesc(beamer.beamer2array_mat_adjustment(...
        profData1{iSTA}.staFrames(:,:,profData1{iSTA}.bestSTAInd )));
    axis square, axis off
    title(sprintf('clus %d', Rout.U1(Rout.idxKeep(iSTA))))
end
dirNameStaPlot = '../Figs';
fileNameStaPlot = 'STA_wn_overview';
suptitle([strrep(fileNameStaPlot,'_',' '), '(image adjusted for scope proj)'])
save.save_plot_to_file(dirNameStaPlot, fileNameStaPlot, 'fig','no_title');

h=figure, hold on, set(h,'Position', [ 679          52        1179         993]);
numRowsCols = ceil(sqrt(length(profData2)));
for iSTA = 1:length(profData2)
    subplot(numRowsCols, numRowsCols, iSTA)
    imagesc(beamer.beamer2array_mat_adjustment(...
        profData2{iSTA}.staFrames(:,:,profData2{iSTA}.bestSTAInd )));
    axis square, axis off
    title(sprintf('clus %d', Rout.U2(Rout.idxKeep(iSTA))))
end
dirNameStaPlot = '../Figs';
fileNameStaPlot = 'STA_all_overview';
suptitle([strrep(fileNameStaPlot,'_',' '), '(image adjusted for scope proj)']);
save.save_plot_to_file(dirNameStaPlot, fileNameStaPlot, 'fig','no_title');

%% Create Matchlist
runNo =1;
configIdx = 1;
matchList=[];
matchList.headings = {'config_idx', 'U1', 'U2', 'R_idx'}
U1 = Rout.U1(Rout.idxKeep)';
U2 = Rout.U2(Rout.idxKeep)';
matchList.data = [ones(size(U1,1),1), U1, U2]
save(sprintf('matchList_run_%02d', runNo), 'matchList');

%% Plot raster series for marching square
fileIdx =2;
clusNos = matchList.data(:,3);
% frameno
load settings/stimFrameInfo_marchingSqr.mat
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(frameno{fileIdx},interStimTime);
stimChangeTsON = stimChangeTs(1:2:end);

%figure setup
h= figure;
figDims = [51          81        1810         987];
figs.set_size_fig(h, figDims)   ;

% line separation setup
numReps=10;
lineIntSeparation = 320/2/numReps;
lineXMat = repmat([0 4]',1,lineIntSeparation+1);
lineYMat = repmat([0.5:10:16*numReps+1],2,1);


% plot
numClus = size(matchList.data,1);
for i=1:numClus
    clf
    subplot(1,2,1);
    
    hold on
    line(lineXMat,lineYMat,'Color','b');%plot separation lines
    
    
    %     get spiketimes
    stCurr = spiketrains.extract_st_from_R(Rall.R{fileIdx, configIdx}, clusNos(i));
    
    idxRasterSeries = [[1:320]' [2:320+1]'];
    idxResortRasterSeries = repmat([1:16:320/2]',16,1)+reshape(repmat([0:15],10,1),16*10,1);
    
    for iTxt = 1:16
        textVal{iTxt} = num2str(stimFrameInfo.pos(iTxt,2));
    end
    
    text(lineXMat(1,1:end-1)-.5,lineYMat(1,1:end-1)+5,textVal);
    plot.raster_series(stCurr/2e4,stimChangeTsON/2e4, idxRasterSeries(idxResortRasterSeries,:));
    
    title(sprintf('Marching Square; clus wn %d | clus all %d', matchList.data(i,2),matchList.data(i,3)));
    xlim([0 4]);
    xlabel('Time (secs)')
    ylabel('Position');
    
    % ORTHOGONAL MOTION
    subplot(1,2,2);
    
    hold on
    line(lineXMat,lineYMat,'Color','b');%plot separation lines
    text(lineXMat(1,1:end-1)-0.5,lineYMat(1,1:end-1)+5,textVal);
    
    %     get spiketimes
    stCurr = spiketrains.extract_st_from_R(Rall.R{fileIdx, configIdx}, clusNos(i));
    
    idxRasterSeries = [[1:320]' [2:320+1]'];
    idxResortRasterSeries = repmat([1:16:320/2]',16,1)+reshape(repmat([0:15],10,1),16*10,1)+160;
    
    plot.raster_series(stCurr/2e4,stimChangeTsON/2e4, idxRasterSeries(idxResortRasterSeries,:));
    
    title(sprintf('Marching Square; clus wn %d | clus all %d', matchList.data(i,2),matchList.data(i,3)));
    xlim([0 4]);
    xlabel('Time (secs)')
    ylabel('Position');
    
    
    
    %     a = input('enter >>')
    dirName = '../Figs/Marching_Square/'; mkdir(dirName);
    fileName = sprintf('marching_sqr_wn_%d',matchList.data(i,2)) ;
    save.save_plot_to_file(dirName, fileName, 'fig','no_title');
    fileName = sprintf('marching_sqr_all_%d',matchList.data(i,3)) ;
    
    save.save_plot_to_file(dirName, fileName, 'fig','no_title');
    %
end

%% Plot raster series for spots
% load configs
load(sprintf('/home/ijones/ln/sorting_in/%s/configurations.mat', expName))

% configs(1).flist has list of all flists the correspond to R sortings

rFlist = configs(configIdx).flist;

recClusNums = wn.selClusterNums';
clusToFlist = num2cell(recClusNums);
clusToFlist(1:length(configs(configIdx).flist),2) = configs(configIdx).flist';
open clusToFlist % to review & edit
a= input('save clusToFlist?')
save clusToFlist clusToFlist

rIdx = find(ismember(rFlist,clusToFlist(:,2)));

clusToRIdx.headers = {'wn', 'R_idx', 'all'};
clusToRIdx.data = [recClusNums rIdx'];

for i=1:length(matchList.data(:,2))
    % find the cluster that corresponds to the R idx and put in match list
    clusIdx = find( clusToRIdx.data(:,1)==matchList.data(i,2));
    if not(isempty(clusIdx))
        matchList.data(i,4) = clusToRIdx.data(clusIdx,2);
    end
    
end
matchList.headings{4} = 'R_idx';

load stimChangeTsAll;

idxValidR = find(matchList.data(:,4)>0);
%% plot spots
doSavePlot = 0;
doPromptInspect =1;
for i=1:length(idxValidR)
    
    currClusNo = matchList.data(idxValidR(i),3);
    currRIdx = matchList.data(idxValidR(i),4);
    stCurr = spiketrains.extract_st_from_R(Rall.R{currRIdx, configIdx}, currClusNo);
    
    plot.vis_stim.plot_spots_response(stCurr, stimChangeTs{currRIdx});
    suptitle(sprintf('wn %d | all %d', matchList.data(idxValidR(i),2),matchList.data(idxValidR(i),3)));
    if doPromptInspect
        a = input('enter >>')
    end
    if doSavePlot
        dirName = '../Figs/Spots/'; mkdir(dirName);
        fileName = sprintf('spots_wn_%d',matchList.data(idxValidR(i),2)) ;
        save.save_plot_to_file(dirName, fileName, 'fig','no_title');
        fileName = sprintf('spots_all_%d',matchList.data(idxValidR(i),3)) ;
        
        save.save_plot_to_file(dirName, fileName, 'fig','no_title');
    end
    close all
end

%% plot spots with moving grating
for i=1:length(idxValidR)
    currClusNo = matchList.data(idxValidR(i),3);
    currRIdx =1+ matchList.data(idxValidR(i),4);
    try
        stCurr = spiketrains.extract_st_from_R(Rall.R{currRIdx, configIdx}, currClusNo);
        
        plot.vis_stim.plot_spots_response(stCurr, stimChangeTs{currRIdx});
        suptitle(sprintf('wn %d | all %d + grating in surround', matchList.data(idxValidR(i),2),matchList.data(idxValidR(i),3)));
        %     a = input('enter >>')
        dirName = '../Figs/SpotsMovingGrating/'; mkdir(dirName);
        fileName = sprintf('spots_grating_wn_%d',matchList.data(idxValidR(i),2)) ;
        save.save_plot_to_file(dirName, fileName, 'fig','no_title');
        fileName = sprintf('spots_grating_all_%d',matchList.data(idxValidR(i),3)) ;
        
        save.save_plot_to_file(dirName, fileName, 'fig','no_title');
    catch
        fprintf('error')
    end
    close all
end

%% plot locations of centers

rasterColor = {'r','k'};

for iClusNo = 1:length(refClusInfo.clus_no)%$wn.selClusterNums(1:end) % go through all clusters
    try
        close all
        h2=figure, hold on
        figs.set_size_fig(h2,[75   472   639   529]);
        plot.locations_with_labels(wn.rfCenterCoords, num2str(wn.selClusterNums'));
        
        xLine = [-450 0  ; 450  0   ];
        yLine = [0    -450  ; 0 450];
        
        line(xLine, yLine,'Color','r')
        grid on
        
        % plot all cluster responses to one spot
        configIdx=1;
        load settings/stimFrameInfo_spots.mat
        
        
        
        %         matchListIdx = find(matchList.data(:,2)==specClusNo);
        %         currRIdx = matchList.data(matchListIdx,4); % R idx for all clusters
        currRIdx = refClusInfo.R_idx(iClusNo);
        
        % stim changes
        currStimChangeTs = stimChangeTs{currRIdx};
        currStimChangeTsStim = currStimChangeTs(1:2:end);
        
        allDiams = unique(stimFrameInfo.dotDiam);
        
        for currDiam=allDiams
            
            
            % figure
            h=figure, hold on
            figs.set_size_fig(h,[  641          27        1230         987]);
            subPCnt = 1;
            for currRgb=[255 0]
                if currRgb==0
                    diamIdx = find(stimFrameInfo.dotDiam==currDiam & stimFrameInfo.rgb == 0);
                else
                    diamIdx = find(stimFrameInfo.dotDiam==currDiam & stimFrameInfo.rgb> 0);
                end
                
                idxRaster = [diamIdx' diamIdx'+1];
                subplot(1,2,subPCnt);
                xlim([0 4])
                
                for i=1:length(refClusInfo.clus_no)
                    %                     currClusNo = matchList.data(idxValidR(i),3); %clus no within loop
                    %                     currClusNoWn = matchList.data(idxValidR(i),2);
                    currClusNo = refClusInfo.clus_no(i);
                    stCurr = spiketrains.extract_st_from_R(Rall.R{currRIdx, configIdx}, currClusNo);
                    offSet = (i-1)*5;
                    plot.raster_series(stCurr/2e4, currStimChangeTsStim/2e4, idxRaster,'offset',offSet,'color',rasterColor{subPCnt});
                    line([0 4], repmat([offSet-0.5],1,2),'Color','b');
                    text(2,offSet+2.5,num2str(currClusNo))
                end
                offSet = (i)*5;
                line([0 4], repmat([offSet-0.5],1,2),'Color','b');
                ylim([-0.5 offSet-0.5])
                titleName = {'ON', 'OFF'};
                
                title(sprintf('Stim %s: Clus # %d, Diameter %d', titleName{subPCnt}, refClusInfo.clus_no(iClusNo), currDiam));
                subPCnt = subPCnt+1;
            end
        end
    catch
        fprintf('error');
    end
    
    a=input('enter >> ');
end

%% plot spots
rasterColor = {'r','k'};

for iClusNo = 1%:length(refClusInfo.clus_no)%$wn.selClusterNums(1:end) % go through all clusters
    try
        % plot all cluster responses to one spot
        configIdx=1;
        load settings/stimFrameInfo_spots.mat
        
        currRIdx = refClusInfo.R_idx(iClusNo);
        
        % stim changes
        currStimChangeTs = stimChangeTs{currRIdx};
        currStimChangeTsStim = currStimChangeTs(1:2:end);
        
        allDiams = unique(stimFrameInfo.dotDiam);
        subPCnt = 1;
        
        % figure
        h=figure, hold on
        figs.set_size_fig(h,[  641          27        1230         987]);
        rasterSpacing=5;
        for iCurrDiam=1:length(allDiams)
            
            
            for currRgb=[255 0]
                if currRgb==0
                    diamIdx = find(stimFrameInfo.dotDiam==allDiams(iCurrDiam) & stimFrameInfo.rgb == 0);
                    plotColor=2;
                else
                    diamIdx = find(stimFrameInfo.dotDiam==allDiams(iCurrDiam) & stimFrameInfo.rgb> 0);
                    plotColor=1;
                end
                
                idxRaster = [diamIdx' diamIdx'+1];
                subplot(length(allDiams),2,subPCnt);
                xlim([0 4])
                
                
                currClusNo = refClusInfo.clus_no(iClusNo);
                stCurr = spiketrains.extract_st_from_R(Rall.R{currRIdx, configIdx}, currClusNo);
                offSet = rasterSpacing;
                plot.raster_series(stCurr/2e4, currStimChangeTsStim/2e4, idxRaster,'offset',offSet,'color',rasterColor{plotColor});
                titleName = {'ON', 'OFF'};
                
                title(sprintf('Stim %s: Clus # %d, Diameter %d', titleName{plotColor}, refClusInfo.clus_no(iClusNo), allDiams(iCurrDiam)));
                subPCnt = subPCnt+1;
            end
        end
    catch
        fprintf('error');
    end
    
    a=input('enter >> ');
    close all
end

%% plot flashes
rasterColor = {'r','k'};

rVals = [1 3 5 14];
% fileInfo = dir('../proc/*ntk');
% fileTimes = [1040; 1116; 1208; 1357];

allClus = unique(Rall.R{2}(:,1));
allClus = wn.selClusterNums;
for iClusNo = 1:length(allClus)%$wn.selClusterNums(1:end) % go through all clusters
%     for iClusNo = 1:length(refClusInfo.clus_no)%$wn.selClusterNums(1:end) % go through all clusters
    % figure
    h=figure, hold on
    figs.set_size_fig(h,[  641          27        1230         987]);
    
    try
        for iR = 1:length(rVals)
            % plot all cluster responses to one spot
            runNo=1;
            
            currRIdx = rVals(iR)%refClusInfo.R_idx(iClusNo);
            subplot(length(rVals),1,iR)
            % stim changes
            currStimChangeTs = stimChangeTs{currRIdx};
            
            
            rasterSpacing=1;
            
            onIdx = 1:2:length(currStimChangeTs);
            idxRaster = [onIdx' onIdx'+2];
            
            xlim([0 4])
            ylim([-1 10])
            
            currClusNo = allClus(iClusNo);%   refClusInfo.clus_no(iClusNo);
            stCurr = spiketrains.extract_st_from_R(Rall.R{currRIdx, runNo}, currClusNo);
            plot.raster_series(stCurr/2e4, currStimChangeTs/2e4, idxRaster, 'color','r');
            %         titleName = {'ON', 'OFF'};
            title(sprintf('Full-Field Flashing: Clus # %d, R# %d', allClus(iClusNo), currRIdx));            
%             title(sprintf('Full-Field Flashing: Clus # %d, R# %d, File time: %d', refClusInfo.clus_no(iClusNo), currRIdx,fileTimes(iR)));
            %         subPCnt = subPCnt+1;
        end
    catch
        fprintf('error');
    end
    
%         a=input('enter >> ');
        saveToDir = '../Figs/Preparation_Rundown_Testing/', mkdir(saveToDir);
        fileName = sprintf('ffFlash%d', allClus(iClusNo));
        save.save_plot_to_file(saveToDir, fileName, 'fig'  )
        pause(0.1)
        close all
end

