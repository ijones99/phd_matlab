function tsMatrix = extract_st_from_R_to_cell(R, rIdx)
% tsMatrix = extract_st_from_R_to_cell(R, rIdx)

% timestamps
if iscell(R)
    if length(rIdx)==1
        currDataset = R{rIdx};
    elseif length(rIdx)==2
        currDataset = R{rIdx(1),rIdx(2)};
    else
        error('rIdx invalid.');
    end
else
    currDataset=R;
end


uniqueClus = unique(currDataset(:,1))';

tsMatrix = {};

% Create out matrix
for i=1:length(uniqueClus)
    tsMatrix{i}.clus_num = uniqueClus(i);
    tsMatrix{i}.ts = currDataset(find(currDataset(:,1)==uniqueClus(i)),2)';
end

end