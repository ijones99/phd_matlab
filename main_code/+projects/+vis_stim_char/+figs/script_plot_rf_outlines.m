% plot outline of RFs
minMaxSz = [ 0 1];
allPercentCoverage = [];
load ../analysed_data/marching_sqr_over_grid/dataOut.mat
onVsOff = dataOut.total_spikes_ON > dataOut.total_spikes_OFF;
colorMats = graphics.distinguishable_colors(length(idxFinalSel.keep),[1 1 1]);

i = 1;
filenameProf = sprintf('clus_merg_%05.0f', selClus(i));
load(fullfile(dirNameProf, filenameProf));

for i=1:104%length(dataOut.clus_no)
    
    idxCurr = dataOut.clus_idx(i);
    if onVsOff(idxCurr)
        savedIm = dataOut.ON.RF_interp{i};
    else
        savedIm = dataOut.OFF.RF_interp{i};
    end
    
    savedImChip = beamer.beamer2array_mat_adjustment(savedIm);
    currIm = interp2(savedImChip ,3);
    
    bwRF = im.threshold(currIm,'thresh_val', max(max(currIm))*0.4);
    currPercentCoverage = 2*sqrt(length(find(bwRF>0))/pi)/size(bwRF,1);
    allPercentCoverage(i) = currPercentCoverage ;
    if  currPercentCoverage > minMaxSz(1) & currPercentCoverage < minMaxSz(2)
        currPercentCoverage
        bContour = im.draw_outline_of_bw_shape(currIm,'color', colorMats(i,:));
    end
    
    % plot electrodes
    if i==1
        figure, hold on, axis equal
        elLocOrig.x = neurM(idxStim).footprint.x; elLocOrig.y = neurM(idxStim).footprint.y;
        elLocCtrdNull.x = elLocOrig.x - mean(unique(elLocOrig.x)); elLocCtrdNull.y = elLocOrig.y - mean(unique(elLocOrig.y));
        
        htMEA = abs(diff(minmax(elLocOrig.y)));
        
        scaleFac = (htMEA - (htMEA/900*size(currIm,1)))/htMEA;
        
        elLocScal.x = elLocCtrdNull.x*scaleFac; elLocScal.y = elLocCtrdNull.y*scaleFac;
        
        elLocCtrd.x = elLocScal.x + size(currIm,1)/2;
        elLocCtrd.y = elLocScal.y + size(currIm,1)/2;
        
        plot(elLocCtrd.x,elLocCtrd.y,'ks','LineWidth',1,'MarkerFaceColor',[.5 .5 .5]), axis equal
    end
    
    

    %     subplot(1,2,1)
    %     imagesc(dataOut.ON.RF_interp{i});
    %     subplot(1,2,2)
    %     imagesc(bwRF);
    
    %     myfilter = fspecial('gaussian',[3 3], 0.5);
    %     myfilteredimage = imfilter(bwRF, myfilter, 'replicate');
        
%         junk = input('enter > ')
end
expName = get_dir_date;
titleName = ['Receptive Fields - ', expName];
dirNameFig = '../analysed_data/Figures/receptive_fields/';
fileNameFig = 'rf_outlines';
figs.font_size(8)
figs.line_width(1)
figs.format_for_pub('journal_name','frontiers',  'plot_dims',[8 8])
figs.save_for_pub(fullfile(dirNameFig, fileNameFig))
% save.save_plot_to_file(dirNameFig, fileNameFig,{'fig', 'eps', 'pdf','ps'},...debian
%      'font_size_all', 13 , ...
%            'sup_title', titleName);