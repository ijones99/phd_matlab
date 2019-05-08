
combos = nchoosek(1:12,2);

for i=1:size(combos,1)
[h_tt, p] = ttest2(paramClusCell{combos(i,1)}(:,1:numParamsVals),paramClusCell{combos(i,2)}(:,1:numParamsVals) );

fprintf('%0.2f %0.2f %0.2f %0.2f %0.2f \n',p)

end