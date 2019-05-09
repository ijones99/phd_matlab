
a =mysort.mea.CMOSMEA('Trace_id747_2013-04-10T17_11_34_2.stream.h5','hpf',350,'lpf',8000,'filterOrder',6);
mysort.plot.SliderDataAxes(a)

%%

dirName = '../analysed_data/profiles/White_Noise/';
% load ../analysed_data/profiles/White_Noise/10Apr2013_0019n6.mat
load(fullfile(dirName,fileNames(75).name));
st = data.White_Noise.spiketimes(1:min(end,2000));
wf = a.getWaveform(round(st),10,35);
%
figure
twf = mysort.wf.v2t(wf,a.MultiElectrode.getNElectrodes);
mysort.plot.waveforms2D(twf, a.MultiElectrode.electrodePositions,'plotMedian', 1);

%% check spike numbers

fileNames = dir(fullfile(dirName, '*.mat'));

lengths = [];
for i=1:length(fileNames)
    load(fullfile(dirName,fileNames(i).name));
    lengths(i) = length(data.White_Noise.spiketimes);

end

figure, bar(lengths)

%% load data to view in UMS
ums = load('/home/ijones/ln_spikesorting/10Apr2013/Trace_id747_2013-04-10T17_11_34_2.stream/sortings/run_01_group070_Export4UMS2000.mat')
%%
splitmerge_tool(ums.localSorting.spikes)
length(data.White_Noise.spiketimes)

