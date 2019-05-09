%% Spiketimes

load ../analysed_data/T11_27_53_5/02_Post_Spikesorting/cl_5658.mat
firstSpikeTime = cl_5658.spiketimes(2)*20000;
sampleSpikeTimes = cl_5658.spiketimes*20000;

figure, hold on

%% load ntk2 data
TIME_TO_LOAD = 1; % mins

% load flist with all file names
flist={};
flist_for_analysis

% frames to load
siz=TIME_TO_LOAD*60*2e4;
% init ntk
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);

[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');

%% data from ntk.data file
% cut out waveforms
subplot(4,1,1)
ntk2SpikeCutout = ntk.data(:,1:5000);

% plot
plot(ntk2SpikeCutout')
title('ntk.data');
%% data from ntk2.sig file
% cut out waveforms
subplot(4,1,2)
ntk2SpikeCutout = ntk2.sig(1:5000,:);

% plot
plot(ntk2SpikeCutout)
title('ntk2.sig');
%% data from h5 file
% cut out waveforms

filename = '../proc/experimental/Trace_id843_2011-12-06T11_27_53_5.stream.h5';
data = mysort.mea.CMOSMEA(filename);
subplot(4,1,3)
Spike_waveform = data(1:92, 1:5000)';

% plot
plot(Spike_waveform')
title('h5');

%% difference between ntk.data and h5

diffBtwnMethods = ntk2SpikeCutout-Spike_waveform';
subplot(4,1,4)

% plot
plot(diffBtwnMethods )
title('ntk2 vs h5');

