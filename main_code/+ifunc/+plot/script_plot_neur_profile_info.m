Settings.DOT_DIAMETERS = [50   100   200   400   600   900];
onBrightness = 253;
neurNames = extract_neur_names_from_files('../analysed_data/profiles/All_Stim/','*.mat');
[selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);

for i=1:length(neurNames)
    
    data = load_profiles_file(neurNames{i},'use_sep_dir', 'All_Stim')
    
    h = figure;
    set(h, 'color', 'white')
    set(h,'Position', [1 1 1000 1200] )
    hold on
    %     load ../../27Nov2012/Matlab/MainFunctions/StimParams_SpotsIncrSize.mat
    load ../../21Aug2012/Matlab/StimCode/StimParams_SpotsIncrSize.mat
    
    % Max firing rate vs dot size
    sH = subplot(3,2,1);hold on
    ifunc.plot.flashing_dots.plot_max_firing_rate(data, ...
        Settings.DOT_DIAMETERS, onBrightness, [0 2e4],'plotArgs', {'Color', 'r','LineWidth',2})
    ifunc.plot.flashing_dots.plot_max_firing_rate(data, ...
        Settings.DOT_DIAMETERS, 0, [0 2e4],'plotArgs', {'Color', 'b','LineWidth',2})
    legend('ON', 'OFF')
    xlabel('Dot Diameter (um)','FontSize',14)
    ylabel('Max Firing Rate','FontSize',14)
    set(sH, 'FontSize', 14),
    title(sprintf('%s. Neuron %s: Response To Flashing Dots', get_dir_date, data.White_Noise.neurName),'FontSize',16)
    
    % DS plot for bars
    %     load ../../27Nov2012/Matlab/MainFunctions/StimParams_Bars.mat
    load ../../21Aug2012/Matlab/StimCode/StimParams_Bars.mat
    sH = subplot(3,2,2);
    Settings.BAR_BRIGHTNESS = [202; 112];
    ifunc.plot.moving_bars.plot_polar_for_moving_bars(data, Settings, 'off')
    title('Directional Response To Moving Bars','FontSize',16)
    set(sH, 'FontSize', 14)
    
    % Rasters vs. diff. dot size
    load ../../21Aug2012/Matlab/StimCode/StimParams_SpotsIncrSize.mat
    % Max firing rate vs dot size
    sH = subplot(3,2,[3 5]);
    ifunc.plot.flashing_dots.plot_raster_dots(data,...
        'drawStimSepLines', 1,'stimLims',[0 1]);
    set(sH, 'FontSize', 14)
    title('Raster Plot of Responses to Flashing Dots','FontSize',16)
    xlabel('Time (sec)','FontSize',14)
    
    
    % plot footprints
    sH = subplot(3,2,4);
    plotMedianPlotArgs =   {'-', 'color', 'g', 'linewidth', 2}
    ifunc.plot.footprints.plot_footprint_median(data.Moving_Bars.footprint_median,...
        hdmea.MultiElectrode.electrodePositions,118, 'excludeEls', elsToExcludeIdx,'axesHandle', sH, ...
        'plotMedianPlotArgs', plotMedianPlotArgs);
    plotMedianPlotArgs =   {'-', 'color', 'm', 'linewidth', 2}
    ifunc.plot.footprints.plot_footprint_median(data.Flashing_Dots.footprint_median,...
        hdmea.MultiElectrode.electrodePositions,118, 'excludeEls', elsToExcludeIdx,'axesHandle', sH,...
        'plotMedianPlotArgs', plotMedianPlotArgs);
    
    ifunc.plot.footprints.plot_footprint_median(data.White_Noise.footprint_median,...
        hdmea.MultiElectrode.electrodePositions,118, 'excludeEls', elsToExcludeIdx,'axesHandle', sH);
    axis square
%     legend({'Moving_Bars', 'Flashing_Dots', 'White Noise Checkerboard'});
    title('RGC Spike Triggered Average','FontSize',16)
    
    % plot STA
    % get min and max indices for sta frames
    % min & max
    sH = subplot(3,2,6);
    [staVal(1) indSTAFr(1)] = min(data.White_Noise.sta_temporal_plot.staIms - median(data.White_Noise.sta_temporal_plot.staIms));
    [staVal(2) indSTAFr(2)] = max(data.White_Noise.sta_temporal_plot.staIms - median(data.White_Noise.sta_temporal_plot.staIms));
    %     bestSTAInd = find(max([rms(data.White_Noise.sta_temporal_plot.staIms(indSTAFr(1))) ...
    %         rms(data.White_Noise.sta_temporal_plot.staIms(indSTAFr(1))) ]));
    [junk, bestSTAInd ]= max(abs(staVal));
    
    selIm = data.White_Noise.sta(:,:,indSTAFr(bestSTAInd)); selIm = (imrotate(flipud(selIm),-90));
    imagesc(selIm); axis square, axis off, hold on
    circle([data.White_Noise.plot_info.imWidth/2+1.5 data.White_Noise.plot_info.imWidth/2+1.5],...
        (data.White_Noise.plot_info.imWidth*...
        data.White_Noise.plot_info.apertureDiam/data.White_Noise.plot_info.stimWidth)/2,...
        data.White_Noise.plot_info.imWidth,'k--',2);
    title('RGC Footprint','FontSize',16)
    dirName.finalNeurProf = '../Figs/Final_Neur_Profiles/';
    if ~exist(dirName.finalNeurProf,'dir')
        mkdir( dirName.finalNeurProf  );
    end
    saveas(h,sprintf('%sneurProfile_%s.fig',  dirName.finalNeurProf,neurNames{i}),'fig');
%     saveas(h,sprintf('%sneurProfile_%s.png',  dirName.finalNeurProf,neurNames{i}), 'png');
    
    exportfig(h, sprintf('%sneurProfile_%s.eps',  dirName.finalNeurProf,neurNames{i}) ,'Resolution', 120,...
        'Color', 'cmyk', 'format','eps');
%     close(h)
    %     catch
    %         fprintf('Error with %d\n', i)
    %     end
    
end
