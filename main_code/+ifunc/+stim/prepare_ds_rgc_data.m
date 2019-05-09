function S = process_ds_rcg_data(timestamps, varargin)
% function S = process_ds_rcg_data(timestamps, frameno, varargin)
% P.angle = 1;
% P.barHeight = 1;
% P.velocity = 1;
% P.brightness = 1;
% P.repeats = 1;

P.angle = 1;
P.barHeight = 1;
P.velocity = 1;
P.brightness = 1;
P.repeats = 1;
P.frameno = [];
P.startStopTimes = [];
P = mysort.util.parseInputs(P, varargin, 'error');




% get start and stop times of stimuli
if ~isempty(P.frameno)
    acqRate = 2e4;
    interStimIntervalSec=.2;
    stimFramesTsStartStop = get_stim_start_stop_ts(frameno, interStimIntervalSec);
    startStopTimes = reshape(stimFramesTsStartStop,2,length(stimFramesTsStartStop)/2)'; % columns: start / stop    
elseif ~isempty(P.startStopTimes)
    startStopTimes = P.startStopTimes;
else
    fprintf('Error with spike times.\n');
    return
end


i=1;
P.repeatTimestamps={};
for iAngle = P.angle
    for iBarHeight = P.barHeight
        for iVelocity = velocity
            for iBrightness = brightness
                for iRepeats = repeats
                    S.stimNames = {'angle', 'barHeight', 'velocity', 'brightness', 'repeats'};
                    S.stimulus(i) = [iAngle iBarHeight iVelocity iBrightness iRepeats];
                    S.repeatTimestamps{i} = select_spiketrain_epoch(timeStamps, startStopTimes(i,1), stopTime(i,2));
                    
                    i=i+1;
                end
            end
        end
    end
end









end