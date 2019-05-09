function S = process_ds_rcg_data(spiketimes, startStopTimes, Settings, varargin)
% function S = process_ds_rcg_data(timestamps, frameno, varargin)
% THESE VALUES COME FROM THE SETTINGS 
% P.angle = 1;
% P.barHeight = 1;
% P.velocity = 1;
% P.brightness = 1;
% P.repeats = 1;

P.angle = Settings.BAR_DRIFT_ANGLE;
P.barHeight = Settings.BAR_HEIGHT_PX*Settings.UM_TO_PIX_CONV;
P.velocity = Settings.BAR_DRIFT_VEL_PX*Settings.UM_TO_PIX_CONV;
P.brightness = Settings.BAR_BRIGHTNESS;
P.repeats = Settings.BAR_REPEATS;
P.frameno = [];
P.startStopTimes = [];
P = mysort.util.parseInputs(P, varargin, 'error');

if length(P.angle)*length(P.barHeight)*length(P.velocity)*length(P.brightness)*P.repeats...
~=length(startStopTimes)
    fprintf('Error with stimulus params in function "process_ds_rcg_data."\n')
 
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
S.stimulus = zeros(1,5);
for iAngle = P.angle
    for iBarHeight = P.barHeight
        for iVelocity = P.velocity
            for iBrightness = P.brightness'
                for iRepeats = 1:P.repeats
                    S.stimNames = {'angle', 'barHeight', 'velocity', 'brightness', 'repeats'};
                    S.stimulus(i,1:5) = [iAngle iBarHeight iVelocity double(iBrightness) iRepeats];
                    S.repeatSpikeTimeTrain{i} = select_spiketrain_epoch(spiketimes, startStopTimes(i,1), ...
                        startStopTimes(i,2),'epochTimescale', 1);
                    
                    i=i+1;
                end
            end
        end
    end
end









end