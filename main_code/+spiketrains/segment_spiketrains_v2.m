function [spikeTimesOut spikeTimesOutAdj] = segment_spiketrains_v2(spikeTimes, switchTime, varargin)
% [spikeTimesOut spikeTimesOutAdj] = SEGMENT_SPIKETRAINS(spikeTimes, switchTime)
%
% varargin
%   'post_switch_time_sec'
%
% v2 changes:
%   1) no 0 at beginning of switches
%   2) varargin options

numSwitches = length(switchTime);
postStimConstraint_sec = 0;preStimConstraint_sec = 0;
acqRate = 2e4;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'post_switch_time_sec')
            postStimConstraint_sec  = varargin{i+1};
        elseif strcmp( varargin{i}, 'pre_switch_time_sec')
            preStimConstraint_sec  = varargin{i+1};
        end
    end
end

postStimConstraint_samp = postStimConstraint_sec*acqRate;
preStimConstraint_samp = preStimConstraint_sec*acqRate;
spikeTimesOut = {};
spikeTimesOutAdj = {};
for i=1:numSwitches
    if isempty(postStimConstraint_samp)
        if i<numSwitches
            spikeTimesOut{i} = spikeTimes(find(and(spikeTimes>=switchTime(i),  ...
                (spikeTimes<switchTime(i+1)))));
        else
            spikeTimesOut{i} = spikeTimes(find(spikeTimes>=switchTime(i)));
            
        end
        
    elseif postStimConstraint_samp ~=0 | preStimConstraint_samp ~=0  % set time constraint following switch
        
        spikeTimesOut{i} = spikeTimes(find(and(spikeTimes>=switchTime(i)-preStimConstraint_samp,  ...
            (spikeTimes<switchTime(i)+postStimConstraint_samp))));
        
        
    end
      spikeTimesOutAdj{i} = spikeTimesOut{i}-switchTime(i);
    
end



end