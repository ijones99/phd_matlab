
plotON = 1;
if plotON 
    iRgb=2;
else
    iRgb=1;
end

iLength=1, iWidth=1, iSpeed=2,
h=figure
figs.maximize(h)
dirVals = [0:45:350];
dirNames = projects.vis_stim_char.analysis.load_dir_names;
for iDir =1:length(dirNames.dataDirLong) % loop through directories
    clf
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load ../analysed_data/moving_bar_ds/dataOut.mat
    
    % load stim params
    stimFrameInfo = file.load_single_var('settings/',...
        'stimFrameInfo_Moving_Bars_ON_OFF.mat');
    
    offsetsUnique = unique(stimFrameInfo.offset );
    rgbsUnique = unique(stimFrameInfo.rgb);
    lengthsUnique = unique(stimFrameInfo.length);
    widthsUnique = unique(stimFrameInfo.width);
    speedsUnique = unique(stimFrameInfo.speed);
    anglesUnique = unique(stimFrameInfo.angle); % input angles (algorithm)
    
    anglesOnScreen = psychtoolbox.angle_transfer_function(anglesUnique); % angles as seen on screen
    [Y, idxOnScrAngle] = sort(anglesOnScreen); % idxOnScrAngle is index for responses to angles
    %     idxOnScrAngle = 1:8;
    xx = load('../analysed_data/marching_sqr_over_grid/dataOut.mat');
    
    subplotEdges = subplots.find_edge_numbers_for_square_subplot(104);
    onOffBias = [];
    paramOut = [];
    for iClus = 1:length(dataOut.clus_num)
        
        % select location of either on or off cells.
        if xx.dataOut.total_spikes_ON(iClus) > xx.dataOut.total_spikes_OFF(iClus)
            onOffBias(iClus) = 2;
            rfCtrLocRel = xx.dataOut.ON.RF_ctr_xy(iClus,:);
        else
            onOffBias(iClus) = 1;
            rfCtrLocRel = xx.dataOut.OFF.RF_ctr_xy(iClus,:);
        end
         d = geometry.get_distance_between_2_points(rfCtrLocRel(:,1),rfCtrLocRel(:,2),0,0);
        
        closestOffset  = projects.vis_stim_char.ds.find_offset_positions_closest_to_point(...
            anglesUnique, offsetsUnique, rfCtrLocRel);
  
        subplot(subplotEdges(1),subplotEdges(2), iClus);
        for iOffset = 1:size(closestOffset,1)
            yVals(iOffset) = squeeze(dataOut.meanFR{iClus}(closestOffset(iOffset,3),...
                iRgb, iLength, iWidth, iSpeed, idxOnScrAngle(iOffset)));
            yStd(iOffset) = squeeze(dataOut.stdFR{iClus}(closestOffset(iOffset,3), ...
                iRgb, iLength, iWidth, iSpeed, idxOnScrAngle(iOffset)));
        end
        
        %         yValsPlot = yVals/max(yVals)*100;
        %         yStdPlot = yStd/max(yStd)*100;
        yValsPlot = yVals;%;-min(yVals);
        yStdPlot = yStd;
        r(iClus) =  response_params_calc.ds(dirVals, yValsPlot,'min_thr',20);
        errorbar( [ dirVals], yValsPlot([1:8]),yStdPlot([1:8]  ));
%         plot_polar_for_ds([ dirVals], yValsPlot([1:8]));
        set(gca,'XTick',[]);
        ylim([-20 180])
        xlim([-10 370])
        title(sprintf('%0.2f',r(iClus) ));
    end
    
    suptitle(['DS Response - ', strrep(dirNames.dataDirShort{iDir},'_','-')])
    
    !mkdir ../Figs/moving_bars_ds
    if plotON
        dirNameFig = '../Figs/moving_bars_ds';
    else
        dirNameFig = '../Figs/moving_bars_ds_OFF';
    end
    fileNameFig = sprintf('ds_response_%s',dirNames.dataDirShort{iDir});
    supTitle = ['DS Response - ', strrep(dirNames.dataDirShort{iDir},'_','-'),' (peak FR vs angle)'];
    
%         save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
%             'font_size_all', 13 , ...
%             'sup_title', supTitle, 'force_overwrite');
    xx = input('enter >>')
end



%%

iOffset=3, iRgb=2, iLength=1, iWidth=1, iSpeed=2,
h=figure
figs.maximize(h)
dirVals = [0:45:350];
dirNames = projects.vis_stim_char.analysis.load_dir_names;
for iDir =1:length(dirNames.dataDirLong) % loop through directories
    clf
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load ../analysed_data/moving_bar_ds/dataOut.mat
    
    % load stim params
    stimFrameInfo = file.load_single_var('settings/',...
        'stimFrameInfo_Moving_Bars_ON_OFF.mat');
    
    offsetsUnique = unique(stimFrameInfo.offset );
    rgbsUnique = unique(stimFrameInfo.rgb);
    lengthsUnique = unique(stimFrameInfo.length);
    widthsUnique = unique(stimFrameInfo.width);
    speedsUnique = unique(stimFrameInfo.speed);
    anglesUnique = unique(stimFrameInfo.angle);
    
    anglesOnChip = beamer.beamer2chip_angle_transfer_function_v2(anglesUnique);
    [Y, idxOnScrAngle] = sort(anglesOnChip )
    
    xx = load('../analysed_data/marching_sqr_over_grid/dataOut.mat');
    
    %     length(dataOut.clus_num)
    subplotEdges = subplots.find_edge_numbers_for_square_subplot(104);
    onOffBias = [];
    paramOut = [];
    
   
    
    for iOffset = 1:3
        iClus = selClusNum
        % select location of either on or off cells.
        if xx.dataOut.total_spikes_ON(iClus) > xx.dataOut.total_spikes_OFF(iClus)
            onOffBias(iClus) = 2;
            rfCtrLocRel = xx.dataOut.ON.RF_ctr_xy(iClus,:);
        else
            onOffBias(iClus) = 1;
            rfCtrLocRel = xx.dataOut.OFF.RF_ctr_xy(iClus,:);
        end
        %          d = geometry.get_distance_between_2_points(rfCtrLocRel(:,1),rfCtrLocRel(:,2),0,0);
        
        %         closestOffset  = projects.vis_stim_char.ds.find_offset_positions_closest_to_point(...
        %             anglesUnique, offsetsUnique, rfCtrLocRel);
        closestOffset = ones(8,3)*iOffset;
        subplot(subplotEdges(1),subplotEdges(2), iOffset);
        for iOffset = 1:size(closestOffset,1)
            
            yVals(iOffset) = squeeze(dataOut.meanFR{iClus}(closestOffset(iOffset,3), iRgb, iLength, iWidth, iSpeed, idxOnScrAngle(iOffset)));
            yStd(iOffset) = squeeze(dataOut.stdFR{iClus}(closestOffset(iOffset,3), iRgb, iLength, iWidth, iSpeed, idxOnScrAngle(iOffset)));
        end
        yValsOffset = yVals-min(yVals);
        errorbar( [ dirVals], yValsOffset([1:8]),yStd([1:8]  ));
        set(gca,'XTick',[]);
        ylim([-20 180])
        xlim([-10 370])
        title(num2str(round(d)));
    end
    
    suptitle(['DS Response - ', strrep(dirNames.dataDirShort{iDir},'_','-')])
    
    !mkdir ../Figs/moving_bars_ds
    dirNameFig = '../Figs/moving_bars_ds_OFF';
    fileNameFig = sprintf('ds_response_%s',dirNames.dataDirShort{iDir});
    supTitle = ['DS Response - ', strrep(dirNames.dataDirShort{iDir},'_','-'),' (peak FR vs angle)'];
%     
%     save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...
%         'font_size_all', 13 , ...
%         'sup_title', supTitle, 'force_overwrite');
xx = input('enter >>')
end
