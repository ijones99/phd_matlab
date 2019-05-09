% script speed comparison : ntk2 vs h5

minutesToLoad = [1 1.5 2 3 4 5 10]
for i=1:length(minutesToLoad)
%% Spiketimes

load ../analysed_data/T11_27_53_5/02_Post_Spikesorting/cl_5658.mat
firstSpikeTime = cl_5658.spiketimes(2)*20000;
sampleSpikeTimes = double(round(cl_5658.spiketimes*20000)); % 


timeInfoRow = i;
TIME_TO_LOAD = minutesToLoad(i); % mins
preSpikeTime = 30;
postSpikeTime = 30;

% frames to load
siz=TIME_TO_LOAD*60*2e4;

% trim spiketimes
sampleSpikeTimes(find(sampleSpikeTimes> siz-30)) = [];
sampleSpikeTimes = single( sampleSpikeTimes' );
origSampleSpikeTimes = double(sampleSpikeTimes);

% create grid of replicated timestamp grid
sampleSpikeTimes = repmat(sampleSpikeTimes, 1, preSpikeTime+postSpikeTime+1);

% create incremental times
incTimes = -preSpikeTime:postSpikeTime;
incTimes = repmat(incTimes,length(sampleSpikeTimes),1);

% add times to ts grid
sampleValuesGrid = sampleSpikeTimes+incTimes; clear incTimes;
sampleValuesDims = size(sampleValuesGrid);

% reshape to linear
sampleValues = reshape(sampleValuesGrid, 1, sampleValuesDims(1)*sampleValuesDims(2));

%% ntk
tic

% load flist with all file names
% flist={};
% flist_for_analysis


% init & load ntk
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');
data = single(ntk2.sig); clear ntk2 ntk2;

% cut out values
ntkSpikeWaveforms = data( sampleValues , 1:92);
ntkSpikeWaveformsLinear = reshape(ntkSpikeWaveforms, [sampleValuesDims(1) sampleValuesDims(2) 92]);

timeStop = toc;

loadingTimeInfo(timeInfoRow,1) = TIME_TO_LOAD; %time
loadingTimeInfo(timeInfoRow,2) = size(sampleValuesGrid,1); % number spikes
loadingTimeInfo(timeInfoRow,3) = timeStop; %mins loaded

fprintf('# spikes: %d \nSeconds processing time: %10.1f \nMins of data loaded: %d\n', ...
    sampleValuesDims(1), timeStop, TIME_TO_LOAD);

% print figure
% figure, plot(ntkSpikeWaveformsLinear(:,:,1)')

%% h5

tic
filename = '../proc/experimental/Trace_id843_2011-12-06T11_27_53_5.stream.h5';
data = mysort.mea.CMOSMEA(filename);
% h5SpikeWaveforms = data(  1:92,double(sampleValues));
% h5SpikeWaveforms = reshape(h5SpikeWaveforms, [sampleValuesDims(1) sampleValuesDims(2) 92]);
% timeStop = toc;

% h5SpikeWaveforms = zeros(size(sampleValuesGrid,1), preSpikeTime+postSpikeTime+1);

% for i = 1:6%size(sampleValuesGrid,1);
%     h5SpikeWaveforms(i,:,:) = data(  1:92, origSampleSpikeTimes(i)-preSpikeTime: ...
%         origSampleSpikeTimes(i)+postSpikeTime) ;%dims [61 92]
    h5SpikeWaveforms = data.getCutWaveforms( origSampleSpikeTimes, preSpikeTime, postSpikeTime) ;%dims [61 92]
% end

timeStop = toc;

loadingTimeInfo(timeInfoRow,4) = timeStop; %mins loaded

fprintf('# spikes: %d \nSeconds processing time: %10.1f \nMins of data loaded: %d\n', ...
    sampleValuesDims(1), timeStop, TIME_TO_LOAD);



% figure, plot(h5SpikeWaveforms(:,:,1))
end

