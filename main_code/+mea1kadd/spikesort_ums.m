function spikes = spikesort_ums(Xfilt)
% spikes = SPIKESORT_UMS(Xfilt)

Fs = 2e4;
spikes = ss_default_params(Fs,'default_waveformmode',2);
spikes = ss_detect({Xfilt},spikes);
spikes = ss_align(spikes);
spikes = ss_kmeans(spikes);
spikes = ss_energy(spikes);
spikes = ss_aggregate(spikes);
splitmerge_tool(spikes)

end
