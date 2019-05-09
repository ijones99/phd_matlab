function neur_plot_ds(neur, varargin)
% function NEUR_PLOT_DS(neur, varargin)
%
%   varargin
%      cluster_no: 
%      neur_idx 
%      parapin_transitions_only: parapin changes are only at major frame
%      changes (e.g. start of moving bar), as opposed to at every frame.


% settings
iDir = 1;
iPlotHeight = 1;
plotIncrement = 1;
barsPresentedOrder = [];
% varargins
clusterNo = [];
neurIdx = [];
parapinTransitionsOnly = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'cluster_no')
            name1 = varargin{i+1};
        elseif strcmp( varargin{i}, 'neur_idx')
            neurIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'parapin_transitions_only')
            parapinTransitionsOnly  = 1;
        elseif strcmp( varargin{i}, 'dir_sort')
            barsPresentedOrder  = varargin{i+1};
        end
            
        
    end
end

% get neur index
if isempty(neurIdx)
   neurIdx = find(neur.cluster_no == clusterNo );
end

% check for frameno changes
if sum(neur.images.frameno) == 0
    fprintf('Error: no parapin changes.\n');
    return;
    
end

% get locations of start and stop
if parapinTransitionsOnly
    [stimFramesTsStartStop] = get_stim_start_stop_ts_sparse(neur.images.frameno);
else
    [stimFramesTsStartStop] = get_stim_start_stop_ts(neur.images.frameno,0.15);
end

plotStyle = '.';

if ~isempty(barsPresentedOrder)
    plotDirOrder = 2*barsPresentedOrder-1;
else
    plotDirOrder =  1:2:length(stimFramesTsStartStop)-1
end

loopCounter = 1;
for i=plotDirOrder
    spikeTimeInds = find(and(neur.neurons{neurIdx}.ts>=stimFramesTsStartStop(i),...
        neur.neurons{neurIdx}.ts<=stimFramesTsStartStop(i+1)));
    
    tsPerDir{iDir} = neur.neurons{neurIdx}.ts(spikeTimeInds)-stimFramesTsStartStop(i);
    plot(tsPerDir{iDir},...
        iPlotHeight*ones(1,length(tsPerDir{iDir})),plotStyle);
    iDir = iDir +1;
    iPlotHeight = iPlotHeight+plotIncrement;
    
    % plot repeat in red
    if loopCounter>16
       plotStyle = 'r.'; 
    end
    loopCounter = loopCounter + 1;
    drawnow
end



end