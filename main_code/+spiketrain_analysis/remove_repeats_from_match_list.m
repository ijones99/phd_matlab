function [matchListUnique keepIdx remIdx] = remove_repeats_from_match_list(matchList)
% [matchListUnique keepIdx remIdx] = remove_repeats_from_match_list(matchList)

keepIdx=[];
for i=1:size(matchList,1)
    idxCurr = find(matchList(:,1)==i);
    if not(isempty(idxCurr))
        keepIdx(end+1)=idxCurr(1);
    end
end
matchListUnique = matchList(keepIdx,:);









end