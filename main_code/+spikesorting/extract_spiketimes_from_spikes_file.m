function st = extract_spiketimes_from_spikes_file(spikes)
% st = EXTRACT_SPIKETIMES_FROM_SPIKES_FILE(spikes)

assigns = unique(spikes.assigns);

[rows,cols,vals]  = find(spikes.labels(:,2)==4);
idxJunk = find(ismember(assigns,spikes.labels(rows,1)));
assigns(idxJunk) = [];

st = {};
for i=1:length(assigns)
    idx = find(spikes.assigns == assigns(i));
    st{i} = spikes.spiketimes(idx);
    
end


end
