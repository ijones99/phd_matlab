function flistIdx = filename_idx_to_flist_idx(ntkFileNames, flist, fileIdx  )
% flistIdx = FILENAME_IDX_TO_FLIST_IDX(ntkFileNames, flist, fileIdx  )
%

flistIdx = [];
    for i=1:length(fileIdx)
        
        % curr file name
        flistNameCurr = ntkFileNames(fileIdx(i)).name;
        
        % find file in flist
        flistIdx(i) = cells.cell_find_str2(flist, flistNameCurr, 'partial_match')
        
    end






end