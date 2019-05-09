function add_timestamp_to_filename(fileDir, timeStamp, fileType)
% FUNCTION ADD_TIMESTAMP_TO_FILENAME
% modify name of recorded file with time up to seconds precision
% timestamp in format: 'yyyymmddTHHMMSS' 20000301T154517, e.g. datestr(now,30) 
%
% fileDir: directory where file is
% timeStamp: use datestr(now, 30)
% fileType: e.g. *.ntk

% check dir name for /
if ~strcmp(fileDir(end),'/')
    fileDir(end+1)='/';
end


% look for newest file in directory
fileData = dir(fullfile(fileDir,fileType));

% get file times
numFiles = length(fileData);
fileTimes = zeros(numFiles );
for i=1:numFiles 
    fileTimes(i) = fileData(i).datenum;
end

% sort file times
[Y I] = sort(fileTimes,'ascend');

% last file written
origFileName = fileData(I(end)).name;

% puttogether new name
tPosOrigName = strfind(origFileName,'T');
tPosTimeStamp = strfind(timeStamp,'T');
newFileName = strcat(origFileName(1:tPosOrigName(end)),timeStamp(tPosTimeStamp(end)+1:end));

% write new file name
eval(strcat(['!mv ', fileDir , origFileName, ' ', fileDir, newFileName,fileType(2:end)]));



end