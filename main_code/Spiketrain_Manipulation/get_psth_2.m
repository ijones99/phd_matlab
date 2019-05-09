function [psthData edges ] = get_psth_2(spikeTrain, startTime, stopTime, binSize)
% function [psthData edges ] = get_psth_2(spikeTrain, startTime, endTime, binSize)
% arguments
%   -> spikeTrain: vector of spike timestamps
%   -> startTime: time when stimulus starts
%   -> endTime: time when stimulus ends
%   -> binSize = 0.05; binning in msec

edges = [startTime:binSize:stopTime];
% +abs(startTime)
psthData = histc(spikeTrain,edges );

end
                        