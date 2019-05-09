function print_file_names(fileNames, varargin)
% PRINT_FILE_NAMES(fileNames)

idx =1:length(fileNames);
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'idx')
            idx = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};
        end
    end
end



for i=1:length(idx)
   fprintf('(%d) %s\n', idx(i),fileNames(idx(i)).name);
end


end