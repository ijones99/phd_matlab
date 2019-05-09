function spikes = ums_merge_spikes_files(ntk2, spikes, spikesAdd)

% function to merge two files containing spikes
% author: ijones
%
%                   params: [1x1 struct]
%         clus_of_interest: [12 14 15]
%     template_of_interest: {[]  []  []  []  []  []  []  []  []  []  []  [26x101 double]  []  [26x101 double]  [26x101 double]}
%                        x: [1x101 double]
%                        y: [1x101 double]
%                     info: [1x1 struct]

MaxSpikeAssignsNumOld = max(unique(spikes.assigns)); % max assign number for the assigns from the orig spikes file;
% new spikes file must exceed this number
MinSpikeAssignsNumNew = min(unique(spikesAdd.assigns));
spikeAssignAug = MaxSpikeAssignsNumOld - MinSpikeAssignsNumNew + 1;

spikes.clus_of_interest = [spikes.clus_of_interest spikesAdd.clus_of_interest+spikeAssignAug];
spikes.template_of_interest = [spikes.template_of_interest spikesAdd.template_of_interest];

%               spiketimes: [1x1132 single]
spikes.spiketimes = [spikes.spiketimes spikesAdd.spiketimes];
[spikes.spiketimes spiketimesInd] = sort(spikes.spiketimes); % sort the spike times

%                waveforms: [1132x30x7 single]
% spikes.waveforms = [spikes.waveforms; spikesAdd.waveforms];
% spikes.waveforms = spikes.waveforms(spiketimesInd,:,:);
numberChs = (  size(spikes.waveforms,3)+size(spikesAdd.waveforms,3) )

spikes.waveforms = zeros(length(spikes.spiketimes), 42, numberChs);
for i=1:42
    i
    spikes.waveforms(:,i,1:numberChs) = ntk2.sig(ceil(spikes.spiketimes*2e4)-13+i, 1:numberChs);
end

spikes.info = rmfield(spikes.info,'align')
spikesAdd.info = rmfield(spikesAdd.info,'align')



%                   trials: [1x1132 single]
spikes.trials = [spikes.trials spikesAdd.trials];
spikes.trials = spikes.trials(spiketimesInd);
%          unwrapped_times: [1x1132 single]
spikes.unwrapped_times = [spikes.unwrapped_times spikesAdd.unwrapped_times];
spikes.unwrapped_times = spikes.unwrapped_times(spiketimesInd);
%                  assigns: [1x1132 double]
spikes.assigns = [spikes.assigns spikesAdd.assigns+spikeAssignAug];
spikes.assigns = spikes.assigns(spiketimesInd);
%                   labels: [4x2 double]
spikes.labels = [spikes.labels; spikesAdd.labels+spikeAssignAug];

%                             ----- info: [1x1 struct] -----
%               detect: [1x1 struct]
%                  pca: [1x1 struct]
%                align: [1x1 struct]
%               kmeans: [1x1 struct]
%     interface_energy: [15x15 double]
%                 tree: [11x2 double]

spikes.info.detect.stds = [spikes.info.detect.stds spikesAdd.info.detect.stds];
spikes.info.detect.thresh = [spikes.info.detect.thresh spikesAdd.info.detect.thresh];
spikes.info.detect.event_channel = [spikes.info.detect.event_channel; spikesAdd.info.detect.event_channel];
spikes.info.detect.event_channel = spikes.info.detect.event_channel(spiketimesInd);
spikes.info.detect.dur = max(spikes.info.detect.dur, spikesAdd.info.detect.dur);

spikes.info.pca.u = [spikes.info.pca.u; spikesAdd.info.pca.u];
spikes.info.pca.u = spikes.info.pca.u(spiketimesInd,:);

spikes.info.kmeans.iteration_count = [spikes.info.kmeans.iteration_count spikesAdd.info.kmeans.iteration_count];
spikes.info.kmeans.assigns = [spikes.info.kmeans.assigns spikesAdd.info.kmeans.assigns+spikeAssignAug];
%     spikes.info.kmeans.centroids = [spikes.info.kmeans.centroids; spikesAdd.info.kmeans.centroids];
spikes.info.kmeans.colors = [spikes.info.kmeans.colors; spikesAdd.info.kmeans.colors];
spikes.info.kmeans.num_clusters = sum(size(spikes.info.kmeans.colors,1), size(spikesAdd.info.kmeans.colors,1));

spikes = ss_align(spikes);


end