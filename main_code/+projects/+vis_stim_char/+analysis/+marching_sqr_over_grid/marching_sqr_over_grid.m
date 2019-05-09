% function marching_sqr_over_grid(dirName, idxFinalSel) 

load settings/stimParams_Marching_Sqr_over_Grid.mat
spikeTrains = {};
param_BiasIndex.stimName = 'stimParams_Marching_Sqr_over_Grid';

for iClus = 1:length(idxFinalSel.keep)
    clusNo = idxFinalSel.keep(iClus);
    fileNameProf = sprintf('clus_merg_%05.0f.mat',clusNo );
    load(fullfile(dirName.prof, fileNameProf));
    try
    spikeTrains{iClus}.ts = neurM(marchingSqrOverGridRIdx).ts;
    catch
        spikeTrains{iClus}.ts  = [];
    end
    spikeTrains{iClus}.clus = clusNo;
    param_BiasIndex.clus_num(end+1) = clusNo;
    
    param_BiasIndex.date{end+1} = expName;
    
end


dataOut = analysis.visual_stim.plot.plot_marching_sqr_over_grid_RF_input_spiketrains(...
    spikeTrains,Settings, ...
    stimChangeTs{marchingSqrOverGridRIdx},'post_switch_time_sec',0.95,'title',expName...
    , 'no_plot');

% get cell type count


idxCurr = (dataOut.total_spikes_ON-dataOut.total_spikes_OFF)./(dataOut.total_spikes_ON+dataOut.total_spikes_OFF);
param_BiasIndex.index(end+1:end+length(idxCurr)) = idxCurr;
param_BiasIndex.total_spikes_ON(end+1:end+length(idxCurr)) = dataOut.total_spikes_ON;
param_BiasIndex.total_spikes_OFF(end+1:end+length(idxCurr)) = dataOut.total_spikes_OFF;

dirName = '../analysed_data/params/';

save param_BiasIndex param_BiasIndex

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% plot RFs with merged cells
load settings/stimParams_Marching_Sqr_over_Grid.mat
spikeTrains = {};

dirNameProf = '../analysed_data/profiles/';
fileNamesProf = filenames.list_file_names('clus*merg*.mat',dirNameProf);

for iClus=1:length(fileNamesProf)

    load(fullfile(dirNameProf, fileNamesProf(iClus).name));
    
    
    spikeTrains{iClus}.ts = neurM(marchingSqrOverGridRIdx).ts;
    spikeTrains{iClus}.clus = currIdx;
end





dataOut = analysis.visual_stim.plot.plot_marching_sqr_over_grid_RF_input_spiketrains(...
    spikeTrains,Settings, ...
    stimChangeTs{marchingSqrOverGridRIdx},'post_switch_time_sec',0.95,'title',expName...
    )

%% get cell type count
h= figure;
figs.scale(h,50,80);

dataOut.paramONOFFIndex = (dataOut.total_spikes_ON-dataOut.total_spikes_OFF)./(dataOut.total_spikes_ON+dataOut.total_spikes_OFF);
save marchingSqrOverGrid_dataOut.mat dataOut

minNumSpikes = 20;
idxKeep = find(dataOut.keep > 0);
hist(dataOut.paramONOFFIndex(idxKeep),60)

title(['ON-OFF Indx Parameter - ' expName],'Interpreter', 'none')
xlabel('parameter value')
ylabel('cell count')

set(gca,'FontSize',16)
set(findall(gcf,'type','text'),'FontSize',16)

% FILE NAME
fileNameFig = 'on_off_params';
% fileNameFig = sprintf('speed_var_length_300_clus_%d', i, clusNum(i));

% DIR NAME
dirNameFig = '../Figs/marching_sqr_over_grid/';
mkdir(dirNameFig);

% SAVE
save.save_plot_to_file(dirNameFig, fileNameFig,{'fig','eps'});

%% Get receptive field size & center

doDebug = 0;

dataOut.RF_size = nan(1, length(dataOut.sta));
dataOut.RF_ctr_xy = nan(length(dataOut.sta),2);
stimRegEdgeLength = 900;

errorIdx = [];
for i=1:length(dataOut.keep)
    
    currIdx = i;
    
    try
        % For ON
        [xFitPercent yFitPercent zInterp fitData zInterpMask] = ...
            fit.find_rf_center_by_fitting_gaussian(...
            dataOut.sta(currIdx).imON   ,'mask_size_um',100);
        
        dataOut.ON.RF_interp = zInterp;
        
        % get RF size
        meanRmsVal = mean(rms(zInterp));
        idxAboveRMS = find(zInterp>meanRmsVal*3);
        rfAreaFract = length(idxAboveRMS)/(size(zInterp,1)*size(zInterp,2));
        dataOut.ON.RF_area_um_sqr(currIdx) = round(rfAreaFract*stimRegEdgeLength*stimRegEdgeLength);
        
        % get center location
        interpEdgeLength = size(zInterp,2);
        dataOut.ON.RF_ctr_xy(currIdx,1) = round(fitData.x_coord*stimRegEdgeLength/interpEdgeLength);
        dataOut.ON.RF_ctr_xy(currIdx,2) = round(fitData.y_coord*stimRegEdgeLength/interpEdgeLength);
        if doDebug
            h2 = figure
            imagesc(zInterp), hold on
            junk = input('enter >>');
            zInterpNew = zInterp;
            zInterpNew(idxAboveRMS) = max(max(zInterp));
            imagesc(zInterpNew)
            junk = input('enter >>');
        end
        
        % For OFF
        [xFitPercent yFitPercent zInterp fitData zInterpMask] = ...
            fit.find_rf_center_by_fitting_gaussian(...
            dataOut.sta(currIdx).imOFF   ,'mask_size_um',100);
        
        dataOut.OFF.RF_interp = zInterp;
        
        % get RF size
        meanRmsVal = mean(rms(zInterp));
        idxAboveRMS = find(zInterp>meanRmsVal*3);
        rfAreaFract = length(idxAboveRMS)/(size(zInterp,1)*size(zInterp,2));
        dataOut.OFF.RF_area_um_sqr(currIdx) = round(rfAreaFract*stimRegEdgeLength*stimRegEdgeLength);
        
        % get center location
        interpEdgeLength = size(zInterp,2);
        dataOut.OFF.RF_ctr_xy(currIdx,1) = round(fitData.x_coord*stimRegEdgeLength/interpEdgeLength);
        dataOut.OFF.RF_ctr_xy(currIdx,2) = round(fitData.y_coord*stimRegEdgeLength/interpEdgeLength);
        if doDebug
            h2 = figure
            imagesc(zInterp), hold on
            junk = input('enter >>');
            zInterpNew = zInterp;
            zInterpNew(idxAboveRMS) = max(max(zInterp));
            imagesc(zInterpNew)
            junk = input('enter >>');
        end
        
        if doDebug
            close(h2)
        end
    catch
        errorIdx(end+1) = currIdx;
    end
    
end
