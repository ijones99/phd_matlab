function h = plot_cluster_characteristics2(spikes, ...
        clusterName, iNeuronInds, elNumber,clusterNumber , varargin)

% default values

% for optional arguments
if ~isempty(varargin)
       
end
% a4 paper: 210 by 297
figPosition =   [480    90   766   766*297/210]*.9;
% [scrsz(3)/4 scrsz(4) scrsz(3)/2.5 scrsz(4)*7/8]
h  = figure('PaperType', 'A4', 'Color',[1 1 1],...
    'Position',figPosition)


axes('Position',[.005 .005 .99 .99],'xtick',[],'ytick',[],'box','on','handlevisibility','off','Color',[1 1 1]) 

% [left bottom width height] : select  location and size for subfigure
setPercentPos = [.2 .90 .2 .05];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );

mTextBox = uicontrol('style','text')
row = 1; col = 1;
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
set(mTextBox,'String','Hello World2','FontSize', 12,'Position',pos,'HorizontalAlignment','left' )


% position settings
leftPosition = 0.20;
middlePosition = leftPosition + 0.20 +0.20/3 ;
rightPosition =  middlePosition + 0.20 +0.20/3 ;
rowHeight = 0.7;
width = 0.30;
height = 0.2;
x = [1:.05:10];y=sin(x);
% % Plot PCA space
% 
setPercentPos = [0.20 rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.xparam = 1;spikes.params.display.yparam = 2;
plot(x,y)%plot_features_with_legend(spikes, 'all')
% 
width = 0.17;
height = 0.14;
setPercentPos = [0.20+0.3+0.2/3 rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.yparam = 3;
plot(x,y)%plot_features_with_legend(spikes, 'all')

setPercentPos = [0.20+0.35+0.2/3+width rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.xparam = 2;
plot(x,y)%plot(x,y)%plot_features_with_legend(spikes, 'all')

width = 0.20;
height = width*figPosition(3)/figPosition(4);

% Plot PCA space
rowHeight = 0.5;
setPercentPos = [leftPosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.xparam = 1;spikes.params.display.yparam = 2;
plot(x,y)%plot_features_with_legend(spikes, 'all')

setPercentPos = [middlePosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.yparam = 3;
plot(x,y)%plot_features_with_legend(spikes, 'all')

setPercentPos = [rightPosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.xparam = 2;
plot(x,y)%plot(x,y)%plot_features_with_legend(spikes, 'all')


% Plot waveforms, linear discr., cross corr.
rowHeight = 0.3;
setPercentPos = [leftPosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.xparam = 1;spikes.params.display.yparam = 2;
plot(x,y)%plot_features_with_legend(spikes, 'all')

setPercentPos = [middlePosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.yparam = 3;
plot(x,y)%plot_features_with_legend(spikes, 'all')

setPercentPos = [rightPosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.xparam = 2;
plot(x,y)%plot(x,y)%plot_features_with_legend(spikes, 'all')

% Plot waveforms, linear discr., cross corr.
rowHeight = 0.1;
setPercentPos = [leftPosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.xparam = 1;spikes.params.display.yparam = 2;
plot(x,y)%plot_features_with_legend(spikes, 'all')

setPercentPos = [middlePosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.yparam = 3;
plot(x,y)%plot_features_with_legend(spikes, 'all')

setPercentPos = [rightPosition rowHeight width height];
pos = get_fig_coords_by_percent(figPosition, setPercentPos );
ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);
spikes.params.display.xparam = 2;
plot(x,y)%plot(x,y)%plot_features_with_legend(spikes, 'all')


end