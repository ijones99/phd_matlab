function fileListIdx = get_filelist_idx_approved(fileList, threshold)
% fileListIdx = GET_FILELIST_IDX_APPROVED(fileList, threshold)

if nargin < 2
    threshold = 0;
end
fileListIdx = [];
for i=1:size(fileList, 1)
    if ~isempty(fileList{i,3})
        if fileList{i,3} > threshold
            fileListIdx(end+1) = i;
        end
    end
end

fileListIdx = fileListIdx';

end