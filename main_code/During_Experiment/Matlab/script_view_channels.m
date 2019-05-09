clear 
flist={};%flist{end+1}='../proc/Trace_id843_2012-03-29T13_14_30_12.stream.ntk';
flist{end+1}= '../proc/Trace_id1032_2012-08-21T14_53_14_4.stream.ntk'
flistFileNo =1;
%% LOAD SELECTED DATA
% get ntk2 data field values
siz=6*2e4;
ntk=initialize_ntkstruct(flist{flistFileNo},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');

chIndsToKeep = [1:20];
% [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only', chIndsToKeep,  'images_v1');
% [ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');
%% plot number of active channels
data = ntk2.sig;
acqFreq = 2e4;
dataStds = std(data,0,1);
thr = 4;
preSpike = 0.002*acqFreq;postSpike = 0.002*acqFreq;
thrVal = thr*dataStds;

chSpikeCounter = zeros(1,size(data,2));
for i=1:size(data,2)
    indAboveThr = find(data(:,i)>thrVal(i));
    
    binarySwitcheInds = diff(indAboveThr);
    spikeLocInds = find(binarySwitcheInds>0);
   
    
    chSpikeCounter(i) = length(spikeLocInds);
    channelNr(i) = ntk2.channel_nr(i);
end
numActiveChannels = length(find(chSpikeCounter>0));
avgActiveChannels = mean(chSpikeCounter);

[Y, chInd] = sort(chSpikeCounter,'descend');
spikeCounts = channelNr(chInd);
spikeCounts(2,:) = chSpikeCounter(chInd);
figure, plot(channelNr(chInd), chSpikeCounter(chInd),'*'), hold on
line([0 size(data,2) ], [ avgActiveChannels avgActiveChannels],'Color','g','LineWidth',2);
indZeroVals = find(chSpikeCounter==0);
plot(channelNr(indZeroVals), chSpikeCounter(indZeroVals),'r*'), hold off
title(strcat([num2str(numActiveChannels), ' of ', num2str(length(channelNr)), ' Active Channels Found']));
text(-10, avgActiveChannels, num2str(round(avgActiveChannels)),'FontWeight','bold');
xlabel('Channel No');
ylabel('Number Spikes');
spikeCounts
%% plot data
timeToPlot = 5*20e3;
figure, signalplotter(ntk2, 'max_channels', 100,'max_samples', timeToPlot), hold on;
title( strrep(flist{flistFileNo},'_','-'),'FontSize',16);
stimFramesTsStartStop = get_stim_start_stop_ts(ntk2.images.frameno, 0.1);
frameChangeInds = find(stimFramesTsStartStop<5*20e3); 
plot([stimFramesTsStartStop(frameChangeInds)/20000 stimFramesTsStartStop(frameChangeInds)/20000],
[0 6e4])


