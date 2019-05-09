function selSpikes = get_selected_spikes(spiketrain, startTime, stopTime, varargin)
% function selSpikes = get_selected_spikes(spiketrain, startTime, stopTime,
% varargin)
%
% PURPOSE: get selected spikes from a spike train
%
% FLAGS: 
%   'align_to_zero'

alignToZero = 0;

if ~isempty(varargin)
   for i = 1:length(varargin)
       if strcmp(varargin{i}, 'align_to_zero')
           alignToZero = 1;
       end
       
   end
end

% get selected spikes
selSpikes = spiketrain(find(and(spiketrain >= startTime, spiketrain <= stopTime)));

% align to start time (start time = 0)
if alignToZero
   selSpikes =  selSpikes - startTime;
end

end