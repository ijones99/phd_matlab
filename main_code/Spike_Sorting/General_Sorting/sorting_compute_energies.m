function spikes = sorting_compute_energies(data, elNumbers, varargin )


% check for arguments
Fs = 2e4;
thrValue = 3.5;
numKmeansReps = 3;
%% SPIKE SORTING

tic
spikes = [];
% default_waveformmode = 1 is for all traces mode
spikes = ss_default_params(Fs, 'thresh', thrValue);
spikes.elidx = elNumbers;
% spikes.channel_nr = chNumbers;
fName = 'fileName';
% SET VIEW MODE;
spikes.params.display.default_waveformmode = 1; % 1: "show all spikes" mode; ...
% 2: show bands

% give file names to spike struct
spikes.fname = fName;
spikes.clus_of_interest=[];
spikes.template_of_interest=[];

% detect spikes
spikes = ss_detect(data,spikes)

spikes = ss_align(spikes);
% cluster spikes
options.reps = numKmeansReps;
options.progress = 1;
spikes = ss_kmeans(spikes, options);
spikes = ss_energy(spikes);
spikes = ss_aggregate(spikes,1,'hide_figure');


toc



end
