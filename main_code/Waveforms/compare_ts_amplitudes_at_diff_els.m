function peakToPeakAmps = compare_ts_amplitudes_at_diff_els(selEls, spikes, ts, hdmea)

cutLeft = 15;   
cutLength = 30; 

% % load data
% data = load_profiles_file(neurName);
% 
% % Cut Spikes
% % if the spike cutting takes to long for eg. 60000 spikes, take a random
% % subsample of all those spikes. That should be good enough for a first
% % visual inspection
% spikes = hdmea.getWaveform(ts, cutLeft, cutLength);
% 
% % convert spikes to tensor
% spikes = mysort.wf.v2t(spikes, size(hdmea,2));

% get inds and keep order in which they were found
[lia locB] = ismember(  hdmea.MultiElectrode.electrodeNumbers, selEls);
elInds = find(lia)';
locB = locB(find(locB>0))';
elInds = elInds(locB);

% get max values
ampsMax = max(spikes(:,[elInds],:), [], 1);
ampsMin = min(spikes(:,[elInds],:), [], 1);

%get peak to peak values
peakToPeakAmps = ampsMax-ampsMin;
peakToPeakAmps = permute(peakToPeakAmps, [2 3 1]);
end


















