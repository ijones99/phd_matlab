% script to calculate spike sorting time

numberFiles = 5;
numberMatlabProcesses = 1;
spikesPerSecond = 72;
recordingLengthSeconds = 35*60;
kmeansReps = 10;
secProcessingTimePerSecRecPerSpikesPerSec = 0.0033;

timeToFinish = (numberFiles/numberMatlabProcesses)*secProcessingTimePerSecRecPerSpikesPerSec* ...
    recordingLengthSeconds*kmeansReps*spikesPerSecond;

fprintf('Finished in %2.2f hours (equals %3.1f minutes)\n', timeToFinish/60/60, timeToFinish/60);
