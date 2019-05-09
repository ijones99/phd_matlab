figure
plot(x,MatchVal,'o-')
dataSet = {};


load /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/testData/analysed_data/T11_27_53_1/01_Pre_Spikesorting/chkP5.mat
dataSet{end+1} = el_5764;

load /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/testData/analysed_data/T11_27_53_1/01_Pre_Spikesorting/chk1.mat
dataSet{end+1} = el_5764;

load /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/testData/analysed_data/T11_27_53_1/01_Pre_Spikesorting/chk1P5.mat
dataSet{end+1} = el_5764;

load /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/testData/analysed_data/T11_27_53_1/01_Pre_Spikesorting/chk2.mat
dataSet{end+1} = el_5764;


for i=1:4
    MatchVal(i) = length(intersect(dataSet{i}.spiketimes, dataSet{4}.spiketimes))/length(dataSet{4}.spiketimes);
end

x = [0.5 1 1.5 2];

figure
plot(x,MatchVal,'o-')