function raster_series(stCurr, stimChangeTs, idxRaster,varargin)
% RASTER_SERIES(stCurr, stimChangeTs, idxRaster,varargin)
%   'offset', 'color',  'height', 'x_offset', 'pre_stim_time_sec'
%
acqRate = 2e4;
offSet = 0;
plotColor = 'r';
dataPtHeight = 0.5;
xOffset = 0;
preStimTime_sec = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'offset')
            offSet = varargin{i+1};
        elseif strcmp( varargin{i}, 'color')
            plotColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'height')
            dataPtHeight = varargin{i+1};
        elseif strcmp( varargin{i}, 'x_offset')
            xOffset = varargin{i+1};
        elseif strcmp( varargin{i}, 'pre_stim_time_sec')
            preStimTime_sec = varargin{i+1};
        end
    end
end

for i=1:size(idxRaster,1)
    spikeTrainSeg = [];
    if max(idxRaster(i,:))<=length(stimChangeTs)
        [spikeTrain spikeTrainSeg] = spiketrains.extract_epoch_from_spiketrain(stCurr,...
            stimChangeTs(idxRaster(i,1))-preStimTime_sec,stimChangeTs(idxRaster(i,2)));
        
    else
        % for the last bit of the recording, when there is no frameno
        % change at the conclusion of the experiment
        intervalLength = diff(stimChangeTs(idxRaster(i-1,:))');
        [spikeTrain spikeTrainSeg] = spiketrains.extract_epoch_from_spiketrain(stCurr,...
            stimChangeTs(idxRaster(i,1))-preStimTime_sec,stimChangeTs(idxRaster(i,1))+intervalLength);
        
        
    end
    % plot raster of spiketrains
    plot.raster(spikeTrainSeg+xOffset,'color',plotColor,'offset', (i-1)+ offSet, 'height',dataPtHeight)
    
end



end