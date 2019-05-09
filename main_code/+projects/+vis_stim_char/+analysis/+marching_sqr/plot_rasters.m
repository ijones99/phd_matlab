function plot_rasters(dataOut, idxClusDataOut)
% PLOT_RASTERS(dataOut)

% settings
postSwitchTime_sec = 1;

% load all settings and data
load settings/stimParams_Marching_Sqr.mat
load settings/stimFrameInfo_marchingSqr.mat
script_load_data

% get dir names
dirNames = projects.vis_stim_char.analysis.load_dir_names;

idxAll = [[1:2:length(stimFrameInfo.pos)*2]' [2:2:length(stimFrameInfo.pos)*2]'];

[junk, idxOnInfo] = sort(stimFrameInfo.pos(1:end/2,2));
idxOnAll = reshape(idxAll(idxOnInfo,:),1,2*length(idxOnInfo));
[junk, idxOffInfo] = sort(stimFrameInfo.pos(end/2+1:end,1));
idxOffAll = reshape(idxAll(idxOffInfo,:),1,2*length(idxOffInfo));


h=figure;
figs.maximize(h);
subplotEdge = subplots.find_edge_numbers_for_square_subplot(length(idxClusDataOut));

for iClus=1:length(idxClusDataOut)
    subplots.subplot_tight(subplotEdge(1),subplotEdge(2),iClus,0.01);
    figs.xticklabel_off, figs.yticklabel_off
    hold on

    plot.raster_from_cells(dataOut.segmentsAdj{idxClusDataOut(iClus)}(idxOnAll),...
        'offset', 0.8,'height', 0.5, 'color','k','x_axis_scale_factor',1/2e4)
    xlim([0 2e4*2])
    
    plot.raster_from_cells(dataOut.segmentsAdj{idxClusDataOut(iClus)}(idxOffAll),...
        'offset', 0.8,'height', 0.5, 'color','r',...
        'offset_idx',length(idxClusDataOut)*2,'x_axis_scale_factor',1/2e4)
   
    xlim([0 3])
    ylim([0 length(idxClusDataOut)*4])
    
    shg
end













end