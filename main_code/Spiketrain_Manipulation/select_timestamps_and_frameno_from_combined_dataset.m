function [timeStamps frameno] = select_timestamps_and_frameno_from_combined_dataset(timeStamps, frameno, segmentBoundaries)
% function [timeStamps frameno] = select_timestamps_and_frameno_from_combined_dataset(timeStamps, frameno, segmentBoundaries)
% Purpose: extract the relevant timestamps and framenumbers from a combined
% spike-sorted set of data

acqRate = 2e4; %samples per second

% isolate timestamps; units are seconds
timeStamps = timeStamps(find(and(timeStamps>=segmentBoundaries(1)/acqRate,timeStamps<=segmentBoundaries(2)/acqRate)));

% shift timestamps
timeStamps = timeStamps - (segmentBoundaries(1)-1)/acqRate; 

% isolate relevant part of frameno
frameno = frameno(segmentBoundaries(1):segmentBoundaries(2));

% adjust frameno
frameno = frameno - (segmentBoundaries(1)-1);


end