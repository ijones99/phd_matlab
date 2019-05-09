function timePerStimPerFile  =  compute_proc_time( nStart, nEnd, numFiles, numStim, avgSize1File )
% function timePerStimPerFile  =  compute_proc_time( nStart, nEnd, numFiles, numStim, avgSize1File )
% ARGUMENTS
%   nStart = datenum('March 06, 2013  22:02:32');
%   nEnd = datenum('March 07, 2013  03:03:19');
%   numFiles = 18;
%   numStim = 5;
%   avgSize1File = 0.876; %GB

nLapsedTime = nEnd-nStart;
elapsedTimeHr =  str2num(datestr(nLapsedTime,'HH')) + str2num(datestr(nLapsedTime,'MM'))/60;
timePerStimPerFile = 60*elapsedTimeHr/(numFiles*numStim);
end