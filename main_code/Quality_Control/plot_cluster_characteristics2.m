function h = plot_cluster_characteristics2(spikes, ...
        clusterName, iNeuronInds, elNumber,clusterNumber , varargin)
    

    doPlotPCA=1;
    % settings values
    testingOn = 0;
    numberRowsOnPage = 4;
    % default values
    
    % for optional arguments
    if ~isempty(varargin)
        for i=1:length(varargin)
            if strcmp(varargin{i},'testing_on')
                testingOn=1;
                
            
            elseif strcmp(varargin{i},'no_pca_plot')
                doPlotPCA=0;
                
            end
            
            
        end
    end

% get spike labels of good clusters

allClusterCatLabels = spikes.labels(:,2)';
goodClusterLabelInds = find(allClusterCatLabels~=4)';
badClusterLabelInds = find(allClusterCatLabels==4)';
badClusterLabels = spikes.labels(badClusterLabelInds,1);
goodClusterLabels = spikes.labels(goodClusterLabelInds,1);
allClusterLabelInds = [goodClusterLabelInds' badClusterLabelInds' ];
allClusterLabels = spikes.labels(allClusterLabelInds,1)';

% get indices for cluster timestamps
for i=1:length(allClusterLabels)
   clusterTsInds{i} = find(spikes.assigns == allClusterLabels(i));
   clusterTs{i} = spikes.spiketimes(clusterTsInds{i});  
end
   

%saved inds of timestamps

% delete bad cluster data
% spikes.waveforms( badClusterTsIndsAll,:,:) = [];
% spikes.spiketimes( badClusterTsIndsAll) = [];
% spikes.trials( badClusterTsIndsAll) = [];
% spikes.unwrapped_times( badClusterTsIndsAll) = [];
% spikes.assigns( badClusterTsIndsAll) = [];
% spikes.labels(badClusterTsIndsAll,:) = [];


% a4 paper: 210 by 297
figPosition =   [480    90   766   766*297/210]*.9;
% [scrsz(3)/4 scrsz(4) scrsz(3)/2.5 scrsz(4)*7/8]
h(1)  = figure('PaperType', 'A4', 'Color',[1 1 1],...
    'Position',figPosition)


axes('Position',[.005 .005 .99 .99],'xtick',[],'ytick',[],'box','on','handlevisibility','off','Color',[1 1 1]) 

% [left bottom width height] : select  location and size for subfigure
setPercentPos = [.75 .90 .2 .05];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );

mTextBox = uicontrol('style','text');
row = 1; col = 1;
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
 textboxInfo = strcat(['Cluster ', strrep(strrep(clusterName,'.mat',''),'st_',''), ' Ind ', num2str(iNeuronInds), ...
        ' (Page 1 of ' num2str(1+ceil((size(allClusterLabelInds,2)-2)/numberRowsOnPage)),')']);
set(mTextBox,'String',textboxInfo,'FontSize', 12,'Position',pos,'HorizontalAlignment','left', ...
    'BackgroundColor',[0.9 0.9 0.9])


% position settings
leftPosition = 0.20;
middlePosition = leftPosition + 0.20 +0.20/3 ;
rightPosition =  middlePosition + 0.20 +0.20/3 ;
rowHeight = 0.7;
width = 0.30;
height = 0.2;

% dummy data
x = [1:.05:10];y=sin(x);

% % TOP ROW: plot waveforms; isi; missing spikes
% 
setPercentPos = [0.20 rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.xparam = 1;spikes.params.display.yparam = 2;
plot_waveforms(spikes,str2num(clusterNumber));
% 
width = 0.17;
height = 0.14;
setPercentPos = [0.20+0.3+0.2/3 rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','on','Units','pixel','Position',pos);
spikes.params.display.yparam = 3;
plot_isi(spikes,str2num(clusterNumber));
axis on
title('ISI');

setPercentPos = [0.20+0.35+0.2/3+width rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','on','Units','pixel','Position',pos);
spikes.params.display.xparam = 2;
plot_detection_criterion(spikes,str2num(clusterNumber));

width = 0.20;
height = width*figPosition(3)/figPosition(4);

reduceDensityOfBadClusters=0;

% Plot PCA space
rowHeight = 0.5;
setPercentPos = [leftPosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','on','Units','pixel','Position',pos);
spikes.params.display.xparam = 1;spikes.params.display.yparam = 2;
% get indices of timestamps to plot
if reduceDensityOfBadClusters
    maxNumberSpikesInBadCluster = 5000;
badTsIndsToPlot = {};
for iBadClusters = 1:length(badClusterLabels) % go through bad clusters
    badTsInds = find(ismember(spikes.assigns, badClusterLabels(iBadClusters))); % get bad timestamps
    if length(badTsInds) > maxNumberSpikesInBadCluster
        stepSize = length(badTsInds)/maxNumberSpikesInBadCluster;
        spikes.assigns(badTsInds) = 9999;
        spikes.assigns(badTsInds(1:stepSize:end)) = badClusterLabels(iBadClusters);
    end
end
end

labelsToPlot = [goodClusterLabels' badClusterLabels'];
if ~doPlotPCA, plot(x,y), else plot_features_with_legend(spikes, labelsToPlot), end

setPercentPos = [middlePosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','on','Units','pixel','Position',pos);
spikes.params.display.yparam = 3;
if ~doPlotPCA, plot(x,y), else plot_features_with_legend(spikes, 'all'), end

setPercentPos = [rightPosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','on','Units','pixel','Position',pos);
spikes.params.display.xparam = 2;
if ~doPlotPCA, plot(x,y), else plot_features_with_legend(spikes, 'all'), end

% row height as percentage of page height
rowHeightPercent = [0.3 0.1];

% get cluster label info
allClusterLabelsNonPrimaryInds = find(~ismember(allClusterLabels, str2num(clusterNumber)));
allClusterLabelsNonPrimary = allClusterLabels(allClusterLabelsNonPrimaryInds);
allClusterLabelsPrimaryInd = find(ismember(allClusterLabels, str2num(clusterNumber)));
allClusterLabelsPrimary = allClusterLabels(allClusterLabelsPrimaryInd);

% display on
display = 1;

% plot on first page
for iCluster = 1:min(2, length(allClusterLabelsNonPrimary))
    rowHeight = rowHeightPercent( iCluster);
    waveformClusterLabel = allClusterLabelsNonPrimary(iCluster);
    show1 = clusterTsInds{allClusterLabelsPrimaryInd};
    show2 = clusterTsInds{allClusterLabelsNonPrimaryInds(iCluster)};
    plot_subcluster_infos(rowHeight, waveformClusterLabel, show1, show2, ... 
    leftPosition,  middlePosition, rightPosition, width, height, figPosition, setPercentPos, ...
    pos, spikes, row, col, display, badClusterLabels )
end



rowHeightPercent = [.7:-.2:.1];
if length(allClusterLabelsNonPrimary) > 2
    % cycle through additional pages
    for iPage = 2:ceil((length(allClusterLabelsNonPrimary)-2)/numberRowsOnPage)+1
        % make new page
        h(iPage)  = figure('PaperType', 'A4', 'Color',[1 1 1],...
            'Position',figPosition);
        
        
        axes('Position',[.005 .005 .99 .99],'xtick',[],'ytick',[],'box','on','handlevisibility','off','Color',[1 1 1])
        
        % [left bottom width height] : select  location and size for subfigure
        setPercentPos = [.75 .90 .2 .05];
        pos = get_fig_coords_by_percent(figPosition, setPercentPos );
        
        mTextBox = uicontrol('style','text')
        row = 1; col = 1;
        ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
         textboxInfo = strcat(['Cluster ', strrep(strrep(clusterName,'.mat',''),'st_',''), ' Ind ', num2str(iNeuronInds), ...
        ' (Page ', num2str(iPage), ' of ' num2str(1+ceil((size(allClusterLabelInds,2)-2)/numberRowsOnPage)),')']);
        set(mTextBox,'String',textboxInfo,'FontSize', 12,'Position',pos,'HorizontalAlignment','left', ...
             'BackgroundColor',[0.9 0.9 0.9] )
        
        clustersOnThisPage = length(allClusterLabelsNonPrimary)-2-(iPage-2)*numberRowsOnPage;
        
        for iCluster = 1:min(numberRowsOnPage, clustersOnThisPage )
            rowHeight = rowHeightPercent( iCluster);
            neurSel = 2+(iPage-2)*numberRowsOnPage+iCluster;
            waveformClusterLabel = allClusterLabelsNonPrimary(neurSel);
            show1 = clusterTsInds{allClusterLabelsPrimaryInd};
            show2 = clusterTsInds{allClusterLabelsNonPrimaryInds(neurSel)};
            plot_subcluster_infos(rowHeight, waveformClusterLabel, show1, show2, ...
                leftPosition,  middlePosition, rightPosition, width, height, figPosition, setPercentPos, ...
                pos, spikes, row, col, display, badClusterLabels )
        end
        
        
        
    end
    
    
end






end


function plot_subcluster_infos(rowHeight, waveformClusterLabel, show1, show2, ... 
    leftPosition,  middlePosition, rightPosition, width, height, figPosition, setPercentPos, ...
    pos, spikes, row, col, display, badClusterLabels )

    % Plot waveforms, 
    setPercentPos = [leftPosition rowHeight width height];
    pos = get_fig_coords_by_percent(figPosition, setPercentPos );
    ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
    plot_waveforms(spikes,waveformClusterLabel);
    if sum(ismember(badClusterLabels, waveformClusterLabel ))
       title('Bad Cluster') 
    end
    
    % linear discr.,
    setPercentPos = [middlePosition rowHeight width height];
    pos = get_fig_coords_by_percent(figPosition, setPercentPos );
    ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
    plot_fld_use_inds( spikes, show1, show2, display );
    title(strcat('Fisher Disc: '))%, num2str(spikes{1}.spikes.labels(1)), ...
%         ' vs. ', num2str(spikes{1}.neighborClus(iRow))));

    % cross corr.
    setPercentPos = [rightPosition rowHeight width height];
    pos = get_fig_coords_by_percent(figPosition, setPercentPos );
    ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
    plot_xcorr_use_inds(spikes, spikes,...
            show1,show2 );
 
end


