% script_plotting_data.m

%% select names
paramClusIdx = 3;
paraClustering.neur_names(find(paraClustering.clusterAssigns == paramClusIdx))

%% load neur
pathDef = dirdefs();
neur = {};
for i=3:length(paraClustering.neur_names)
    neur{i} = file.load_single_var(pathDef.neuronsSaved,paraClustering.neur_names{i});
    i
end

%% plot STA

load all_1
load refClusInfo
load refClusCtrLoc.mat
figure
clusNo = 115;

idxClusProfData = cells.cell_find_number_in_field(all.profData,'clusNum',clusNo);

figure, imagesc(all.profData{idxClusProfData}.staImAdj), axis square
%% plot STA

selNeur = 1;
figure, imagesc(neur{selNeur}.sta.staImAdj),axis square

%% plot FR vs spot diam
figure
analysis.visual_stim.plot.neur.plot_spot_diameter_vs_peak_fr(neur{selNeur},neur{selNeur}.info.clus_no)

%% Plot best response to spot
figure
sptSize = neur{selNeur}.spt.pref_diam;
sptOnOff = neur{selNeur}.spt.pref_brightness;
if strcmp(sptOnOff,'on')
    idx = intersect(find(neur{selNeur}.spt.settings.rgb>0),find(neur{selNeur}.spt.settings.dotDiam==sptSize));
else
    idx = intersect(find(neur{selNeur}.spt.settings.rgb==0),find(neur{selNeur}.spt.settings.dotDiam==sptSize));
end

spiketrainCell = neur{selNeur}.spt.spikeTrains(idx);
[firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_from_psth(spiketrainCell,[0 2*2e4]);
plot(edges, firingRate)

%% plot space time
figure
analysis.visual_stim.plot.neur.plot_space_time_plot(neur{selNeur},neur{selNeur}.info.clus_no,1);
figure
analysis.visual_stim.plot.neur.plot_space_time_plot(neur{selNeur},neur{selNeur}.info.clus_no,2);
%% plot DS
figure
polarPlotColors = {'r','k'};
polarStimType = {'ON', 'OFF'};
angleVectorsOnChip = neur{selNeur}.mb.ds.angles;
peakFRNorm= neur{selNeur}.mb.ds.peak_fr_norm;
plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(1,:),'line_style',polarPlotColors{ones(1,8)},...
    'no_normalization');hold on
plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(2,:),'line_style',polarPlotColors{2*ones(1,8)},...
    'no_normalization');

%% plot STA timecourse

figure,
plot(neur{selNeur}.sta.staTemporalPlot.x_axis, neur{selNeur}.sta.staTemporalPlot.staIms)

%% plot all
subPRows = 3;
subPCols = 4;
expName = input('exp name >>','s');
% analysis purpose
functionOpts = {'plot_all', 'review_plots'};
fprintf('Purpose of plotting?\n')
for i=1:length(functionOpts)
   fprintf('(%d) %s\n', i, functionOpts{i}) 
end
functionOptsSel = input('Select number (above) >> ');

for selNeur = 1:length(neur)
    try
        footprintCtr.x = mean(neur{selNeur}.footprint.x);
        footprintCtr.y = mean(neur{selNeur}.footprint.y);
        h=figure, figs.scale(h, 75,100)
        iSub = 1; subplot(subPRows,subPCols,iSub); iSub = iSub+1;
        imagesc(neur{selNeur}.sta.staImAdj),axis square, colorbar
        title('Receptive Field')
        
        yticklabels = linspace(75,900,12);
        yticks = 1:length(yticklabels);
        xticklabels = num2str(yticklabels');
        xticklabels(1:2:end,:) = ' ';
        xticks = yticks ;
        
        set(gca, 'YTick', yticks, 'YTickLabel', yticklabels,...
            'XTick', xticks, 'XTickLabel', xticklabels)
        
        
        % plot FR vs spot diam
        subplot(subPRows,subPCols,iSub); iSub = iSub+1; hold on; title('FR vs spot diam')
        analysis.visual_stim.plot.neur.plot_spot_diameter_vs_peak_fr(neur{selNeur},neur{selNeur}.info.clus_no)
        axis square
        
        % plot FR vs spot diam
        subplot(subPRows,subPCols,iSub); iSub = iSub+1; hold on; title('Spikecount vs spot diam')
        analysis.visual_stim.plot.neur.plot_spot_diameter_vs_spikecount(neur{selNeur},neur{selNeur}.info.clus_no)
        axis square
        
        % Plot response to preferred spot
        subplot(subPRows,subPCols,7);  hold on;title('response to preferred spot')
        sptSize = neur{selNeur}.spt.pref_diam;
        sptOnOff = neur{selNeur}.spt.pref_brightness;
        if strcmp(sptOnOff,'on')
            idx = intersect(find(neur{selNeur}.spt.settings.rgb>0),find(neur{selNeur}.spt.settings.dotDiam==sptSize));
        else
            idx = intersect(find(neur{selNeur}.spt.settings.rgb==0),find(neur{selNeur}.spt.settings.dotDiam==sptSize));
        end
        axis square
        
        spiketrainCell = neur{selNeur}.spt.spikeTrains(idx);
        [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_from_psth(spiketrainCell,[0 2*2e4]);
        plot(edges/2e4, firingRate)
        
        % plot DS
        subplot(subPRows,subPCols,4);  title('DS Response')
        polarPlotColors = {'r','k'};
        polarStimType = {'ON', 'OFF'};
        angleVectorsOnChip = neur{selNeur}.mb.ds.angles;
        peakFRNorm= neur{selNeur}.mb.ds.peak_fr_norm;
        
        polarPlotOrder = [1 2; 2 1];
        
        [polarPlotOrderIdx,J] = find(peakFRNorm==1,1);
        
        polarPlotIdx = polarPlotOrder(polarPlotOrderIdx,1);
        plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(polarPlotIdx,:),'line_style',polarPlotColors{polarPlotIdx*ones(1,8)},...
            'no_normalization');hold on
        polarPlotIdx = polarPlotOrder(polarPlotOrderIdx,2);
        plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(polarPlotIdx,:),'line_style',polarPlotColors{polarPlotIdx*ones(1,8)},...
            'no_normalization');
        axis square
        
        % plot footprint
        subplot(subPRows,subPCols,5);
        plot_footprints_simple([neur{selNeur}.footprint.x neur{selNeur}.footprint.y], ...
            neur{selNeur}.footprint.average, 'input_templates','hide_els_plot', 'plot_color','b');
        % add center info
        %         RF  center
        hold on
        RFCtr.x = footprintCtr.x + neur{selNeur}.sta.rfRelCtr(1);
        RFCtr.y = footprintCtr.y - neur{selNeur}.sta.rfRelCtr(2);
        p2p = max(neur{selNeur}.footprint.average,[],2) -  min(neur{selNeur}.footprint.average,[],2);
        [Y I] = max(p2p);
        maxP2PLoc.x = neur{selNeur}.footprint.x(I);
        maxP2PLoc.y = neur{selNeur}.footprint.y(I);
        plot(RFCtr.x, RFCtr.y,'ro')
        plot(maxP2PLoc.x, maxP2PLoc.y,'co')
        
        
        
        title('Footprint')
        axis equal
        
        subplot(subPRows,subPCols,6); title('Spots Response Raster')
        analysis.visual_stim.plot.neur.plot_spot_raster_all_sizes_one_pane(neur{selNeur});
        title('Spot Response')
        
        subplot(subPRows,subPCols,8); title('Spots Response Raster')
        analysis.visual_stim.plot.neur.plot_mb_raster_all_sizes_one_pane(neur{selNeur});
        title('DS Response')
        
        iSub=9;
        % plot STA timecourse
        subplot(subPRows,subPCols,iSub); iSub = iSub+1; hold on; title('STA timecourse')
        plot(neur{selNeur}.sta.staTemporalPlot.x_axis, neur{selNeur}.sta.staTemporalPlot.staIms)
        axis square
        
        %plot space time
        subplot(subPRows,subPCols,iSub); iSub = iSub+1;
        analysis.visual_stim.plot.neur.plot_space_time_plot(neur{selNeur},neur{selNeur}.info.clus_no,2);
        title('Space Time: To Right Along X')
        
        subplot(subPRows,subPCols,iSub); iSub = iSub+1;
        analysis.visual_stim.plot.neur.plot_space_time_plot(neur{selNeur},neur{selNeur}.info.clus_no,1);
        title('Space Time: Down Y')
        
        %
        % dirName = '~/Desktop/Temp_08Oct2014_Plots/';
        % save.save_plot_to_file(dirName, strrep(strrep(paraClustering.neur_names{selNeur},'08Oct2014/',''),'.mat',''),'fig',...
        %     'fig_h',h)
        
        subplot(subPRows,subPCols,iSub)
        paramFlds = structs.fields_to_cell(neur{selNeur}.paramOut,'strrep_char', '-');
        text(0.1,0.5,paramFlds,'FontSize', 14)
        title('Parameters')
        axis off
        
        suptitle(strrep(sprintf('Neuron Profile for Exp %s, Cluster # %d', expName, neur{selNeur}.info.clus_no),'_','-'));
        %         keepSel= input('keep? [k] >> ','s')
        if functionOptsSel==1
            % add info for quality control
            clusNoStr = sprintf('clus_%d.mat',neur{selNeur}.info.clus_no);
            paraOutMatIdx = cells.cell_find_str2( paraOutputMat.neur_names,{expName clusNoStr},'two_and_exp');
            paraOutputMat.quality_control(paraOutMatIdx) = 1;
            
            fileName = strrep(paraOutputMat.neur_names{paraOutMatIdx},'.mat','');
            % save fig
            dirProfileFig = '~/ln/vis_stim_hamster/plots/neuron_profiles/';
            save.save_plot_to_file(dirProfileFig, fileName,{'fig'});
            
        elseif functionOptsSel==2   
            junk = input('Hit enter >> ')
        end
    end
    close all
    
    
end
