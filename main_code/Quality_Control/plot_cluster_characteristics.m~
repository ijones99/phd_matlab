function plot_cluster_characteristics(principalClusInds, selClusterInds, ...
    printToFile, flistName,outputDir, flistFileIDSuffix)
% mod by ijones
% UltraMegaSort2000 by Hill DN, Mehta SB, & Kleinfeld D  - 07/12/2010
%
% plot_cluster_characteristics -- creates a figure to plot various statistics of a set of clusters
%
% Usage:
%       show_clusters( spikes, clusters, alt_assigns )
%
% Description:
%    Builds a figure with a row of plots for each specified cluster. Plots
%  are generated as follows:
%
%    column 1          =>          plot_waveforms
%    column 2          =>          plot_residuals
%    column 3          =>          plot_detection_criterion
%    column 4          =>          plot_isi
%    column 5          =>          plot_stability
%
%  SliderFigure is also called to allow the user to scale plots.
%
% Input:
%  spikes      - a spikes structure
%
% Optional input:
%  clusters        - list of cluster IDs (default is to use all clusters)
%  alt_assigns - alternate list of spike assignments (default is to use spikes.assigns)

% Page Layout:
% large image of waves, isi, spike distance
% n1: waves, PCA, Fisher, xcorr

% get names for files
% directory
flistFileNameIDStartPoint = strfind(flistName,'T');flistFileNameIDStartPoint(1)=[];
flistFileNameID = flistName(flistFileNameIDStartPoint:end-11);
dirNameSt = strcat('../analysed_data/',flistFileNameID,flistFileIDSuffix,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',flistFileNameID,flistFileIDSuffix,'/02_Post_Spikesorting/');

% file types to open
fileNamePatternSt = fullfile(dirNameSt,'st_*mat');
fileNamePatternCl = fullfile(dirNameCl,'cl_*mat');

% obtain file names
fileNamesSt = dir(fileNamePatternSt); numStFiles = length(fileNamesSt);
fileNamesCl = dir(fileNamePatternCl); numClFiles = length(fileNamesCl);

% get cluster indices
selClusterInds = [ principalClusInds selClusterInds ];

% assign spikes data to spikes{} structure
% spikes are ordered according to selClusterNos input
spikes = {};
spikes{1} = struct('el',[], 'clusInd',[], 'clus', [], 'neighborClus',[]);
iSpikes = 1;
for i=selClusterNos
    
    % load cl-file
    load(fullfile( dirNameCl, strcat('cl_',spikes{iSpikes}.el,'.mat')));
    %     eval([ fileNamesCl(i).name(1:end-4), '.info.kmeans.colors = rand(200,3);']);
    %         load(fullfile( dirNameCl, fileNamesCl(iSpikes).name));
    %     eval([ fileNamesCl(i).name(1:end-4), '.info.kmeans.colors = rand(200,3);']);
    
    % save electrode # to spikes cell
    spikes{iSpikes}.el = fileNamesSt(i).name(4:7);
    
    % save cluster index 
    spikes{iSpikes}.clusInd = num2str(i);
    
    periodLoc = strfind(fileNamesSt(i).name,'.');
    spikes{iSpikes}.clus = fileNamesSt(i).name(9:periodLoc-1);
    eval(['spikes{iSpikes}.spikes = cl_',spikes{iSpikes}.el,';'])
    eval(['neighboringClus = cl_',spikes{iSpikes}.el,'.labels(:,1);']);
    neighboringClus = neighboringClus(find(~ismember( neighboringClus, str2num(spikes{iSpikes}.clus ))));
    spikes{iSpikes}.neighborClus = neighboringClus;
    iSpikes = iSpikes+1;
end

axis off
scrsz = get(0,'ScreenSize');
% h = figure('Units','Normalized', 'Color',[1 1 1], ...
%     'PaperPositionMode','auto','PaperType', 'A4','Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
h = figure('PaperType', 'A4', 'Color',[1 1 1],...
    'Position',[scrsz(3)/4 scrsz(4) scrsz(3)/3 scrsz(4)*7/8])

title(strcat('clusInd:', spikes{1}.clusInd,'Electrode:', spikes{1}.el, ...
    'Cluster:', spikes{1}.clus), 'FontSize', 14);
axis off

set(h,'Pointer','watch'),pause(.01)
% set(h,'defaultaxesfontsize',spikes{1}.spikes.params.display.figure_font_size);
set(h,'defaultaxesfontsize',8);



% params for plotting
params.width = 100;
params.margin = 70;
params.aspect_ratio = .6667;
params.outer_margin = 70;
impose_margins = 1;
row = 1;
spikes{1}.spikes.params.display.figure_font_size = 6;

pageOffset = -20;

params.width = 150;
col = 1;
grid_pos = [row,col,1,1];
pos = get_pos_on_grid( grid_pos, params, h, 1 );pos(2) = pos(2)+pageOffset;

ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
plot_waveforms(spikes{1}.spikes,str2num(spikes{1}.clus));

params.width = 70;
col = col+2;
grid_pos = [row,col,1,1];
pos = get_pos_on_grid( grid_pos, params, h, 1 );pos(2) = pos(2)+pageOffset;
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
plot_isi(spikes{1}.spikes,str2num(spikes{1}.clus));
axis on
title('ISI');

col = col+1;
grid_pos = [row,col,1,1];
pos = get_pos_on_grid( grid_pos, params, h, 1 );pos(2) = pos(2)+pageOffset;
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
plot_detection_criterion(spikes{1}.spikes,str2num(spikes{1}.clus));
plot_isi
params.width = 100;
params.margin = 75;
set(h,'defaultaxesfontsize',8);
%PCA1 vs PCA2
col = 1;
row = 2;
grid_pos = [row,col,1,1];
pos = get_pos_on_grid( grid_pos, params, h, 1 );pos(2) = pos(2)+pageOffset;
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
plot_features_with_legend(spikes{1}.spikes, 'all')

%PCA1 vs PCA3
spikes{1}.spikes.params.display.yparam = 3;
col = 2;
grid_pos = [row,col,1,1];
pos = get_pos_on_grid( grid_pos, params, h, 1 );pos(2) = pos(2)+pageOffset;
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
plot_features_with_legend(spikes{1}.spikes, 'all')

%PCA2 vs PCA3
spikes{1}.spikes.params.display.xparam = 2;
col = 3;
grid_pos = [row,col,1,1];
pos = get_pos_on_grid( grid_pos, params, h, 1 );pos(2) = pos(2)+pageOffset;
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
plot_features_with_legend(spikes{1}.spikes, 'all')

% reset values
params.width = 100;
params.margin = 70;
spikes{1}.spikes.params.display.xparam = 1;
spikes{1}.spikes.params.display.yparam = 2;

rowOffSet = 2;
numClusToPlotInFirstFig = length( spikes{1}.neighborClus);
totalNumSpikes = length( spikes{1}.neighborClus);

if numClusToPlotInFirstFig > 5, numClusToPlotInFirstFig=5; end

    for iRow = 1:numClusToPlotInFirstFig
        set(h,'defaultaxesfontsize',8);
        %ISI
        iCol = 1;
        grid_pos = [iRow + rowOffSet,iCol,1,1];
        pos = get_pos_on_grid( grid_pos, params, h, 1 );pos(2) = pos(2)+pageOffset;
        ax(iRow + rowOffSet,iCol) = axes('Visible','off','Units','pixel','Position',pos);
        plot_waveforms(spikes{1}.spikes,(spikes{1}.neighborClus(iRow)));
        title('ISI');
        
        
        %plot fisher
        iCol = 2;
        grid_pos = [iRow + rowOffSet,iCol,1,1];
        pos = get_pos_on_grid( grid_pos, params, h, 1 ); pos(2) = pos(2)+pageOffset;
        ax(iRow+4,iCol) = axes('Visible','off','Units','pixel','Position',pos);
        show1 = find(spikes{1}.spikes.assigns == str2num(spikes{1}.clus));
        show2 = find(spikes{1}.spikes.assigns == spikes{1}.neighborClus(iRow));
        display = 1;
        plot_fld_use_inds( spikes{1}.spikes, show1, show2, display );
        
        title(strcat('Fisher Disc: ', num2str(spikes{1}.spikes.labels(1)), ...
            ' vs. ', num2str(spikes{1}.neighborClus(iRow))));
        
        %plot Xcorr
        iCol = 3;
        grid_pos = [iRow + rowOffSet,iCol,1,1];
        pos = get_pos_on_grid( grid_pos, params, h, 1 ); pos(2) = pos(2)+pageOffset;
        ax(iRow + rowOffSet,iCol) = axes('Visible','off','Units','pixel','Position',pos);
        plot_xcorr_use_inds(spikes{1}.spikes, spikes{1}.spikes,...
            find(spikes{1}.spikes.assigns == str2num(spikes{1}.clus)), ...
            find(spikes{1}.spikes.assigns == spikes{1}.neighborClus(iRow) ));
        title(strcat('Ind#', num2str(spikes{1}.clus) ,' vs Ind#', ...
            num2str(spikes{1}.neighborClus(iRow))),'FontSize', 8);
        
    end


% if and(length( spikes{1}.neighborClus) >5 , length( spikes{1}.neighborClus) <= 12)
if totalNumSpikes >5 
    h2 = figure('PaperType', 'A4', 'Color',[1 1 1],...
        'Position',[scrsz(3)/4 scrsz(4) scrsz(3)/3 scrsz(4)*7/8])
    
    title(strcat('clusInd:', spikes{1}.clusInd,'Electrode:', spikes{1}.el, ...
        'Cluster:', spikes{1}.clus), 'FontSize', 14);
    axis off
    
    set(h2,'Pointer','watch'),pause(.01)
    % set(h,'defaultaxesfontsize',spikes{1}.spikes.params.display.figure_font_size);
    set(h2,'defaultaxesfontsize',8);
    
    
    
    for iRow2 = 7:min(totalNumSpikes, 12) 
        set(h2,'defaultaxesfontsize',8);
        %ISI
        iCol = 1;
        grid_pos = [(iRow2-8+rowOffSet),iCol,1,1];
        pos = get_pos_on_grid( grid_pos, params, h2, 1 );pos(2) = pos(2)+pageOffset;
        ax(iRow2 -6 + rowOffSet,iCol) = axes('Visible','off','Units','pixel','Position',pos);
        plot_waveforms(spikes{1}.spikes,(spikes{1}.neighborClus(iRow2)));
        title('ISI');
        
        
        %plot fisher
        iCol = 2;
        grid_pos = [(iRow2-8+rowOffSet),iCol,1,1];
        pos = get_pos_on_grid( grid_pos, params, h2, 1 ); pos(2) = pos(2)+pageOffset;
        ax(iRow2 -6+4,iCol) = axes('Visible','off','Units','pixel','Position',pos);
        show1 = find(spikes{1}.spikes.assigns == str2num(spikes{1}.clus));
        show2 = find(spikes{1}.spikes.assigns == spikes{1}.neighborClus(iRow2));
        display = 1;
        plot_fld_use_inds( spikes{1}.spikes, show1, show2, display );
        
        title(strcat('Fisher Disc: ', num2str(spikes{1}.spikes.labels(1)), ...
            ' vs. ', num2str(spikes{1}.neighborClus(iRow2))));
        
        %plot Xcorr
        iCol = 3;
        grid_pos = [(iRow2-8+rowOffSet),iCol,1,1];
        pos = get_pos_on_grid( grid_pos, params, h2, 1 ); pos(2) = pos(2)+pageOffset;
        ax(iRow2 -6 + rowOffSet,iCol) = axes('Visible','off','Units','pixel','Position',pos);
        plot_xcorr_use_inds(spikes{1}.spikes, spikes{1}.spikes,...
            find(spikes{1}.spikes.assigns == str2num(spikes{1}.clus)), ...
            find(spikes{1}.spikes.assigns == spikes{1}.neighborClus(iRow2) ));
        title(strcat('Ind#', num2str(spikes{1}.clus) ,' vs Ind#', ...
            num2str(spikes{1}.neighborClus(iRow2))),'FontSize', 8);
        
    end
end
if totalNumSpikes > 12
    
    h3 = figure('PaperType', 'A4', 'Color',[1 1 1],...
        'Position',[scrsz(3)/4 scrsz(4) scrsz(3)/3 scrsz(4)*7/8])
    
    title(strcat('clusInd:', spikes{1}.clusInd,'Electrode:', spikes{1}.el, ...
        'Cluster:', spikes{1}.clus), 'FontSize', 14);
    axis off
    
    set(h3,'Pointer','watch'),pause(.01)
    % set(h,'defaultaxesfontsize',spikes{1}.spikes.params.display.figure_font_size);
    set(h3,'defaultaxesfontsize',8);
    
    
    
    for iRow3 = 14:totalNumSpikes
        set(h3,'defaultaxesfontsize',8);
        %ISI
        iCol = 1;
        grid_pos = [(iRow3-8-7+rowOffSet),iCol,1,1];
        pos = get_pos_on_grid( grid_pos, params, h3, 1 );pos(2) = pos(2)+pageOffset;
        ax(iRow3 -6 + rowOffSet,iCol) = axes('Visible','off','Units','pixel','Position',pos);
        plot_waveforms(spikes{1}.spikes,(spikes{1}.neighborClus(iRow3)));
        title('ISI');
        
        
        %plot fisher
        iCol = 2;
        grid_pos = [(iRow3-8-7+rowOffSet),iCol,1,1];
        pos = get_pos_on_grid( grid_pos, params, h3, 1 ); pos(2) = pos(2)+pageOffset;
        ax(iRow3 -6+4,iCol) = axes('Visible','off','Units','pixel','Position',pos);
        show1 = find(spikes{1}.spikes.assigns == str2num(spikes{1}.clus));
        show2 = find(spikes{1}.spikes.assigns == spikes{1}.neighborClus(iRow3));
        display = 1;
        plot_fld_use_inds( spikes{1}.spikes, show1, show2, display );
        
        title(strcat('Fisher Disc: ', num2str(spikes{1}.spikes.labels(1)), ...
            ' vs. ', num2str(spikes{1}.neighborClus(iRow3))));
        
        %plot Xcorr
        iCol = 3;
        grid_pos = [(iRow3-8-7+rowOffSet),iCol,1,1];
        pos = get_pos_on_grid( grid_pos, params, h3, 1 ); pos(2) = pos(2)+pageOffset;
        ax(iRow3 -6 + rowOffSet,iCol) = axes('Visible','off','Units','pixel','Position',pos);
        plot_xcorr_use_inds(spikes{1}.spikes, spikes{1}.spikes,...
            find(spikes{1}.spikes.assigns == str2num(spikes{1}.clus)), ...
            find(spikes{1}.spikes.assigns == spikes{1}.neighborClus(iRow3) ));
        title(strcat('Ind#', num2str(spikes{1}.clus) ,' vs Ind#', ...
            num2str(spikes{1}.neighborClus(iRow3))),'FontSize', 8);
        
    end
end

% finish up figure
set(ax,'Visible','on')
% sliderFigure(h,spikes{1}.spikes.params.display.outer_margin)

set(h,'Name','Show Clusters','NumberTitle','off','Pointer','arrow')
figure(h)
if totalNumSpikes > 5
    
    set(h2,'Name','Show Clusters','NumberTitle','off','Pointer','arrow')
    figure(h2)
end
if totalNumSpikes > 12
    
    set(h3,'Name','Show Clusters','NumberTitle','off','Pointer','arrow')
    figure(h3)
end
% flist ={};
% flist_for_analysis
% 
% if printToFile
%     saveToDir = '../Figs/DataSheets';
%     
%     %does directory exist?
%     if ~exist(saveToDir)
%         %    if not, then create it
%         eval(['!mkdir ',  saveToDir]);
%         
%     end
%     
%     imSuffix = strcat('ClusID',num2str(principalClusNo),'_');
%     
%     namingInfo = strfind(flist,'201');
%     % print('-dpng', '-r300', fullfile(saveToDir,strcat(imSuffix, ...
%     %     flist{1}(namingInfo{1}+10:end-11))));
%     
%     % saveas(h, fullfile(saveToDir,strcat(imSuffix, ...
%     %     flist{1}(namingInfo{1}+10:end-11),'.jpg')));
doSave = 1;
if doSave
    exportfig(gcf,fullfile(outputDir, fullfile(saveToDir,strcat('Data-Quality-Sheet', flistFileNameID), ...
        'width',6, 'fontmode','fixed', 'fontsize',8,'Color', 'cmyk')));
end


%     %     aa = input('Please adjust the print preview for figure and then press <enter>');
%     %     eval(['print -dpng -append -r400 ', fullfile(saveToDir,strcat(imSuffix, ...
%     %         flistFileNameID)) ])
%     %      eval(['print -dpsc2 -append -r350 ', fullfile(saveToDir,strcat(imSuffix, ...
%     %         flistFileNameID)) ])
%     %       eval(['print -dpsc2 -r450 ', fullfile(saveToDir,strcat(imSuffix, ...
%     %         flistFileNameID)) ])
% end

end



