function spikeTrainZ = extract_epoch_from_spiketrain(spikeTrain,startTime,endTime, ...
plotStartTimeZ, plotEndTimeZ, spikeMarkerHeight, stimMarkerHeight,  yAxisLoc, varargin)

% arguments
%   -> stName: identifying name for the spiketrain (int, double, etc. or
%   string)
%   -> spikeTrain: vector of spike timestamps
%   -> preStimBorder: time to show before stimulus
%   -> postStimBorder: time to show after stimulus
%   -> startTime: time when stimulus starts
%   -> endTime: time when stimulus ends
%   -> yAxisLoc: location of raster plot spikes along the y-axis
% 
% init vars
drawText = 1;
drawCustomText = 0;
% 
% check for arguments
if ~isempty(varargin)
    for j=1:length(varargin)
        if strcmp( varargin{j}, 'no_y_axis_text')
            drawText = 0;
            if strcmp( varargin{j}, 'specific_text')
                drawText = 0;
                drawCustomText = 1;
                textToInsert = varargin{i+1};
            end
            
        end
    end
end

% variable settings
textPlacement = -0.8;

% range of time over which to show spikes - nonadjusted time
plotStartTime = startTime+plotStartTimeZ;
plotEndTime = startTime+plotEndTimeZ;

% select ts to show
spikeTrain = spikeTrain(find(and(spikeTrain>=plotStartTime,spikeTrain<=plotEndTime)));

% adjust time to zero at stimulus appearance
% plotStartTimeAdjusted = 0; % defined as zero
% plotEndTimeAdjusted = endTime - startTime ;
spikeTrainZ = spikeTrain - startTime;


                        
end
                        