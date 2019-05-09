function [fileNamesSel fileNamesAll idxSel] = select_files(searchStr, dirName,varargin)
% [fileNamesSel fileNamesAll idxSel] = SELECT_FILES(searchStr, dirName)

idxSel = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'idx')
            idxSel= varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};
        end
    end
end



fileNamesAll = filenames.list_file_names(searchStr, dirName);

if isempty(idxSel)
    idxSel = input('Please select file name indices [n1:n2] >> ');
end
fileNamesSel = fileNamesAll(idxSel);



end
