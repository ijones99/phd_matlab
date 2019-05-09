x = linspace(-10,10,200);
y = cos(x);
plot(x,y)

ax = gca;
ax.XTick = [-3*pi,-2*pi,-pi,0,pi,2*pi,3*pi];
ax.YTick = [-1,-0.5,0,0.5,1];

ax.XTickLabel = {'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'};
ax.YTickLabel = {'min = -1','-0.5','0','0.5','max = 1'};





%% plot and save figure

figure,
plot(rand(1,50),'LineWidth', 1); hold on, plot(rand(1,50),'r','LineWidth', 1)
figs.format_for_pub
figs.save_for_pub('~/Desktop/matilda6')




%% plot and save figure

%# cate some plot, and make axis fill entire figure
figure,
plot(1:50,'LineWidth', 2); hold on, plot(51:100,'r','LineWidth', 2)

edgeDist = [1 1];
plotDims = [5 5];
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [edgeDist plotDims]);

%# set size of figure's "drawing" area on screen
% set(gcf, 'Units','centimeters', 'Position',[0 0 20 20])

dirNameFig = '~/Desktop/';
fileNameFig = 'testPlot_03';
supTitle = 'Test'
xlabel('X label')
ylabel('Y label')
figs.font_size(12)
figs.font_name('Times')
xlim([0 50])
shg
figs.numticks(6,6)
% print -depsc -tiff -r900 ~/Desktop/matilda2
figs.save_for_pub('~/Desktop/matilda4')
%%
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps'},...
    'font_size_all', 8 , ...
     'sup_title', supTitle,'font_name_all','Times');

%% Initial run

% load data directories
dirNames = projects.vis_stim_char.analysis.load_dir_names;

for iDir = 1%:length(dirNames.dataDirLong) % loop through directories
    close all
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    %     clearvars -except dirNames iDir param_BiasIndex % clear vars
    script_load_data; load idxNeur ; load idxToMerge.mat; load idxFinalSel% load data
    %     load(fullfile(dirNames.marching_sqr_over_grid,'dataOut'))
    dataOut = projects.vis_stim_char.analysis.marching_sqr_over_grid.process_spiketrains(...
        idxFinalSel.keep);
    dataOut = projects.vis_stim_char.analysis.marching_sqr_over_grid.get_rf_size(dataOut);
    
end


%%

[xi,yi] = meshgrid(-10:10,-20:20);
xip = (xi-4)*cos(pi/6) + yi*sin(pi/6);
yip =-(xi-4)*sin(pi/6) + yi*cos(pi/6);
zi = exp(-(xip.^2+yip.^2)/2/2^2).*cos(xip*2*pi/5+pi/3) + .2*randn(size(xi));
results = autoGaborSurf(xi,yi,zi);


figure,
iP = 1;
subplot(2,2,iP); iP = iP+1;
imagesc(dataOut.direc1{iClus}.on.mean_fr)
subplot(2,2,iP); iP = iP+1;
imagesc(dataOut.direc2{iClus}.on.mean_fr)
subplot(2,2,iP); iP = iP+1;
imagesc(dataOut.direc1{iClus}.off.mean_fr)
subplot(2,2,iP); iP = iP+1;
imagesc(dataOut.direc2{iClus}.off.mean_fr)


%%

 % get peak firing rate and position
    dataOut.xy_loc = [];
    [dataOut.direc1{iClus}.on.peak_fr, idxLoc] = max(dataOut.direc1{iClus}.on.peak_mean_fr);
    

    
    
    dataOut.direc1{iClus}.on.edges = edges;dataOut.direc2{iClus}.on.edges = edges;
    dataOut.direc1{iClus}.off.edges = edges;dataOut.direc2{iClus}.off.edges = edges;
    
    % latency
    [amp, locMaxResponse] = max(dataOut.direc1{iClus}.on.peak_mean_fr);
    dataOut.direc1{iClus}.on.peak_fr = amp;
    dataOut.direc1{iClus}.on.latency = response_params_calc.latency_simple(...
        dataOut.direc1{iClus}.on.mean_fr(locMaxResponse,:), ...
        edges,'fit_spline', 'first_peak','min_fr', minLatencyFR);%, 'show_plot','raster', segmentsAdj(idxSegForCtr(1:2:end))

    [amp, locMaxResponse] = max(dataOut.direc2{iClus}.on.peak_mean_fr);
    dataOut.direc2{iClus}.on.peak_fr= amp;
    dataOut.direc2{iClus}.on.latency = response_params_calc.latency_simple(...
        dataOut.direc1{iClus}.on.mean_fr(locMaxResponse,:), ...
        edges,'fit_spline', 'first_peak','min_fr', minLatencyFR);%, 'show_plot','raster', segmentsAdj(idxSegForCtr(1:2:end))

    [amp, locMaxResponse] = max(dataOut.direc1{iClus}.off.peak_mean_fr);
    dataOut.direc1{iClus}.off.peak_fr= amp;
    dataOut.direc1{iClus}.off.latency = response_params_calc.latency_simple(...
        dataOut.direc1{iClus}.off.mean_fr(locMaxResponse,:), ...
        edges,'fit_spline', 'first_peak','min_fr', minLatencyFR);%, 'show_plot','raster', segmentsAdj(idxSegForCtr(1:2:end))

    [amp, locMaxResponse] = max(dataOut.direc2{iClus}.off.peak_mean_fr);
    dataOut.direc2{iClus}.off.peak_fr= amp;
    dataOut.direc2{iClus}.off.latency = response_params_calc.latency_simple(...
        dataOut.direc1{iClus}.off.mean_fr(locMaxResponse,:), ...
        edges,'fit_spline', 'first_peak','min_fr', minLatencyFR);
    end


%%
x = [1: 6];
y = [1 2 4 5 4 2];


[Y, ySort ] = sort(y,'descend');
xdxActive = ySort(1:round(length(y)*1/3));
weightedY = zeros(1,length(y));
normVals = y(xdxActive)./sum(y(xdxActive));
weightedY(xdxActive) = normVals;

maxResponse = sum(weightedY.*x);

figure, plot(x,y,'g'); hold on
plot(maxResponse,0,'o','MarkerFaceColor', 'b')

%%
x = [1: 6];
y = [1 6 4 10 4 3 ];
yShift = y-min(y);
weightedY = yShift./sum(yShift);


maxResponse = sum(weightedY.*x);

figure, plot(x,y,'g'); hold on
plot(maxResponse,0,'o','MarkerFaceColor', 'b')

%% plot xyz plots

figure
idxCompare = [8 3 7]
scatter3(paraOutputMat.params(:, idxCompare(1)),paraOutputMat.params(:,idxCompare(2)),...
    paraOutputMat.params(:,idxCompare(3)), '.');


 xlabel(headingNames{idxCompare(1)}); 
 ylabel(headingNames{idxCompare(2)});
 zlabel(headingNames{idxCompare(3)});
 
 titleName = cells.concat_with_spacer(headingNames(idxCompare), ' vs ');
 title(titleName);
 
 dirNameFig = dirNames.common.clus_params;
fileNameFig = strrep(['param comparison ' titleName],' ','_');


save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
    'font_size_all', 13 );
 
  %%
 
 figure
[X,Y,Z] = sphere(16);
x = [0.5*X(:); 0.75*X(:); X(:)];
y = [0.5*Y(:); 0.75*Y(:); Y(:)];
z = [0.5*Z(:); 0.75*Z(:); Z(:)];
scatter3(x,y,z)



%%

colorMats = graphics.distinguishable_colors(100,[1 1 1]);

figure,
idxCompare = [   7 8  3]
x = paraOutputMat.params(:, idxCompare(1));
y = paraOutputMat.params(:, idxCompare(2));
z = paraOutputMat.params(:, idxCompare(3));

nanVals = union(union(find(isnan(x)),find(isnan(y))),find(isnan(z)))
goodVals = find(~ismember(1:length(z),nanVals));
zProp = round(normalize_values( z(goodVals),[1 99]));
    S = colorMats(zProp,:);
            scatter(x(goodVals),y(goodVals),25,S)

            figure, hold on
x = edges/2e4;
y = firingRateMean;
cs = spline(x,[0 y 0]);
xx = linspace(0,1,501);
fittedSpline = ppval(cs,xx);
plot(x,y,'o',xx,ppval(cs,xx),'-r');



%%
figure
xi = x/2e4;
q = @(x) x.^3;
yi = y;
randomStream = RandStream.create( 'mcg16807', 'Seed', 23 );
ybad = yi+.3*(rand(randomStream, size(xi))-.5);
p = .5;
xxi = (0:100)/100;
ys = csaps(xi,ybad,p,xxi);
plot(xi,yi,':',xi,ybad,'x',xxi,ys,'r-')
title('Clean Data, Noisy Data, Smoothed Values')
legend( 'Exact', 'Noisy', 'Smoothed', 'Location', 'NorthWest' )


%%

for iDir =1:length(dirNames.dataDirShort) % loop through directories
% eval(sprintf( '!mv /net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Roska/%s/marching_sqr_over_grid/dataOut.mat.old2  /net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Roska/%s/marching_sqr_over_grid/dataOut.mat',dirNames.dataDirShort{iDir}, dirNames.dataDirShort{iDir}))
 eval(sprintf( '!rm /net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Roska/%s/marching_sqr_over_grid/dataOut.mat.old' ,dirNames.dataDirShort{iDir}))
% eval(sprintf( '!cp  /net/bs-filesvr01/export/group/hierlemann/.zfs/snapshot/2015-02-02_0200/projects/retina_project/Roska/%s/marching_sqr_over_grid/dataOut.mat /net/bs-filesvr01/export/group/hierlemann/projects/retina_project/Roska/%s/marching_sqr_over_grid/dataOut.mat.old2',dirNames.dataDirShort{iDir}, dirNames.dataDirShort{iDir}))
    iDir
end


%%
idxExp = find(param_March_Sqr_Over_Grid.dir_num==4);

fieldName = 'latency';
fieldData = getfield(param_March_Sqr_Over_Grid,fieldName);
clusNums = getfield( param_March_Sqr_Over_Grid,'clus_num');

for i=1:length(idxExp)
    
    
   fprintf('%d\t%1.2f\n', clusNums(idxExp(i)), fieldData(idxExp(i)) )
    
end


