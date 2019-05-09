function [footprintMedian waveforms] = get_median_footprint(spikeTimes, hdmea, varargin)

P.num_waveforms_to_use = [];
P.cut_left = 15;
P.cut_length = 30;
P = mysort.util.parseInputs(P, varargin, 'error');


currspiketimes = double(round(spikeTimes));
if ~isempty(P.num_waveforms_to_use)
    if length(currspiketimes ) > P.num_waveforms_to_use
        currspiketimes = currspiketimes(1:P.num_waveforms_to_use);
    end
end
% get waveforms
% for cutting
P.cut_left = 15;
P.cut_length = 30;
waveforms = hdmea.getWaveform(currspiketimes, P.cut_left, P.cut_length);
% convert waveforms to tensor
waveforms = mysort.wf.v2t(waveforms, size(hdmea,2));

footprintMedian = median(waveforms,3);



end