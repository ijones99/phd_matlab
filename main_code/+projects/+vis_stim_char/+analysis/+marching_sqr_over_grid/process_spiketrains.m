function dataOut = process_spiketrains(selClusIdx, varargin)

% load all settings and data
load settings/stimParams_Marching_Sqr_over_Grid.mat

script_load_data
noPlot = 0;
dataOut = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'no_plot')
            noPlot  =1;
        elseif strcmp( varargin{i}, 'dataOut')
            dataOut = varargin{i+1};
        
        
        end
        
    end
end


% get dir names
dirNames = projects.vis_stim_char.analysis.load_dir_names;

spikeTrains = {};

for iClus=1:length(selClusIdx)

       filenameProf = sprintf('clus_merg_%05.0f', selClusIdx(iClus));
    load(fullfile(dirNames.prof, filenameProf))
    
    spikeTrains{iClus}.ts = neurM(marchingSqrOverGridRIdx).ts;
    spikeTrains{iClus}.clus =selClusIdx(iClus);
end

if noPlot
    if isempty(dataOut)
        % calculate parameters: latency, transience, etc.
        dataOut = analysis.visual_stim.plot.plot_marching_sqr_over_grid_RF_input_spiketrains(...
            spikeTrains,Settings, ...
            stimChangeTs{marchingSqrOverGridRIdx},'post_switch_time_sec',0.95,'title',expName...
            ,'no_plot') ;
    else
        dataOut = analysis.visual_stim.plot.plot_marching_sqr_over_grid_RF_input_spiketrains(...
            spikeTrains,Settings, ...
            stimChangeTs{marchingSqrOverGridRIdx},'post_switch_time_sec',0.95,'title',expName...
            ,'no_plot','dataOut',dataOut);
        
    end
else
    if isempty(dataOut)
        dataOut = analysis.visual_stim.plot.plot_marching_sqr_over_grid_RF_input_spiketrains(...
            spikeTrains,Settings, ...
            stimChangeTs{marchingSqrOverGridRIdx},'post_switch_time_sec',0.95,'title',expName);
    else
        dataOut = analysis.visual_stim.plot.plot_marching_sqr_over_grid_RF_input_spiketrains(...
            spikeTrains,Settings, ...
            stimChangeTs{marchingSqrOverGridRIdx},'post_switch_time_sec',0.95,'title',expName...
            ,'dataOut',dataOut);
    end
end


end