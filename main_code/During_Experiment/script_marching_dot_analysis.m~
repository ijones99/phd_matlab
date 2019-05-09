% LOAD SELECTED DATA
flist = {};
flist{end+1}= '../proc/Trace_id843_2012-04-25T16_28_00_4.stream.ntk'
flistFileNo =1;

% get ntk2 data field values
siz=10*2e4;
ntk=initialize_ntkstruct(flist{flistFileNo},'hpf', 500, 'lpf', 3000);


totalRecTime = 20*60*2e4;
chunkSize = 2*60*2e4;
chsInPatch = [84 108 72 25 55 90];

data = []; frameno = [];

% extract data and framenumber
for i=1:ceil(totalRecTime/chunkSize)
    [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'keep_only',  chsInPatch);
%     [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1');
   
    data = [data single(ntk2.sig)'];
    
    frameno = [frameno single(ntk2.images.frameno)];
    i
end
    
%% analysis
interStimIntervalSec = 3.2;
% get stimulus stop and start frame locations
stimFramesTsStartStop = get_stim_start_stop_ts(frameno, interStimIntervalSec);

% set thresholding values
dataStds = std(data,0,2);
thr = 4;
thrVal = thr*dataStds;

% do thresholding
chSpikeCounter{1}.count = [];%zeros(1,size(data,2));
spikeCounterCount = 1;
for iStimulus = 1:2:length(stimFramesTsStartStop)
    
    for i=1:size(data,1)
        indAboveThr = find(data(i,stimFramesTsStartStop(iStimulus): ...
            stimFramesTsStartStop(iStimulus+1))>thrVal(i));
        
        binarySwitcheInds = diff(indAboveThr);
        chSpikeCounter{spikeCounterCount}.count(i) = length(find(binarySwitcheInds>0))
        
    end
    iStimulus
    spikeCounterCount = spikeCounterCount+1;
end

%% calculate mean spiking activity

for i=1:length(chSpikeCounter)
   meanSpiking(i) =  mean(chSpikeCounter{i}.count);
    
end

meanSpikingReshaped = flipud(rot90(reshape(meanSpiking,5,5)'));
figure, imagesc(meanSpikingReshaped)
% 'FontSize', 15,'LineWidth', 2
set(gca, 'XTick', 1:5, 'XTickLabel', {[50:100:450]});
set(gca, 'YTick', 1:5, 'YTickLabel', {[50:100:450]});
title('Thresh Spiking Response Marching Dot Stimulus (150um diam) 25 % up for ch #s [84 108 72 25 55 90]')
