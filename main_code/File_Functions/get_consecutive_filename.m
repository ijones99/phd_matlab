function fileNameNew = get_consecutive_filename(fileName, varargin)
% fileNameNew = GET_CONSECUTIVE_FILENAME(fileName, varargin)

dirPath = '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)

        if strcmp( varargin{i}, 'dir_path')
            dirPath = varargin{i+1};
        end
    end
end

existingFileNames = dir(fullfile(dirPath,[fileName, '*']));

if ~isempty(existingFileNames)

fileNameMostRecent = existingFileNames(end).name;

decimalLoc = strfind(fileNameMostRecent,'.');

% determine number of digits
stillNum = 1;
i=1;
while stillNum
    currChar = str2num(fileNameMostRecent(decimalLoc-i));
    if ~isempty(currChar)
        i = i+1;
    else
        stillNum = 0;
    end
end

numDigits = i-1;
nameNumber = str2num(fileNameMostRecent(decimalLoc-numDigits:decimalLoc-1));

else
    nameNumber = 0;
end

fileNameNewPrintText = ['%s%0', num2str(numDigits),'d']; 

fileNameNew = sprintf(fileNameNewPrintText, fileNameMostRecent(1:decimalLoc-numDigits-1), nameNumber+1);




end