% plot results
%  C = combnk(1:5,2);
C = [ 1 2; ...
    1 3;...
    1 4;...
    1 5;...
    2 3;...
    2 4;...
    2 5;...
    3 4;...
    3 5; ...
    4 5;...
    ]

xLims = [...
    -1 1;...
    -1 1;...
    -1 1;...
    -1 1;...
    0.06 0.9;...
    0.06 0.9;...
    0.06 0.9;...
    0.03 1.2;...
    0.03 1.2;...
    0.08 .92;...
    ]
yLims = [...
    0.06 0.9;...
    0.03 1.2;...
    0.08 .92;...
    0 0.55
    0.03 1.2;...
    0.08 0.92;...
    0 0.55;...
    0.08 0.92;...
    0 0.55;...
    0 0.55;...
    ]
%% remove nan and zero values
[r c i]= find(isnan(paraOutputMat.params(:,1:5)))
[r2 c i] = find(paraOutputMat.params(:,2:5)==0);
rowIdxRem = unique([r' r2']);
rowIdxSave = find(~ismember(1:size(paraOutputMat.params,1),rowIdxRem));

paraOutputMat.neur_names = paraOutputMat.neur_names(rowIdxSave);
paraOutputMat.params = paraOutputMat.params(unique(rowIdxSave),:);

%% cluster all with fuzzy GK
headingNames = {'Bias-Index'    'Latency'    'Transience'    'RF-Index'    'DS-Index'}

xyLimsOff = 0;
nclass = 12;
data = paraOutputMat.params(:,1:5);
phi=2;
maxiter=100;
distype=1;
toldif = 1.0000e-07;
scatter =  0.1000;
ntry = 500;
ndata = size(data,1);
choice = input('run fuzzy gk?','s')
if strcmp(choice,'y')
    [U, cbest, dist, W, obj] = run_fuzme(nclass,data,phi,maxiter,distype,toldif,scatter,ntry);

    %     Uinit= initmember(0.1,nclass,ndata);
    %     [U, centroid, dist, W, F, obj] = gk_fkm(nclass,data,Uinit,phi,maxiter,toldif)
end
[Y,idxAssigns] = max(U,[],2);

paramClustering = {};
paraClustering.neur_names = paraOutputMat.neur_names;
paraClustering.clusterAssigns = idxAssigns;

%% Plot clusters
figure 
headingNamesSel = headingNames(3:7);
combos = nchoosek(1:5,2);
numCombos = size(combos,1);
subplotDims = subplots.find_edge_numbers_for_square_subplot(numCombos);

for iPlot = 1:numCombos;
    subplot(subplotDims(1),subplotDims(2), iPlot)
    projects.vis_stim_char.figs.plot_clusters(data, clusterAssigns, ...
        combos(iPlot, 1),combos(iPlot, 2))
    title(sprintf('%s vs %s', headingNamesSel{combos(iPlot, 2)},headingNamesSel{combos(iPlot, 1)}))
    xlabel(headingNamesSel{combos(iPlot, 1)});
    ylabel(headingNamesSel{combos(iPlot, 2)});
    axis square
end

%% get cluster names within groups
paramClusIdx = 3;
paraClustering.neur_names(find(paraClustering.clusterAssigns == paramClusIdx))   

%% plot all clusters
colorMats = graphics.distinguishable_colors(nclass,[1 1 1]);
doLims = input('set x and y lims? [y/n] >> ','s');
fontSize = 7;
h=figure, hold on
numParams = size(paraOutputMat.params,2);
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
        plot(paraOutputMat.params(I,C(i,1)),paraOutputMat.params(I,C(i,2)),'*',...
            'LineWidth',3,'Color',colorMats(iClus,:),'MarkerSize',3)
        paraOutputMat.params(I,numParams+1) = iClus;
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

suptitle(sprintf('All Params, n = %d, kmeans reps = 30,000', size(paraOutputMat.params,1)))
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


