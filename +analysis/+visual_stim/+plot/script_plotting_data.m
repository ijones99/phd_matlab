% script_plotting_data.m

%% select names
paramClusIdx = 3;
paraClustering.neur_names(find(paraClustering.clusterAssigns == paramClusIdx))  

%% load neur
pathDef = dirdefs();
neur = {};
for i=1:length(paraClustering.neur_names)
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


figure, imagesc(all.profData{idxClusProfData}.staImAdj), axis square

%% plot FR vs spot diam
figure
analysis.visual_stim.plot.neur.plot_spot_diameter_vs_peak_fr(neur,clusNo)

%% Plot best response to spot
figure
sptSize = neur.spt.pref_diam;
sptOnOff = neur.spt.pref_brightness;
if strcmp(sptOnOff,'on')
    idx = intersect(find(neur.spt.settings.rgb>0),find(neur.spt.settings.dotDiam==sptSize));
else
    idx = intersect(find(neur.spt.settings.rgb==0),find(neur.spt.settings.dotDiam==sptSize));
end

spiketrainCell = neur.spt.spikeTrains(idx);
[firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_from_psth(spiketrainCell,[0 2*2e4]);
plot(edges, firingRate)

%% plot space time
figure
analysis.visual_stim.plot.neur.plot_space_time_plot(neur,clusNo,1);
figure
analysis.visual_stim.plot.neur.plot_space_time_plot(neur,clusNo,2);
%% plot DS
figure
polarPlotColors = {'r','k'};
polarStimType = {'ON', 'OFF'};
angleVectorsOnChip = neur.mb.ds.angles;
peakFRNorm= neur.mb.ds.peak_fr_norm;
plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(1,:),'line_style',polarPlotColors{ones(1,8)},...
    'no_normalization');hold on
plot_polar_for_ds(angleVectorsOnChip, peakFRNorm(2,:),'line_style',polarPlotColors{2*ones(1,8)},...
    'no_normalization');

%% plot STA timecourse

figure,
plot(neur.sta.staTemporalPlot.x_axis, neur.sta.staTemporalPlot.staIms)


    

