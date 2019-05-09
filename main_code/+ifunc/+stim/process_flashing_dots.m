function S = process_flashing_dots(spiketimes, startStopTimes, Settings, StimMats, varargin)
% function S = process_ds_rcg_data(timestamps, frameno, varargin)
% THESE VALUES COME FROM THE SETTINGS 

P.brightness = double(Settings.DOT_BRIGHTNESS_VAL);
P.dotSize = double(Settings.DOT_DIAMETERS(StimMats.PRESENTATION_ORDER));

P.frameno = [];
P.startStopTimes = [];
P = mysort.util.parseInputs(P, varargin, 'error');

if length(P.brightness)*length(P.dotSize)~=length(startStopTimes)
    fprintf('Warning: Error with stimulus params in function "process_flashing_dots."\n')
    
end

% get start and stop times of stimuli
if ~isempty(P.frameno)
    acqRate = 2e4;
    interStimIntervalSec=.2;
    stimFramesTsStartStop = get_stim_start_stop_ts(frameno, interStimIntervalSec);
    startStopTimes = reshape(stimFramesTsStartStop,2,length(stimFramesTsStartStop)/2)'; % columns: start / stop    
elseif ~isempty(P.startStopTimes)
    startStopTimes = P.startStopTimes;
elseif ~isempty(startStopTimes)

else
    fprintf('Error with spike times.\n');
    return
end

i=1;
P.repeatSpikeTimeTrain={};
S.stimulus = zeros(1,2);
for iBrightness = P.brightness
    for iDotSize = P.dotSize
        
        S.stimNames = {'brightness', 'dotSize'};
        S.stimulus(i,1:2) = [iBrightness iDotSize];
        S.repeatSpikeTimeTrain{i} = select_spiketrain_epoch(spiketimes, startStopTimes(i,1), ...
            startStopTimes(i,2),'epochTimescale', 1);
        
        i=i+1;
        
    end
end
end









