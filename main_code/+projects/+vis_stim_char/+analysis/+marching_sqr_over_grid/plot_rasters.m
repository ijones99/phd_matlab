function dataOut = plot_rasters(dataOut, varargin)

script_load_data
idxStim = marchingSqrOverGridRIdx;
selClus = 1:length(dataOut.keep);


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'fig')
            h = varargin{i+1};
        end
    end
end


% load stim params
stimFrameInfo = file.load_single_var('settings/',...
    'stimFrameInfo_Moving_Bars_ON_OFF.mat');
plotColor = 'k';
h = [];

if ~isempty(h)
    figs.maximize(h);
end


subplotEdges = subplots.find_edge_numbers_for_square_subplot(...
    length(selClus));



% selClus=selClus(10:20);warning('truncated data')
subplotCnt=1;
for i=1:length(selClus)
    if dataOut.keep(i)
        subplot(subplotEdges(1),subplotEdges(2),subplotCnt)
        for iT = 1:length(dataOut.spikecount_at_ctr_ON{i})
            plot.raster2(dataOut.spikecount_at_ctr_ON{i}{iT}/2e4,'color','r','height',0.75,'offset', iT,'ylim',[0 11],'xlim',[-0.5 1])
        end
        for iT = 1:length(dataOut.spikecount_at_ctr_OFF{i})
            plot.raster2(dataOut.spikecount_at_ctr_OFF{i}{iT}/2e4,'color','k','height',0.75,'offset', iT+5,'ylim',[0 11],'xlim',[-0.5 1])
        end
        title(sprintf('cl %d) keep = %d ', dataOut.clus_no{i},dataOut.keep(i)))
        subplotCnt = subplotCnt+1;
    end
    progress_info(i,length(selClus));
    
end
shg

% add cluster and date info
% dataOut.clus_num = idxFinalSel.keep;
% dataOut.date = get_dir_date;
% dirName =  '../analysed_data/moving_bar_ds';
% mkdir(dirName)
% save(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'), 'dataOut');
% fprintf('dataOut saved.\n')
