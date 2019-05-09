function st = extract_spiketimes_from_spikes_file(spikes)
% st = EXTRACT_SPIKETIMES_FROM_SPIKES_FILE(spikes)

Fs = 2e4;

assigns = unique(spikes.assigns);

[rows,cols,vals]  = find(spikes.labels(:,2)==4);
idxJunk = find(ismember(assigns,spikes.labels(rows,1)));
assigns(idxJunk) = [];

st = {};
for i=1:length(assigns)
    idx = find(spikes.assigns == assigns(i));
    st{i} = double(round(spikes.spiketimes(idx)*Fs));
end


end
