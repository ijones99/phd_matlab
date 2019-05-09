
%% format indices matrix
paraOutputMat = [];
paraOutputMat.params = [];

dirNames = projects.vis_stim_char.analysis.load_dir_names;
% marching sqr over grid
b = file.load_single_var(dirNames.common.params, 'param_March_Sqr_Over_Grid.mat');
idxColParamMat = 1;
idxInvalid = b.invalid;
paraOutputMat.params(:,idxColParamMat) = mats.set_orientation( b.dir_num,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) = mats.set_orientation( b.clus_num,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) = mats.set_orientation( b.index_total_cnt,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) =  mats.set_orientation( b.latency,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) =  mats.set_orientation( b.transience,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) =  normalize_values( mats.set_orientation( b.RF_area_um_sqr,'col'),[0 1]); idxColParamMat = idxColParamMat + 1;

% moving bar DS
b = file.load_single_var(dirNames.common.params, 'param_Moving_Bars_DS.mat');
paraOutputMat.params(:,idxColParamMat) = ...
    mats.set_orientation(b.ds_fr_slow_on, 'col');
idxColParamMat = idxColParamMat + 1;

b = file.load_single_var(dirNames.common.params, 'param_Speed_Test.mat');
paraOutputMat.params(:,idxColParamMat) = ...
    mats.set_orientation(b.index, 'col');
idxColParamMat = idxColParamMat + 1;

b = file.load_single_var(dirNames.common.params, 'param_Length_Test.mat');
paraOutputMat.params(:,idxColParamMat) = ...
    mats.set_orientation(b.index, 'col');
idxColParamMat = idxColParamMat + 1;

%% get normalized spike counts for each ds cell
dataOutAll = {};
nrmSpkCntAll = [];

for iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load ../analysed_data/moving_bar_ds/dataOut.mat;
    nrmSpkCntAll = [nrmSpkCntAll  dataOut.mean_norm_spk_cnt_pref_angle];
end

%% remove nan and zero values
[r c i]= find(isnan(paraOutputMat.params(:,:)))
rowIdxRem = unique([r' find(nrmSpkCntAll<0.35)]);%idxInvalid

rowIdxSave = find(~ismember(1:size(paraOutputMat.params,1),rowIdxRem));

% paraOutputMat.neur_names = paraOutputMat.neur_names(rowIdxSave);
paraOutputMat.params = paraOutputMat.params(unique(rowIdxSave),:);

headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}

%% plot histograms of parameters
dirNames = projects.vis_stim_char.analysis.load_dir_names;
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}

idxCol = [3:9];
histData = {};
histX = {};
for j=1:length(idxCol)
    figure, hold on
    hist(paraOutputMat.params(:,idxCol(j)),30);
    [histData{j} histX{j}] = hist(paraOutputMat.params(:,idxCol(j)),30);
    title(headingNames{idxCol(j)});
    xlabel('Index (normalized)');
    ylabel('Cell Count');
%     figs.format_hist_for_pub('journal_name',  'frontiers');
%     figs.format_for_pub('journal_name',  'frontiers');
%     figs.save_for_pub({dirNames.common.figs, strrep(headingNames{idxCol(j)},' ','-')});
 
end

%% plot parameters against each other
idxCol = [3:9];
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
textColor = {'r'  'g' 'b' 'k' 'c' 'm'  'y'}

C = nchoosek(idxCol, 2);
subplotDims = subplots.find_edge_numbers_for_square_subplot(length(C));
h=figure
figs.maximize(h)
for j=1:length(C)
    subplots.subplot_tight(subplotDims(1), subplotDims(2), j,.06);
    plot(paraOutputMat.params(:, C(j,1)),paraOutputMat.params(:, C(j,2)),'.');
    axis square
%     title(sprintf('%s vs %s',  headingNames{C(j,2)}, ...
%         headingNames{C(j,1)}));
    
    xlabel(headingNames{C(j,1)},'Color', textColor{C(j,1)-2});
    ylabel(headingNames{C(j,2)},'Color', textColor{C(j,2)-2});

end

%% plot parameters against each other with color-coded split
idxCol = [3:9];
% textColor = {'r'  'g' 'b' 'k' 'c' 'm'  'y'}
colorMats = graphics.distinguishable_colors(10,[1 1 1]);

headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
threshVal = 0.5;
C = nchoosek(idxCol, 2);
subplotDims = subplots.find_edge_numbers_for_square_subplot(length(C));
idxParamOfInterest = 7;

idxOverThresh = find(paraOutputMat.params(:,idxParamOfInterest) > threshVal );
idxRest = find(paraOutputMat.params(:,idxParamOfInterest) <= threshVal );

h=figure
figs.maximize(h)
for j=1:length(C)
    subplots.subplot_tight(subplotDims(1), subplotDims(2), j,.04); hold on
    markerSize = 5;
    mainPop = [paraOutputMat.params(idxRest, C(j,1)),paraOutputMat.params(idxRest, C(j,2))];
    overThreshPop = [paraOutputMat.params(idxOverThresh, C(j,1)),paraOutputMat.params(idxOverThresh, C(j,2))];
    
    %     mainPop = mats.add_noise_to_mat(mainPop,[-1 1]*.001);
    %     overThreshPop = mats.add_noise_to_mat(overThreshPop,[-1 1]*.001);
    
    
    plot(mainPop(:,1),mainPop(:,2),'xr','MarkerSize',markerSize );
    plot(overThreshPop(:,1), overThreshPop(:,2),'ko','MarkerSize',markerSize );
    axis tight, axis square
    %     title(sprintf('%s vs %s',  headingNames{C(j,2)}, ...
    %         headingNames{C(j,1)}));
    
    xlabel(headingNames{C(j,1)},'Color', colorMats(C(j,1)-2,:));
    ylabel(headingNames{C(j,2)},'Color', colorMats(C(j,2)-2,:));
    %     xlim([round(minmax(mainPop(:,1)))])
    %     ylim([round(minmax(mainPop(:,2)))])

end

%% cluster all with fuzzy GK
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}

xyLimsOff = 0;
nclass = 12;
data = paraOutputMat.params(:,[3 4 5 7 8 ]);
phi=2;
maxiter=500;
distype=1;
toldif = 1.0000e-07;
scatter =  0.1000;
ntry = 500;
ndata = size(data,1);
choice = input('run fuzzy gk?','s')
nclass = 12;
if strcmp(choice,'y')
    [U, cbest, dist, W, obj] = run_fuzme(nclass,data,phi,maxiter,distype,toldif,scatter,ntry);
    %
    %     Uinit= initmember(0.1,nclass,ndata);
    %     [U, centroid, dist, W, F, obj] = gk_fkm(nclass,data,Uinit,phi,maxiter,toldif)
end
[Y,idxAssigns] = max(U,[],2);

paramClustering = {};
% paraClustering.neur_names = paraOutputMat.neur_names;
paraClustering.clusterAssigns = idxAssigns;

%% cluster with k-means
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
idxAssigns = {};
idxCol = [3 4 5 7 8 ];
data = paraOutputMat.params(:,idxCol );
cpu.open_matlabpool(8)
parfor k=4:19
    idxAssigns{k} = kmeans(data,k,'Distance','cityblock','Replicates', 5000);
    k
end
loadSave = input('Load or save: (l/s)','s');
if loadSave == 's'
    save ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns.mat idxAssigns
elseif loadSave == 'l'
    load ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns.mat idxAssigns
end

%% cluster with k-means 30,000 reps
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
idxAssigns = {};
idxCol = [3 4 5 7 8 ];
data = paraOutputMat.params(:,idxCol );
cpu.open_matlabpool(8)
parfor k=4:25
    tic
    idxAssigns{k} = kmeans(data,k,'Distance','cityblock','Replicates', 30000,'display','final');
    toc
    k
    progress_info(k,25,'30,000 reps, same params as before')
end
save ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns_30000reps.mat idxAssigns
printf('done with 30,000 same params as before\n')

% cluster with k-means 30,000 reps and orig area
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
idxAssigns = {};
idxCol = [3 4 5 6 7 8 ];
data = paraOutputMat.params(:,idxCol );

parfor k=4:25
    idxAssigns{k} = kmeans(data,k,'Distance','cityblock','Replicates', 30000);
    k
    progress_info(k,25,'30,000 reps, plus orig area')
end
save ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns_30000reps_orig_area.mat idxAssigns
printf('done with 30,000 plus orig area\n')

%cluster with k-means 30,000 reps and 7 params
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
idxAssigns = {};
idxCol = [3 4 5 6 7 8 9];
data = paraOutputMat.params(:,idxCol );

parfor k=4:25
    idxAssigns{k} = kmeans(data,k,'Distance','cityblock','Replicates', 30000);
    k
    progress_info(k,25,'30,000 reps, 7 params')
end
save ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns_30000reps_7_params.mat idxAssigns
printf('done with 30,000 7 params\n');

% cluster with k-means 30,000 reps new area
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
idxAssigns = {};
idxCol = [3 4 5 7 8 ];
data = [paraOutputMat.params(:,idxCol ) rfDiam'] ;

parfor k=4:25
    idxAssigns{k} = kmeans(data,k,'Distance','cityblock','Replicates', 30000);
    k
    progress_info(k,25,'30,000 reps, same params as before with new area')
end
save ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns_30000reps_new_area.mat idxAssigns
printf('done with 30,000 , same params as before with new area \n')


%% cluster with k-means 30,000 reps and orig area
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
idxAssigns = {};
idxCol = [3 4 5 7 8 ];
data = paraOutputMat.params(:,idxCol );
cpu.open_matlabpool(8)
parfor k=4:25
    idxAssigns{k} = kmeans(data,k,'Distance','cityblock','Replicates', 30000);
    k
    progress_info(k,25,'30,000 reps, orig area')
end
save ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns_30000reps_orig_area.mat idxAssigns
printf('done with 30,000 orig area\n')



%% plot silhouette
figure,
silh = {};
for k=4:19
    [silh{k},h] = silhouette(data,idxAssigns{k},'cityblock');
    h = gca;
    h.Children.EdgeColor = [.8 .8 1];
    xlabel 'Silhouette Value';
    ylabel 'Cluster';
    title(num2str(k))
    pause(0.2)
end

meanSilh = cellfun(@mean, silh(4:19));
k=4:19;
figure, plot(k, meanSilh,'o-k')
supTitle = ['Mean Silhouette Value for ', cells.concat_with_spacer(headingNames(idxCol),', ')];
dirNameFig = dirNames.common.figs;
fileNameFig = 'silhouette_values_for_clustering_plot_2';
xlabel('Number Clusters'), xlim(minmax(k)+[-0.5 0.5])
ylabel('Mean Silhouette Value')
title(supTitle)
figs.format_for_pub(   'journal_name','frontiers')
figs.save_for_pub(fullfile(dirNameFig, fileNameFig))

% if input('save? ')
%     save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
%         'font_size_all', 13 , ...
%         'x_label', 'k (cluster number)','y_label', 'Mean Silhouette Value',...
%         'sup_title', supTitle);
% end

silhAnalysis.silh = silh;
silhAnalysis.param_names = headingNames(idxCol) ;
silhAnalysis.data = paraOutputMat.params;
silhAnalysis.idx_col_data = idxCol;
silhAnalysis.idx_assigns = idxAssigns;
silhAnalysis.k = k;
dirName = dirNames.common.clus_params;
fileName = ['silhAnalysis_', cells.concat_with_spacer(headingNames(idxCol),'_'),'.mat']
save(fullfile(dirName, fileName), 'silhAnalysis')


%% get cluster names within groups
paramClusIdx = 3;
paraClustering.neur_names(find(paraClustering.clusterAssigns == paramClusIdx))   

%% plot clustered param datapoints

headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
selK = 7;
plotSymbol = {'>','x','<', '^', 'v', '+', 'o', 'd', '>','x','<', '^', 'v', '+', 'o', 'd','>','x','<', '^', 'v', '+', 'o', 'd'};
idxCol = [3 4 5 7 8 9 ];
C = nchoosek(idxCol, 2);
colorMats = graphics.distinguishable_colors(selK,[1 1 1]);
cMap = distinguishable_colors(11);
cMap = cMap([1:3 5 7:11],:);

subplotDims = subplots.find_edge_numbers_for_square_subplot(length(C));
h=figure
figs.maximize(h)
for j=1:length(C)
    subplots.subplot_tight(subplotDims(1), subplotDims(2), j,.04); hold on
    
    for iParamClus = 1:selK
        currIdxPClus = find(idxAssigns{selK}==iParamClus);
        plot(paraOutputMat.params(currIdxPClus, C(j,1)),...
            paraOutputMat.params(currIdxPClus, C(j,2)),'o',...
            'Color',cMap(iParamClus,:),'MarkerFaceColor', cMap(iParamClus,:));
    end
    
    axis square
    %     title(sprintf('%s vs %s',  headingNames{C(j,2)}, ...
    %         headingNames{C(j,1)}));
    
    xlabel(headingNames{C(j,1)});
    ylabel(headingNames{C(j,2)});

end

legend(num2str([1:8]'))

%% plot cluster means per parameter 

headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
optimalNumClus = 7;
idxParam = [3 4 5 7 8 9 ];%3:9;
colorMats = graphics.distinguishable_colors(optimalNumClus,[1 1 1]);
cMapAll = colorcube;
cMap = cMapAll([15: 3:64],:);
cMap = distinguishable_colors(11);
cMap = cMap([1:3 5 7:11],:);
% sort by bias
iParamClus = 3;
meanVal = [];
subplotDims = subplots.find_edge_numbers_for_square_subplot(optimalNumClus);
for iGp=1:optimalNumClus % loop through groups
    % idx for curr cluster
    
  
    
    currIdxPClus = find(idxAssigns{optimalNumClus}==iGp);
    meanVal(iGp) = mean(paraOutputMat.params(currIdxPClus, iParamClus));
    stdVal(iGp) = std(paraOutputMat.params(currIdxPClus, iParamClus));
end

 [Y orderIncBias] =  sort(meanVal,'ascend');

meanVal = [];
stdVal= [];
h=figure
figs.maximize(h);
iPlot = 1;
for iParamClus = idxParam % loop through parameter
    
    hold on
    subplots.subplot_tight(subplotDims(1), subplotDims(2), iPlot,.04); hold on
    for iGp=1:length(orderIncBias) % loop through groups
        % idx for curr cluster
        currIdxPClus = find(idxAssigns{optimalNumClus}==orderIncBias(iGp));
        meanVal = mean(paraOutputMat.params(currIdxPClus, iParamClus))
        stdVal = std(paraOutputMat.params(currIdxPClus, iParamClus));
        errorbar(iGp, meanVal, stdVal,'Color',cMap(orderIncBias(iGp),:) )
        plot(iGp, meanVal,'s', 'MarkerFaceColor', cMap(orderIncBias(iGp),:),...
            'MarkerEdgeColor','none',  'MarkerSize',15)
    end
    
    origYLim = get(gca,'YLim');
    if origYLim(1) > 0
        ylim([0 origYLim(2)]);
    end
    axis square
    
    title(headingNames{iParamClus})
  
    xlim([0.5 length(orderIncBias)+0.5]);
    
    xlabel('Group Number');
    ylabel('Parameter');
    %figs.format_hist_for_pub('journal_name',  'frontiers');
    %figs.format_for_pub('journal_name',  'frontiers');
    xlim([0.5 length(orderIncBias)+0.5]);
    iPlot = 1+iPlot;
end
fileName = sprintf('cluster_center_values_for_%s', headingNames{iParamClus});
fileName = texts.replace_characters(fileName,{'-_', ' _'});
figs.save_for_pub({dirNames.common.figs, fileName});


%% plot clustered params in separate figs

headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
selK = 7;
plotSymbol = {'>','h','<', '^', 'v', 'p', 'o', 'd'};
C = nchoosek(idxCol, 2);
colorMats = graphics.distinguishable_colors(selK,[1 1 1]);


for j=1:length(C)
    figure; hold on
    
    for iParamClus = 1:selK
        currIdxPClus = find(idxAssigns{selK}==iParamClus);
        plot(paraOutputMat.params(currIdxPClus, C(j,1)),paraOutputMat.params(...
            currIdxPClus, C(j,2)),plotSymbol{iParamClus},...
            'Color',colorMats(iParamClus,:), 'MarkerFaceColor',colorMats(iParamClus,:));
    end
    
    axis square
        
    xlabel(headingNames{C(j,1)});
    ylabel(headingNames{C(j,2)});
    title(sprintf('%s vs %s', headingNames{C(j,2)}, headingNames{C(j,1)}));
    figs.font_size(fontSize); %,'fontWeight','bold'
    figs.format_for_pub(   'journal_name', 'frontiers','plot_dims',[20 20])
    dirName = dirNames.common.figs;
    fileName = strrep(strrep(sprintf('clustered params %s vs %s LARGER _7_clus',...
        headingNames{C(j,2)},headingNames{C(j,1)}),' ','_'),'-','_');
    figs.save_for_pub(fullfile(dirName,fileName))


end

%% plot clustered params in separate figs - no labels

headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
selK = 7;
plotSymbol = {'>','h','<', '^', 'v', 'p', 'o', 'd'};
C = nchoosek(idxCol, 2);
colorMats = graphics.distinguishable_colors(selK,[1 1 1]);

for j=1:length(C)
    figure; hold on
    
    for iParamClus = 1:selK
        currIdxPClus = find(idxAssigns{selK}==iParamClus);
        plot(paraOutputMat.params(currIdxPClus, C(j,1)),paraOutputMat.params(currIdxPClus, C(j,2)),plotSymbol{iParamClus},...
            'Color',colorMats(iParamClus,:), 'MarkerFaceColor',colorMats(iParamClus,:));
    end
    
    axis square
    xlabel(headingNames{C(j,1)});
    ylabel(headingNames{C(j,2)});
  
    figs.ticknum(2,2)
    figs.ticksoff
    figs.format_for_pub(   'journal_name', 'frontiers','plot_dims',[20 20])
    dirName = dirNames.common.figs;
    fileName = strrep(strrep(sprintf('clustered params %s vs %s LARGER', headingNames{C(j,2)},headingNames{C(j,1)}),' ','_'),'-','_');
%     figs.save_for_pub(fullfile(dirName,fileName))
junk = input('enter >>')
end

%% plot all cluster groups to subplots
plotDims = [1 1]*60;
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
selK = 7;
plotSymbol = {'>','h','<', '^', 'v', 'p', 'o', 'd'};
plotSymbol(1:7) = {'o'}
C = nchoosek(idxCol, 2);
colorMats = graphics.distinguishable_colors(selK,[1 1 1]);
h=figure, figs.maximize(h)
for j=1:length(C)
    subplot(3,5,j); hold on
    for iParamClus = 1:selK
        currIdxPClus = find(idxAssigns{selK}==iParamClus);
        plot(paraOutputMat.params(currIdxPClus, C(j,1)),paraOutputMat.params(currIdxPClus, ...
            C(j,2)),plotSymbol{iParamClus},...
            'Color',colorMats(iParamClus,:), 'MarkerFaceColor',colorMats(iParamClus,:));
    end
    xlabel(headingNames{C(j,1)});
    ylabel(headingNames{C(j,2)});
    axis square
    figs.ticknum(2,2)
    figs.ticksoff
        figs.format_for_pub(   'journal_name', 'frontiers','plot_dims',plotDims)
end
legend(num2str([1:selK]'))
figs.format_for_pub(   'journal_name', 'frontiers','plot_dims',plotDims)

dirName = dirNames.common.figs;
fileName = strrep(strrep(sprintf('clustered params %s vs %s LARGER subplots', ...
    headingNames{C(j,2)},headingNames{C(j,1)}),' ','_'),'-','_');
figs.save_for_pub(fullfile(dirName,fileName))

%% plot all clusters

colorMats = graphics.distinguishable_colors(10,[1 1 1]);
doLims = input('set x and y lims? [y/n] >> ','s');
fontSize = 7;
selClusNum = 7;
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
selK = 7;

h=figure, hold on
idxCol = 3:8;
selParams = paraOutputMat.params(:,idxCol);
numParams = size(selParams,2);
for j=1:length(headingNames)
    headingNames{j} = strrep(headingNames{j},'_','-');
end

for i=1:length(C)
    subplot(2,5,i), hold on
    % figure, hold on
    figureHandle = gcf;
    %# make all text in the figure to size 14 and bold
    set(findall(figureHandle,'type','text'),'fontSize',fontSize); %,'fontWeight','bold'
    
    for iClus = 1:size(colorMats,1)  
        I = find(idxAssigns{selClusNum }==iClus);
        plot(selParams(I,C(i,1)),selParams(I,C(i,2)),'*',...
            'LineWidth',3,'Color',colorMats(iClus,:),'MarkerSize',3)
        selParams(I,numParams+1) = iClus;
    end
    
    title(sprintf('%s vs %s', headingNames{C(i,2)},headingNames{C(i,1)}));
    xlabel(upper(headingNames{C(i,1)}));
    ylabel(upper(headingNames{C(i,2)}));
    %     xlim(xLims(i,:));
    if strcmp(doLims,'y')
        set(gca,'XTick',linspace(xLims(i,1),xLims(i,2),2)); xlim([xLims(i,:)])
        ylim(yLims(i,:));
    else
        axis auto
    end
    axis square
    set(gca,'FontSize',fontSize)
    
    set(findall(gcf,'type','text'),'FontSize',fontSize)
    
end
legend(num2str([1:size(colorMats,1)]'))
figs.maximize(h)

suptitle(sprintf('All Params, n = %d, kmeans reps = 30,000', size(selParams,1)))
% save plots
dirNameFig = '~/ln/vis_stim_hamster/plots/params_all';
dateStr = strrep(strrep(datestr(now),' ', '_'),':','_');

% save plots
fileNameFig = sprintf('all_params_and_clusters_no_set_lims');
set(h, 'Position', [100, 100, 1900   , 1065]);
choice = input('Print? [y/n] >> ','s')
if strcmp(choice,'y')
    save.save_plot_to_file(dirNameFig, fileNameFig,{'fig','eps'},'add_filename_datestr');
end
%% plot all clusters in separate figs

colorMats = graphics.distinguishable_colors(10,[1 1 1]);
% doLims = input('set x and y lims? [y/n] >> ','s');
fontSize = 8;
preferredClusNum = 8;
% idxCol = 3:8;
selParams = paraOutputMat.params(:,idxCol);
numParams = size(selParams,2);
for j=1:length(headingNames)
    headingNames{j} = strrep(headingNames{j},'_','-');
end

for i=1%:length(C)
    figure, hold on
    % figure, hold on
    figureHandle = gcf;
    %# make all text in the figure to size 14 and bold
   
    
    for iClus = 1:size(colorMats,1)
        
        I = find(idxAssigns{preferredClusNum}==iClus);
        plot(selParams(I,C(i,1)),selParams(I,C(i,2)),'*',...
            'LineWidth',3,'Color',colorMats(iClus,:),'MarkerSize',3)
        selParams(I,numParams+1) = iClus;
    end
    
    title(sprintf('%s vs %s', headingNames{C(i,2)},headingNames{C(i,1)}));
    xlabel(upper(headingNames{C(i,1)}));
    ylabel(upper(headingNames{C(i,2)}));
    %     xlim(xLims(i,:));
    
    
    axis square
    
    legend(num2str([1:size(colorMats,1)]'))
    figs.font_size(    fontSize); %,'fontWeight','bold'
    figs.format_for_pub(   'journal_name', 'frontiers')
    dirName = dirNames.common.figs;
    fileName = strrep(strrep(sprintf('%s vs %s', headingNames{C(i,2)},headingNames{C(i,1)}),' ','_'),'-','_');
    figs.save_for_pub(fullfile(dirName,fileName))
end


%% plot all together with same color
fontSize = 12;
figure, hold on
for i=1:length(C)
    subplot(5,2,i)
    figureHandle = gcf;
    %# make all text in the figure to size 14 and bold
    set(findall(figureHandle,'type','text'),'fontSize',16); %,'fontWeight','bold'
    plot(paraOutputMat.params(:,C(i,1)),paraOutputMat.params(:,C(i,2)),'o','LineWidth',2);
    title(sprintf('%s vs %s', headingNames{C(i,1)},headingNames{C(i,2)}));
    xlabel(upper(headingNames{C(i,1)}));
    ylabel(upper(headingNames{C(i,2)}));
    xlim(xLims(i,:));
    ylim(yLims(i,:))
    axis square
    set(gca,'FontSize',fontSize)
    
    set(findall(gcf,'type','text'),'FontSize',fontSize)
end

%% plot separate seasons
% get idx for seasons
fontSize = 7;
h2=figure, hold on
season.winter_dates = {'15July2014', '26Jun2014', '29May2014', '24July2014'}
season.autumn_dates = {'29Jul2014', '22May2014', '17Jun2014', '03Jun2014', '30Jul2014_2','08Jul2014' };
headingNames = {'Bias-Index'    'Latency'    'Transience'    'RF-Index'    'DS-Index'}

warning('Plot restricted to defined winter and autumn dates.')
doLims = input('set x and y lims? [y/n] >> ','s');
idx.winter = [];
idx.autumn = [];

for i=1:length(season.winter_dates)
    idx.winter = [idx.winter cells.cell_find_str2(paraOutputMat.neur_names,season.winter_dates{i} ,'partial_match')];
end
for i=1:length(season.autumn_dates)
    idx.autumn = [idx.autumn cells.cell_find_str2(paraOutputMat.neur_names,season.autumn_dates{i} ,'partial_match')];
end
for i=1:length(C)
    subplot(5,2,i), hold on
    figureHandle = gcf;
    % winter and autumn idxs
    
    %# make all text in the figure to size 14 and bold
    set(findall(figureHandle,'type','text'),'fontSize',fontSize); %,'fontWeight','bold'
    % winter
    plot(paraOutputMat.params(idx.winter,C(i,1)),paraOutputMat.params(idx.winter,C(i,2)),'bo','LineWidth',0.5,'MarkerSize',2);
    % autumn
    plot(paraOutputMat.params(idx.autumn,C(i,1)),paraOutputMat.params(idx.autumn,C(i,2)),'ro','LineWidth',0.5,'MarkerSize',2);
    
    
    title(sprintf('%s vs %s', headingNames{C(i,1)},headingNames{C(i,2)}));
    xlabel(upper(headingNames{C(i,1)}));
    ylabel(upper(headingNames{C(i,2)}));
    if strcmp(doLims,'y')
        set(gca,'XTick',linspace(xLims(i,1),xLims(i,2),2)); xlim([xLims(i,:)])
        ylim(yLims(i,:))
    else
        axis auto
    end
    axis square
    set(gca,'FontSize',fontSize)
    
    set(findall(gcf,'type','text'),'FontSize',fontSize)
end

legend({'Winter'; 'Autumn'})

% save plots
dirNameFig = '/home/ijones/Desktop/Work_Report-2014-08/Plots/';
fileNameFig = sprintf('all_params_and_clusters_by_season_no_set_lims');
set(h2, 'Position', [100, 100, 1900   , 1065]);
choice = input('Print? [y/n] >> ','s')
if strcmp(choice,'y')
    save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
    save.save_plot_to_file(dirNameFig, fileNameFig,'eps');
end


%% Plot histograms
% hist(data,nbins)
% figure, hold on
paramNo = 1;
fontSize = 10;
histSegs=20;
yLabel = 'Counts';
xLabel = {'Index' 'Time (sec)' 'Time (sec)' 'Index' 'Index' 'Size (um)' }
headingNames = {'Bias_Index'    'Latency'    'Transience_Index'    'RF_Index'    'DS_Index' 'pref_Spot_Diam'}
xLim = [ -1 1; 0 2; 0 2; 0 1; 0 1; 0 1000];
yLim = [0 25;0 25; 0 25; 0 25; 0 25; 0 25]

h=figure, hold on
numParams = length(headingNames)
for i=1:numParams
    subplot(1,numParams,i)
    spacing = linspace(xLim(i,1),xLim(i,2),histSegs);
    hist(paraOutputMat.params(:,i),spacing,'Color','k')
    axis square
    xlim([xLim(i,1)-diff(spacing(1:2)),xLim(i,2)+diff(spacing(1:2))]);
    title(sprintf('%s', strrep(headingNames{i},'_', ' ')));
    xlabel(xLabel{i}), ylabel(yLabel)
    set(gca,'FontSize',fontSize)
    set(findall(gcf,'type','text'),'FontSize',fontSize)
    fileNameFig = headingNames{i};
    
    set(get(gca,'child'),'FaceColor','k','EdgeColor','k');
    
end
suptitle(sprintf('n = %d', size(paraOutputMat.params,1)))
% save plots
dirNameFig = '~/ln/vis_stim_hamster/plots/params_histogram';
dateStr = strrep(strrep(datestr(now),' ', '_'),':','_');
fileNameFig = sprintf('histogram_of_all_params_%s',dateStr);
set(h, 'Position', [ 5         674        1912         402]);
choice = input('Print? [y/n] >> ','s')
if strcmp(choice,'y')
    save.save_plot_to_file(dirNameFig, fileNameFig,'fig','no_title');
    save.save_plot_to_file(dirNameFig, fileNameFig,'eps','no_title');
end
%% Plot histograms by season
histSegs=20;
fontSize = 10;
h=figure, hold on
season.autumn_dates = {'08Oct2014','09Oct2014','23Sep2014', '25Sep2014','29Jul2014','30Jul2014_2'};%??
season.winter_dates = {'08July2014', '15July2014', '26Jun2014', '30Oct2014', '30Oct2014_2'}; 

headingNames = {'Bias-Index'    'Latency'    'Transience'    'RF-Index'    'DS-Index'  'pref_Spot_Diam'}
xLim = [ -1 1; 0 2; 0 2; 0 1; 0 1; 0 1000];
yLim = [0 25;0 25; 0 25; 0 25; 0 25;0 25]
yLabel = 'Counts';
xLabel = {'Index' 'Time (sec)' 'Time (sec)' 'Index' 'Index' 'Spot Diam (um)' }

warning('Plot restricted to defined winter and autumn dates.')

idx.winter = [];
idx.autumn = [];

for i=1:length(season.winter_dates)
    idx.winter = [idx.winter cells.cell_find_str2(paraOutputMat.neur_names,season.winter_dates{i} ,'partial_match')];
end
for i=1:length(season.autumn_dates)
    idx.autumn = [idx.autumn cells.cell_find_str2(paraOutputMat.neur_names,season.autumn_dates{i} ,'partial_match')];
end
numParams = length(headingNames);
subPlotNos = [1:numParams];
for i=1:numParams
    subplot(2,numParams, subPlotNos(i)), hold on
    paraOutputMat.params(idx.winter,i);
    title([headingNames{i}, ' Winter']), xlabel(xLabel{i}), ylabel(yLabel)
    histInfo.winter = hist(paraOutputMat.params(idx.winter,i),linspace(xLim(i,1), xLim(i,2),histSegs));
    hist(paraOutputMat.params(idx.winter,i),linspace(xLim(i,1), xLim(i,2),histSegs))
    %     histc(paraOutputMat.params(idx.winter,i),linspace(xLim(i,1),xLim(i,2),15)); ylim([yLim(i,1), yLim(i,2)]);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','k','EdgeColor','k')
    xlim([xLim(i,1)-.25, xLim(i,2)+.25]);
    %
    subplot(2,numParams,subPlotNos(i)+numParams), hold on
    paraOutputMat.params(idx.autumn,i);
    title([headingNames{i}, ' Autumn']), xlabel(xLabel{i}), ylabel(yLabel)
    histInfo.autumn = hist(paraOutputMat.params(idx.autumn,i),linspace(xLim(i,1), xLim(i,2),histSegs));
    hist(paraOutputMat.params(idx.autumn,i),linspace(xLim(i,1), xLim(i,2),histSegs));axis square
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',ones(1,3)*0.5,'EdgeColor',ones(1,3)*0.5)
    yLimHigh =max(max([histInfo.autumn histInfo.winter]));
    xlim([xLim(i,1)-.25, xLim(i,2)+.25]); ylim([0 yLimHigh+1]);axis square
    subplot(2,numParams, subPlotNos(i))
    xlim([xLim(i,1)-.25, xLim(i,2)+.25]); ylim([0 yLimHigh+1]);axis square
end
set(gca,'FontSize',fontSize)
set(findall(gcf,'type','text'),'FontSize',fontSize)

% dirNameFig = '/home/ijones/Desktop/Work_Report-2014-08/Plots/';
% fileNameFig = sprintf('histogram_of_params_by_season');
% save plots
dirNameFig = '~/ln/vis_stim_hamster/plots/params_histogram_by_season';
mkdir(dirNameFig);
dateStr = strrep(strrep(datestr(now),' ', '_'),':','_');
fileNameFig = sprintf('histogram_of_params_by_season_%s',dateStr);


choice = input('Print? [y/n] >> ','s')
if strcmp(choice,'y')
    save.save_plot_to_file(dirNameFig, fileNameFig,'fig','no_title');
    save.save_plot_to_file(dirNameFig, fileNameFig,'eps','no_title');
end
%% Get parameters per cluster & plot
meanVals = [];
clusterNums = unique(paraOutputMat.params(:,7));
clusterData = {};
numClusters = length(clusterNums);
clusElementCnt = [];
colorMats = graphics.distinguishable_colors(nclass,[1 1 1]);

for iClus=1:length(clusterNums)
    currIdx = find(paraOutputMat.params(:,7)==clusterNums(iClus));
    
    for iParam = 1:5
        
        clusterData{iParam}.mean(iClus) = mean(paraOutputMat.params(currIdx, iParam));
        clusterData{iParam}.std(iClus) = std(paraOutputMat.params(currIdx, iParam));
    end
    clusElementCnt(iClus) = length(currIdx);
end


fontSize = 15
[Y dataSortIdx ] = sort(clusterData{1}.mean);

yLabel = {'Index' 'Time (sec)' 'Time (sec)' 'Index' 'Index' };
xLabel = 'Cluster #';
% plot
dirNameFig = '/home/ijones/Desktop/Work_Report-2014-08/Plots/';
for iParam = 1:5
    figure, hold on
    xLocCnt = 1;
    for iCol = dataSortIdx
        currColor = colorMats( iCol ,:);
        errorbar(xLocCnt, clusterData{iParam}.mean(iCol),clusterData{iParam}.std(iCol),'s','LineWidth', 2,'Color',currColor);
        xLocCnt = 1+xLocCnt;
    end
    %     errorbar(clusterData{iParam}.mean(dataSortIdx),clusterData{iParam}.std(dataSortIdx),'sk','LineWidth', 2)
    
    set(gca,'XTick',[1:numClusters]); xlim([0 numClusters+1])
    title(headingNames{iParam})
    ylabel(yLabel{iParam}), xlabel(xLabel);
    set(gca,'FontSize',fontSize)
    % set font
    set(findall(gcf,'type','text'),'FontSize',fontSize)
    % save plots
    fileNameFig = sprintf('cluster_plot_%s', headingNames{iParam});
    save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
    save.save_plot_to_file(dirNameFig, fileNameFig,'eps');
end
%% Get parameters per cluster & plot in subplot
meanVals = [];
clusterNums = unique(paraOutputMat.params(:,7));
clusterData = {};
numClusters = length(clusterNums);
clusElementCnt = [];
colorMats = graphics.distinguishable_colors(nclass,[1 1 1]);

for iClus=1:length(clusterNums)
    currIdx = find(paraOutputMat.params(:,7)==clusterNums(iClus));
    
    for iParam = 1:5
        
        clusterData{iParam}.mean(iClus) = mean(paraOutputMat.params(currIdx, iParam));
        clusterData{iParam}.std(iClus) = std(paraOutputMat.params(currIdx, iParam));
    end
    clusElementCnt(iClus) = length(currIdx);
end


fontSize = 5
[Y dataSortIdx ] = sort(clusterData{1}.mean);

yLabel = {'Index' 'Time (sec)' 'Time (sec)' 'Index' 'Index' };
xLabel = 'Cluster #';
% plot
dirNameFig = '/home/ijones/Desktop/Work_Report-2014-08/Plots/';
figure, hold on
for iParam = 1:5
    subplot(1,5,iParam), hold on
    xLocCnt = 1;
    for iCol = dataSortIdx
        currColor = colorMats( iCol ,:);
        errorbar(xLocCnt, clusterData{iParam}.mean(iCol),clusterData{iParam}.std(iCol),'s',...
            'LineWidth', 0.5,'Color',currColorp);
        xLocCnt = 1+xLocCnt;
    end
    %     errorbar(clusterData{iParam}.mean(dataSortIdx),clusterData{iParam}.std(dataSortIdx),'sk','LineWidth', 2)
    
    set(gca,'XTick',[1:numClusters]); xlim([0 numClusters+1])
    title(headingNames{iParam})
    ylabel(yLabel{iParam}), xlabel(xLabel);
    set(gca,'FontSize',fontSize)
    % set font
    set(findall(gcf,'type','text'),'FontSize',fontSize)
    % save plots
    axis square
   
end
% legend(num2str([1:12]'))
m = input('press enter>>')
 fileNameFig = sprintf('cluster_subplot_plot_%s', headingNames{iParam});
    save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
    save.save_plot_to_file(dirNameFig, fileNameFig,'eps');
%% plot count
clusElementCntSort = clusElementCnt(dataSortIdx);
figure, hold on
bar(clusElementCntSort,'k');
set(gca,'XTick',[1:numClusters]); xlim([0 numClusters+1])
title('Number Elements per Cluster')
ylabel('Number Clusters'), xlabel(xLabel);
set(gca,'FontSize',fontSize)
% set font
set(findall(gcf,'type','text'),'FontSize',fontSize)
% save plots
fileNameFig = sprintf('number_elements_per_cluster');
save.save_plot_to_file(dirNameFig, fileNameFig,'fig');
save.save_plot_to_file(dirNameFig, fileNameFig,'eps');


%% Put data into table
paramTable.data = zeros(numClusters, 5);
paramTable.std = zeros(numClusters, 5);

for iParam = 1:5
    paramTable.data(:,iParam) = clusterData{iParam}.mean(dataSortIdx)';
    paramTable.std(:,iParam) = clusterData{iParam}.std(dataSortIdx)';
end


