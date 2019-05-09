function print(myMat)

if find(ismember(size(myMat), 1))
    for i=1:length(myMat)
        fprintf('%d) %d\n', i, myMat(i));
        
    end
end

end
