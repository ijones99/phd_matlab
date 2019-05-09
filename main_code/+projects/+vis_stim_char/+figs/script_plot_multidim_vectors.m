

% format indices matrix
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
% [r c i]= find(isnan(paraOutputMat.params(:,:)))
% rowIdxRem = unique([r' ]);%idxInvalid
% rowIdxSave = find(~ismember(1:size(paraOutputMat.params,1),rowIdxRem));
% 
% % paraOutputMat.neur_names = paraOutputMat.neur_names(rowIdxSave);
% paraOutputMat.params = paraOutputMat.params(unique(rowIdxSave),:);
% headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
%     'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}
% 

% remove nan and zero values
[r c i]= find(isnan(paraOutputMat.params(:,:)))
rowIdxRem = unique([r' find(nrmSpkCntAll<0.35)]);%idxInvalid

rowIdxSave = find(~ismember(1:size(paraOutputMat.params,1),rowIdxRem));

% paraOutputMat.neur_names = paraOutputMat.neur_names(rowIdxSave);
paraOutputMat.params = paraOutputMat.params(unique(rowIdxSave),:);

headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}

load ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns.mat


%% find num groups per type
bestClusNum = 7;
uniqueClus = unique(idxAssigns{bestClusNum });
memberCnt = [];
for i=1:length(uniqueClus)
    memberCnt(i) = length(find(idxAssigns{bestClusNum }==uniqueClus(i)));
end

%% plot centers
h1=figure, hold on
idxParam = 3:9;
clusCtrs = zeros(bestClusNum,length(idxParam));
cMapAll = colorcube;
cMap = cMapAll([15: 3:64],:);

% get centers
for i=1:bestClusNum
   currIdx = find(idxAssigns{bestClusNum }==i);
   clusCtrs(i,:) = mean(paraOutputMat.params(currIdx,idxParam ),1);
   plot(clusCtrs(i,1),clusCtrs(i,2),'*', 'Color', cMap(i,:),'LineWidth',2);
   text(clusCtrs(i,1),clusCtrs(i,2)+0.05,num2str(i),'Color', cMap(i,:))
end

figs.maximize(h1);
title('Cluster Mean Locations');

% save.save_plot_to_file(dirThisDoc,'cluster_center_locs','fig','add_filename_datestr');
% save.save_plot_to_file(dirThisDoc,'cluster_center_locs','eps','add_filename_datestr');

%% Density Distributions

allClusCombos = nchoosek(1:bestClusNum ,2); 
currIdxSorting = idxAssigns{bestClusNum};
% get edge lengths
edgeLength = subplots.dimensions_for_ratio(length(allClusCombos ), 1.5);
h = figure
figs.maximize(h)



for j=1:length(allClusCombos )
    
    subplots.subplot_tight(edgeLength(1),edgeLength(2),j,0.05), hold on
    % get vector from center to center
    currVector = clusCtrs(allClusCombos(j,1),:)-clusCtrs(allClusCombos(j,2),:);
    currVector = currVector/max(currVector);
    a = paraOutputMat.params(:,idxParam );
    projA = linear_algebra.project_points_onto_vector(a,currVector);
   
    currIdx1 = find(currIdxSorting==allClusCombos(j,1));
    currIdx2 = find(currIdxSorting==allClusCombos(j,2));
    
    % fit gaussian
    [muhat1,sigmahat1] = normfit(projA(currIdx1));
    [muhat2,sigmahat2] = normfit(projA(currIdx2));
    
    projALims = mean([muhat1 muhat2])+[-1.2 1.2];
    plotIncr = 0.2;
    edges = [projALims(1):plotIncr:projALims(2)];
    edgesGauss = [projALims(1):plotIncr/10:projALims(2)];
    
    [counts1 ] = histc(projA(currIdx1), edges);
    [counts2 ] = histc(projA(currIdx2), edges);
       
    % fit gaussian
    norm1 = normpdf(edgesGauss,muhat1,sigmahat1);
    norm2 = normpdf(edgesGauss,muhat2,sigmahat2);
    
    % scale fit
    norm1 = normalize_values(norm1,[0 max(counts1)]);
    norm2 = normalize_values(norm2,[0 max(counts2)]);
    
    bar(edges'-plotIncr/4, counts1,0.5,'FaceColor','r','EdgeColor','none'); 
    hold on
    bar(edges'+plotIncr/4, counts2,0.5,'FaceColor','b','EdgeColor','none');
    
    plot(edgesGauss, norm1,'r-','LineWidth',1);
    plot(edgesGauss, norm2,'b-','LineWidth',1);
    
    
    titleName = sprintf('%d to %d', allClusCombos(j,1), allClusCombos(j,2));
    title(titleName)
    axis tight
    axis square
end
% legend(num2str([1:12]'))
suptitle('Density Plots Along Center-to-Center Vectors');
figs.maximize(h);
figs.font_size(8);
figs.format_for_pub( 'journal_name', 'frontiers','plot_dims',[30 30])
figs.save_for_pub({dirNames.common.figs, 'density_plots_along_center-to-center_vectors'})
% 
% save.save_plot_to_file(dirThisDoc,'cluster_center_locs','fig','add_filename_datestr');
% save.save_plot_to_file(dirThisDoc,'cluster_center_locs','eps','add_filename_datestr');

%% Density Distributions with fit
h=figure, hold on
% cMapAll = colorcube;
% cMap = cMapAll([ 7 12 17 25 28 41 46 56 60],:);

cMap = distinguishable_colors(11);
cMap = cMap([1:3 5 7:11],:);

allClusCombos = nchoosek(1:bestClusNum ,2); 
currIdxSorting = idxAssigns{bestClusNum};
% get edge lengths
edgeLength = subplots.dimensions_for_ratio(length(allClusCombos ), 1.5);
vectorName= {};
sepVal = [];
for j=length(allClusCombos ):-1:1
    IND = sub2ind([6 6],allClusCombos(j,1),7-(allClusCombos(j,2)-1));
    subplot(6,6,IND); hold on
 
    % get vector from center to center
    currVector = clusCtrs(allClusCombos(j,1),:)-clusCtrs(allClusCombos(j,2),:);
    currVector = currVector/max(currVector);
    a = paraOutputMat.params(:,idxParam );
    projA = linear_algebra.project_points_onto_vector(a,currVector);
    projALims = minmax(projA);
    edges = [projALims(1):0.1:projALims(2)];

    currIdx1 = find(currIdxSorting==allClusCombos(j,1));
    currIdx2 = find(currIdxSorting==allClusCombos(j,2));

    [counts1 ] = histc(projA(currIdx1), edges);
    [counts2 ] = histc(projA(currIdx2), edges);
    
    numSegs = round(abs(diff(maxmin(projA(currIdx2))))/0.14);
    m1 = histfit(projA(currIdx2),numSegs);
    [muhat2,sigmahat2] = normfit(projA(currIdx2));
     
    numSegs = round(abs(diff(maxmin(projA(currIdx1))))/0.14);
    hold on, 
    m2=histfit(projA(currIdx1),numSegs);
    [muhat1,sigmahat1] = normfit(projA(currIdx1));
    d = muhat2-muhat1;
    sepVal(j) = abs(d)/sqrt((abs(sigmahat1)*abs(sigmahat2)));
    fprintf('%2.2f %2.2f %2.2f\n',d, sigmahat1, sigmahat2) 
       
    g=findobj(gca,'Type','patch');
    set(g(1),'FaceColor',cMap(allClusCombos(j,1),:),'EdgeColor','w')
    set(m2(2),'color','k');
    set(g(2),'FaceColor',cMap(allClusCombos(j,2),:),'EdgeColor','w') % currIdx2
    set(m1(2),'color', 'k');
    
    %     figs.format_hist_for_pub('face_color','r');
    %     bar(edges, counts2);
    %alpha(0.8)
    hold on
    
    axis on
        
    titleName = sprintf('%d to %d', allClusCombos(j,1), allClusCombos(j,2));
    vectorName{j} = titleName;
    title(titleName)
    
    xlim([-2 2])
    figs.ticknum_interval(2,10);
end
% legend(num2str([1:12]'))
% suptitle('Density Plots Along Center-to-Center Vectors');
figs.maximize(h);
%% make legend
 figure, hold on, 
 for i=1:7, 
     plot(rand(1),rand(1),'s','MarkerFaceColor',cMap(i,:),'MarkerSize', 15), 
 end
 legend(num2str([1:7]'))
%% plot horiz-bar of separation coefficient
figure
[Y,I] = sort(sepVal,'descend');
figure, barh(sepVal(I)*-1,0.5);
set(gca,'YTick',[1:length(sepVal)])
set(gca,'YTickLabel',vectorName(I)) % s
title('Cluster Mean Separation Coefficient');
figs.format_hist_for_pub('journal_name','frontiers')
figs.save_for_pub(fullfile(dirNames.common.figs,'Cluster_Mean_Separation_Coefficient'));

%% plot table of separation coefficient
heatMap = nan(7);
idxHeat1 = sub2ind(size(heatMap), allClusCombos(:,1), allClusCombos(:,2));
heatMap(idxHeat1) = abs(sepVal);
h=figure, hold on
plot.table(heatMap,'hide_nans','dec_places','2.2')

axis equal
title('Heatmap Cluster Mean Separation Coefficient');
figs.format_hist_for_pub('journal_name','frontiers')
figs.save_for_pub(fullfile(dirNames.common.figs,'table_cluster_mean_separation_coefficient'));

%% heatmap separation coefficient
heatMap = nan(7);
idxHeat1 = sub2ind(size(heatMap), allClusCombos(:,1), allClusCombos(:,2));
idxHeat2 = sub2ind(size(heatMap), allClusCombos(:,2), allClusCombos(:,1));
heatMap(idxHeat1) = -sepVal;
heatMap(idxHeat2) = -sepVal;
figure, imagesc(heatMap)
axis equal
title('Heatmap Cluster Mean Separation Coefficient');
figs.format_hist_for_pub('journal_name','frontiers')
colorbar 
figs.save_for_pub(fullfile(dirNames.common.figs,'heatmap_cluster_mean_separation_coefficient'));


%% Histogram of Distributions 
for constIdx = 1:12
h=figure, hold on


clusterRange = [1:12];
clusterLoopNums = clusterRange(find(~ismember(clusterRange, constIdx)));

for j=clusterLoopNums
    
    subplot(3,4,j), hold on
    % get vector
    currVector = clusCtrs(constIdx,:)-clusCtrs(j,:);
    currVector = currVector/max(currVector);
    
    a = paraOutputMat.params(:,idxParam );
    projA = linear_algebra.project_points_onto_vector(a,currVector);
    allVals = projA;
    plotOrder = [1:12 j constIdx];
    for i=plotOrder
        currIdx = find(currIdxSorting==i);
        edges = linspace( min(allVals),max(allVals),20);
        n = histc(projA(currIdx),edges);
        
        
        if i~=j & i~=constIdx
            plot(edges,n,'.-','Color',0.5*ones(1,3),'LineWidth',2);
        else
            plot(edges,n,'.-','Color',colorMats(i,:),'LineWidth',2);
        end
    end
    titleName = sprintf('%d to %d', j, constIdx);
    title(titleName)
    
end
%
% legend(num2str([1:12]'))
suptitle(sprintf('Density Histogram Plots Along Center-to-Center Vectors (Clus %d)',constIdx));
figs.maximize(h);
fileName = sprintf('cluster_histograms_clus_%d',constIdx);
save.save_plot_to_file(dirThisDoc,fileName ,'fig','add_filename_datestr');
save.save_plot_to_file(dirThisDoc,fileName ,'eps','add_filename_datestr');
close all
end

