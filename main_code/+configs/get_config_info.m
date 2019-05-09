function elConfigInfo = get_config_info(dirName, varargin)

fileIdx = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'file_idx')
            fileIdx = varargin{i+1};
  
        end
    end
end

fileNames = dir(fullfile(dirName,'*fi2el.nrk2'));
if ~isempty(fileIdx)
    fileIdxToOpen = fileIdx;
else
    fileIdxToOpen = 1:length(fileNames);
end

for i=fileIdxToOpen
    
    elConfigInfo{i} = get_el_pos_from_nrk2_file('file_dir', dirName, 'file_name', ...
        fileNames(i).name);
    
    progress_info(i,length(fileNames));
end

end