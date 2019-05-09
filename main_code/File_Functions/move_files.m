function move_files(origDirName, destDirName, varargin)

% init vars
fileInds = [];
searchPatternString = '';
fileType = '';
fileNamePhrases = {};
fileNamePrefix = '';
fileNameSuffix = '';
fileOperation = 'mv';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'file_inds')
            fileInds = varargin{i+1};
        elseif strcmp( varargin{i}, 'search_pattern')
            searchPatternString = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_type')
            fileType = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_names')
            fileNamePhrases = varargin{i+1};
        elseif strcmp( varargin{i}, 'prefix')
            fileNamePrefix = varargin{i+1};
        elseif strcmp( varargin{i}, 'suffix')
            fileNameSuffix = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_operation')
            fileOperation = varargin{i+1};
        end
    end
end



for i=1:length(fileNamePhrases)
    fileNamesFound = dir(fullfile(origDirName, ...
        strcat(fileNamePrefix,'*', fileNamePhrases{i}, '*', fileNameSuffix, fileType)));
    if length(fileNamesFound)==1
        eval(['!',fileOperation,' ' , fullfile(origDirName,fileNamesFound(1).name), ' ', destDirName]);
        if strcmp(fileOperation,'mv')
            fprintf('File %s moved.\n', fileNamePhrases{i})
        elseif strcmp(fileOperation,'cp')
            fprintf('File %s copied.\n', fileNamePhrases{i})
        end
    elseif length(fileNamesFound)>1
        fprintf('Warning: more than one file found for %s.\n', fileNamePhrases{i})
    else
        fprintf('Warning: No file found for %s.\n', fileNamePhrases{i})
    end
end




end