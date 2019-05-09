function write_log(stimIdName, logType)
% write_log(stimIdName, logType)
%   stimIdName = name of stimulus or stimulus file name
%   logType = 'pre' for before experiment or 'post' for following it

if strcmp(logType, 'pre')
    % -------- WRITE DATA LOG --------
    logFileExistStatus = exist(strcat('Stimulus_Log_File_',datestr(now(),29),...
        '.txt'));
    stimLogFile= strcat('Stimulus_Log_File_',datestr(now(),29),'.txt');
    dirPath = '';
    fid = fopen(fullfile(dirPath,stimLogFile),'a');
    writeMsg = strcat(datestr(now(),30), ' (',datestr(now(),31) , ')',...
        ' - begin stimulus: ',...
        stimIdName,'\n');

    % Add title to log
    if ~logFileExistStatus
        fprintf(fid,strcat(['------- Stimuli Presentation Log File, ', ...
            datestr(now(),29) ,...
            ' -------\n\n\n']));
    end
    % write info
    fprintf(fid,writeMsg);
    fclose(fid);

elseif strcmp(logType, 'post')
    % after recording
    stimLogFile= strcat('Stimulus_Log_File_',datestr(now(),29),'.txt');
    dirPath = '';
    fid = fopen(fullfile(dirPath,stimLogFile),'a');
    writeMsg = strcat(datestr(now(),30), ' (',datestr(now(),31) , ')',...
        ' - end stimulus: ',stimIdName,'\n\n');
    fprintf(fid,writeMsg);
    fclose(fid);

else
    disp('Error with log type\n');


end