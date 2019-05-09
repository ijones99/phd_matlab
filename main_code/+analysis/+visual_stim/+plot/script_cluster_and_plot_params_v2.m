
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
paraOutputMat.params(:,idxColParamMat) =  mats.set_orientation( b.RF_area_um_sqr,'col'); idxColParamMat = idxColParamMat + 1;


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

%% remove nan and zero values
[r c i]= find(isnan(paraOutputMat.params(:,:)))
rowIdxRem = unique([r' ]);%idxInvalid
rowIdxSave = find(~ismember(1:size(paraOutputMat.params,1),rowIdxRem));

% paraOutputMat.neur_names = paraOutputMat.neur_names(rowIdxSave);
paraOutputMat.params = paraOutputMat.params(unique(rowIdxSave),:);
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}

%% plot histograms of parameters
headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}

idxCol = [3:9];
subplotDims = subplots.find_edge_numbers_for_square_subplot(length(idxCol));
figure, hold on
suptitle('All Parameters')
for j=1:length(idxCol)
    subplot(subplotDims(1), subplotDims(2), j);
    hist(paraOutputMat.params(:,idxCol(j)),25);
    title(headingNames{idxCol(j)});
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
eval(sprintf('matlabpool open local%dclus',4));
idxAssigns = {};
idxCol = [3 4 5 7 8 ];
data = paraOutputMat.params(:,idxCol );
cpu.open_matlabpool(7)
parfor k=2:19
    idxAssigns{k} = kmeans(data,k,'Distance','cityblock','Replicates', 5000);
    k
end
%% plot silhouette
figure,
silh = {};
for k=2:19
    [silh{k},h] = silhouette(data,idxAssigns{k},'cityblock');
    h = gca;
    h.Children.EdgeColor = [.8 .8 1];
    xlabel 'Silhouette Value';
    ylabel 'Cluster';
    title(num2str(k))
    pause(0.2)
end

meanSilh = cellfun(@mean, silh(2:19));
k=2:19;
figure, plot(k, meanSilh,'o-c')
supTitle = ['Mean Silhouette Value for ', cells.concat_with_spacer(headingNames(idxCol),', ')];
dirNameFig = dirNames.common.clus_params;
fileNameFig = 'silhouette_values_for_clustering_plot_2';


if input('save? ')
    save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
        'font_size_all', 13 , ...
        'x_label', 'k (cluster number)','y_label', 'Mean Silhouette Value',...
        'sup_title', supTitle);
end

silhAnalysis.silh = silh;
silhAnalysis.param_names = headingNames(idxCol) ;
silhAnalysis.data = paraOutputMat.params;
silhAnalysis.idx_col_data = idxCol;
silhAnalysis.idx_assigns = idxAssigns;
silhAnalysis.k = k;
if input('Save? ')
    save(['silhAnalysis_', cells.concat_with_spacer(headingNames(idxCol),'_'),'.mat'], 'silhAnalysis')
end
%% get cluster names within groups
paramClusIdx = 3;
paraClustering.neur_names(find(paraClustering.clusterAssigns == paramClusIdx))   

%% plot clustered params

headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
selK = 8;
plotSymbol = {'>','x','<', '^', 'v', '+', 'o', 'd'};
C = nchoosek(idxCol, 2);
colorMats = graphics.distinguishable_colors(selK,[1 1 1]);

subplotDims = subplots.find_edge_numbers_for_square_subplot(length(C));
h=figure
figs.maximize(h)
for j=1:length(C)
    subplots.subplot_tight(subplotDims(1), subplotDims(2), j,.04); hold on
    
    for iParamClus = 1:selK
        currIdxPClus = find(idxAssigns{selK}==iParamClus);
        plot(paraOutputMat.params(currIdxPClus, C(j,1)),paraOutputMat.params(currIdxPClus, C(j,2)),plotSymbol{iParamClus},'Color',colorMats(iParamClus,:));
    end
    
    axis square
    %     title(sprintf('%s vs %s',  headingNames{C(j,2)}, ...
    %         headingNames{C(j,1)}));
    
    
    
    xlabel(headingNames{C(j,1)});
    ylabel(headingNames{C(j,2)});

end

%% plot all clusters

colorMats = graphics.distinguishable_colors(10,[1 1 1]);
doLims = input('set x and y lims? [y/n] >> ','s');
fontSize = 7;
h=figure, hold on
% idxCol = 3:8;
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
        
        I = find(idxAssigns==iClus);
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


