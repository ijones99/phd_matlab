function list_ntk2_files( )
% list_ntk2_files(flistName, varargin)
% ARGUMENTS:
%   flistName = name of output file [string]
% VARARGS:
%   'no_proc': do not add ../proc string
%
% ian.jones@bsse.ethz.ch 2012.09.04


% get file names
ntkFileNames = dir('../proc/*.ntk');
if isempty(ntkFileNames)
    fprintf('No files found.\n');
else
    ntkFileNames = sortStruct(ntkFileNames,'datenum',1);
    
    % list all files
    for i=1:length(ntkFileNames)
        fprintf('(%d) %s\n', i, ntkFileNames(i).name);
    end
end
end

