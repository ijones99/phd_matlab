%% plot all waveforms
h=figure, figs.scale(h,70,80); hold on, axis equal

% load footprintData.mat
waveforms = {};
iStim = 2;
numEls = 8;
idxToPlotBase = 1:2:35;
idxToPlot = {idxToPlotBase;...
    idxToPlotBase+36;...
    73:2:104}
idxToPlot{4}=idxToPlot{1}+1;
idxToPlot{5}=idxToPlot{2}+1;
idxToPlot{6}=idxToPlot{3}+1;

% file info
dirNameProf = '../analysed_data/profiles/';
fileNamesProf = filenames.list_file_names('clus*merg*.mat',dirNameProf);

for i=1:length(idxToPlot)
    subplot(1,6,i), axis equal, hold on
    % colors
    colorVals = graphics.distinguishable_colors(length(idxToPlot{i} ));
    
    % initial data
    load(fullfile(dirNameProf, fileNamesProf(1).name));
    
    % plot
    xLim = minmax(neurM(1).footprint.x);
    xSpc = mode(diff(unique(neurM(1).footprint.x)));
    
    yLim = minmax(neurM(1).footprint.y);
    ySpc = mode(diff(unique(neurM(1).footprint.y)));
    
    
    xlim(xLim+[-xSpc xSpc])
    ylim(yLim+[-ySpc ySpc]),
    plot(neurM(1).footprint.x,neurM(1).footprint.y,'s','Color',...
        ones(1,3)*0.5)%,'MarkerFaceColor',ones(1,3)*0.7
    
    
    plotCnt = 1:length(idxToPlot{i} );
    colorCnt =1;
    for iClus=idxToPlot{i}
        
        load(fullfile(dirNameProf, fileNamesProf(iClus).name));
        try
            rmsVal = median(rms(neurM(iStim).footprint.average(:,end-15:end),2));
            
            p2pVal = max(neurM(iStim).footprint.average,[],2)-...
                min(neurM(iStim).footprint.average,[],2);
            
            [Y,I] = sort(p2pVal,1,'descend')  ;
            plot_footprints_simple([neurM(iStim).footprint.x(I(1:numEls)) ...
                neurM(iStim).footprint.y(I(1:numEls))], neurM(iStim).footprint.average(I(1:numEls),:), ...
                'input_templates','hide_els_plot', 'plot_color',colorVals(colorCnt,:),...
                'line_width',2);
            colorCnt =1+colorCnt;
        catch
            waveforms{iClus} = [];
        end
    end
    figs.xticklabel_off;
    figs.yticklabel_off;
end