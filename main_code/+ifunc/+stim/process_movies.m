function S = process_movies(spiketimes, startStopTimesCol)
% function S = process_ds_rcg_data(timestamps, frameno, varargin)
% THESE VALUES COME FROM THE SETTINGS
% P.angle = 1;
% P.barHeight = 1;
% P.velocity = 1;
% P.brightness = 1;
% P.repeats = 1;
acqRate = 2e4;
% P.frameno = [];
% P.startStopTimesCol = [];
% P = mysort.util.parseInputs(P, varargin, 'error');

i=1;
S.repeatSpikeTimeTrain={};
for i = 1:size(startStopTimesCol,1)
    S.repeatSpikeTimeTrain{i} = select_spiketrain_epoch(spiketimes, startStopTimesCol(i,1), ...
        startStopTimesCol(i,2),'epochTimescale', 1);
end


end