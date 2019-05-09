function fileNames = list_file_names(searchStr, dirName, varargin)
% selFileName = LIST_FILE_NAMES(searchStr, dirName )
%
% varargin
%   'not': string that should not be included in file name

notArg = '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'not')
            notArg = varargin{i+1};

        end
    end
end


fileNames = dir(fullfile(dirName, searchStr));

if ~isempty(notArg)
    fileNamesFilt = [];
    for i=1:length(fileNames)
        if isempty(strfind(fileNames(i).name, notArg))
            fileNamesFilt(end+1).name = fileNames(i).name;
        end

    end
    fileNames = fileNamesFilt;
end


for i=1:length(fileNames)
   fprintf('(%d) %s\n',  i, fileNames(i).name);
end

end