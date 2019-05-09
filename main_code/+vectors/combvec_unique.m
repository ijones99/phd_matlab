function out = combvec_unique(a,b)
% out = COMBVEC_UNIQUE(a,b)
%
% Purpose: unique combination of two vectors
%

result = combvec(a,b);
result = result';
resultSorted = sort(result,2);
out = unique(resultSorted,'rows');


end