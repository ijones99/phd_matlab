function plot_response_moving_flashing_squares()
% function: plots a response to the data aquired from the
% show_moving_flashing_squares function. Intervals between parapin changes
% : 0.5*1/autoFlashFreq with breaks of 1.5*0.5*1/autoFlashFreq between
% positions.
%%
autoFlashFreq = 1;
numPositions = 16; numRepeats = 5; % this must be the same as in the function show_moving_flashing_squares
acqFreq = 2e4;
numRows = sqrt(numPositions);
numCols = sqrt(numPositions);
rmsMultiplier = 3;

dirProc = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/17July2012/proc/'; % get directory location

if length(dirProc) == 0
   fprintf('In wrong directory\n');
   break
end

fileDataProc = dir(dirProc); % get file data

dateInfo = []; % contains info about dates of files
for i=3:length(fileDataProc) % go from 3 because first two are "." and ".."
    dateInfo(i) = sum(datestr(fileDataProc(i).date,30));
end

[junk, indNewestFile] = max(dateInfo ); indNewestFile = indNewestFile+2;% find largest index; add two since i started at 3 above

siz= (numPositions*(numRepeats+1.5)*autoFlashFreq+2*60)*acqFreq; % amount to load plus 5 mins

flist = {}; % load newest file
flist{end+1} = fullfile(dirProc, fileDataProc(indNewestFile).name);
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');

% get signal
chipSignal = single(ntk2.sig);

% get stim start stop info
frameno = single(ntk2.images.frameno);
interStimIntervalSec = 1/autoFlashFreq*0.9*1.5*0.5; % the pause is 1.5 times half the 
% interval between parapin changes
stimFramesTsStartStop = get_stim_start_stop_ts(frameno, interStimIntervalSec);

% get timestamps for all electrodes
timeStamps = single(zeros(size(chipSignal,1),size(chipSignal,2)-1));
textprogressbar('getting timestamps: ');
for i=1:size(chipSignal,2)
    rmsNoise = rms(chipSignal(1:20*2e4,i));
    signalThresholded = find(chipSignal(:,i) > rmsMultiplier*rmsNoise);
    thrCrossings = diff(signalThresholded); % find time stamps
    timeStamps(i,:)
    textprogressbar(i)
end
textprogressbar('done');


timeStamps(find(or(timeStamps~=0,timeStamps~=1)))=0; % get rid of non-one values 

figure, hold on
textprogressbar('calculating spiking rates: ');
spikeCounts = zeros(1,size(chipSignal,2)); % compute spiking rates
epochSpikeTimes = 0;
for iPos=1:2:numPositions*2
    
    epochSpikeTimes = 
    
    % plot data
    subplot(numRows, numCols, i), hold on % designate subplot
    
    
    textprogressbar(iPos);
end
textprogressbar('done');
%%
end