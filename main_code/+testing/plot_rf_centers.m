
idxStim = 1;
dirNameProf = '../analysed_data/profiles/';

% load data
load idxFinalSel
script_load_data

selClus = idxFinalSel.keep;

% radius = amplitude
for i=1:200%length(selClus)
    
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf));
    if i==1
        figure, hold on
        plot(neurM(idxStim).footprint.x,neurM(idxStim).footprint.y,'ks','LineWidth',1,'MarkerFaceColor',[.5 .5 .5]), axis equal
    end
    
    waveforms = neurM(idxStim ).footprint.median;
    xyCoord = [neurM(idxStim ).footprint];
    
    amps = max(waveforms,[],2)'-min(waveforms,[],2)';
    ctrLoc = footprint.find_center_with_contour(xyCoord.x, xyCoord.y, amps);
    
    %     plot.plot_xyz_data(xyCoord.x, xyCoord.y, amps,'n_contour_lines', 10);
    plot.circle2(ctrLoc.x, ctrLoc.y, 20*max(amps)/1000, 'MarkerEdgeColor',[.5 .5 .5], 'LineWidth', 1,...
        'EdgeColor','r','FaceColor','c');
    %     ju = input(' > ')
    
end
expName =get_dir_date;
dirNameFig = dirNames.local.figs.marching_sqr_over_grid;
fileNameFig = 'rgc_locations_amps_in_radius';
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
     'font_size_all', 13 , ...
      'sup_title', ['RGC Locations -  ',expName ]);

%% color = amp

colorMats = graphics.distinguishable_colors(100,[1 1 1]);

for i=1:150%length(selClus)
    
    filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
    load(fullfile(dirNameProf, filenameProf));
    if i==1
        figure, hold on
        plot(neurM(idxStim).footprint.x,neurM(idxStim).footprint.y,'ks','LineWidth',1,'MarkerFaceColor',[.5 .5 .5]), axis equal
    end
    
    waveforms = neurM(idxStim ).footprint.median;
    xyCoord = [neurM(idxStim ).footprint];
    
    amps = max(waveforms,[],2)'-min(waveforms,[],2)';
    ctrLoc = footprint.find_center_with_contour(xyCoord.x, xyCoord.y, amps);
    
    %     plot.plot_xyz_data(xyCoord.x, xyCoord.y, amps,'n_contour_lines', 10);
    idxColor = round(max(amps)/10);
    plot.circle2(ctrLoc.x, ctrLoc.y, 7, 'MarkerEdgeColor',[.5 .5 .5], 'LineWidth', 1,...
        'EdgeColor','r','FaceColor',colorMats(idxColor ,:));
    %     ju = input(' > ')
    
end
expName =get_dir_date;
dirNameFig = dirNames.local.figs.marching_sqr_over_grid;
fileNameFig = 'rgc_locations_amps_in_color';
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
     'font_size_all', 13 , ...
      'sup_title', ['RGC Locations -  ',expName ]);
%%
[I J] = find( zi == max(max(zi)))
ctrLoc.x = xi(I,J)
ctrLoc.y = yi(I,J)
plot(ctrLoc.x,ctrLoc.y,'kx','LineWidth',3)