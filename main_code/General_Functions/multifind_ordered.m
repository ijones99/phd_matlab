function inds = multifind_ordered(poolVals, sampleVals)

numInds = length(sampleVals);

inds = zeros(1,numInds);

for i=1:numInds
    tempInd = find(poolVals == sampleVals(i));
    if ~isempty(tempInd)
        inds(i)=tempInd;
    else
        inds(i) = NaN;
    end
    
end



end