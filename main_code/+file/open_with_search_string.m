function varOut = open_with_search_string(dirName, searchStr,varargin)
% varOut = open_with_search_string(dirName, searchStr)
% varargin
%   'load_into_var': load struct into variable name

origVarNameOut= 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'load_into_var')
            origVarNameOut = 1;
        end
    end
end

fileName = dir(fullfile(dirName,searchStr));
if length(fileName)> 1
    error('Multiple entries found.');
elseif length(fileName) == 0
    error('No entries found.');
end

if ~origVarNameOut
    
    varOut = load(fullfile(dirName, fileName.name));
    
else
    % load data
    loadedVar = load(fullfile(dirName, fileName.name));
    loadedVarFields = fields(loadedVar);
    
    % remove struct
    if length(loadedVarFields) > 1
        error('must have one variable in file.\n')
    end
    
    fieldName = loadedVarFields{1};
    varOut = getfield ( loadedVar, fieldName );
end




end