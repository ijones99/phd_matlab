flist = {};flist_build_footprint;

validInds = [1:length(flist)];
chunkSize = 3;

elNumbers = zeros(length(flist),4);

for i=1:length(flist)
    
    
    ntk=initialize_ntkstruct(flist{i},'hpf', 500, 'lpf', 3000);
    [ntk2 ntk]=ntk_load(ntk, chunkSize);
    elNumbers(i,:) = ismember(initSegElNumbers,ntk2.el_idx);
    
    
    if sum(ismember(initSegElNumbers,ntk2.el_idx))~=4
        validInds(i) = NaN;
    end
    fprintf('Progress %3f\n', i/length(flist));
end

validInds(find(isnan(validInds))) = [];